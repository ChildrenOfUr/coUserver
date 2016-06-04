library chat_handler;

import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:coUserver/common/identifier.dart';
import 'package:coUserver/common/keep_alive.dart';
import 'package:coUserver/common/util.dart';
import 'package:coUserver/common/user.dart';
import 'package:coUserver/API_KEYS.dart';

import "package:http/http.dart" as http;
import "package:http/src/multipart_request.dart";
import "package:http/src/multipart_file.dart";
import "package:http/src/streamed_response.dart";
import 'package:slack/io/slack.dart' as slack;
import 'package:image/image.dart';
import 'package:redstone/redstone.dart' as app;
import 'package:redstone_mapper_pg/manager.dart';

// handle chat events
class ChatHandler {
	static Map<String, Identifier> users = new Map<String, Identifier>();

	static void superMessage(
		String message, {String username: 'GOD', String channel: 'Global Chat'}
	) {
		sendAll(JSON.encode({
			'username': username,
			'message': message,
			'channel': channel
		}));
	}

	static Future handle(WebSocket ws) async
	{
		/**we are no longer using heroku so this should not be necessary**/
		//if a heroku app does not send any information for more than 55 seconds, the connection will be terminated

		if (!KeepAlive.pingList.contains(ws))
			KeepAlive.pingList.add(ws);

		ws.listen((message) async
		{
			Map map = JSON.decode(message);
			/*if(relay.connected)
			{
				//don't repeat /list messages to the relay
				//or possibly any statusMessages, but we'll see
				if(map['statusMessage'] == null || map['statusMessage'] != "list")
					relay.sendMessage(message);
			}*/
			if (map["channel"] == "Global Chat" && !(await UserMutes.INSTANCE.userMuted(map["username"]))) {
				if (map["statusMessage"] == null && map["username"] != null &&
				    map["message"] != null)
					slackSend(map["username"], map["message"]);
			}
			processMessage(ws, message);
		},
			          onError: (error) {
				          cleanupLists(ws);
			          },
			          onDone: () {
				          cleanupLists(ws);
			          });
	}

	static void slackSend(String username, String text) {
		try {
			String icon_url = "http://childrenofur.com/data/heads/$username.head.png";
			http.get(icon_url).then((response) {
				//if the head picture doesn't already exist, try to make one
				if (response.statusCode != 200) {
					getSpritesheets(username).then((Map spritesheets) {
						if (spritesheets['base'] != null) {
							http.get(spritesheets['base']).then((response) {
								Image image = decodeImage(response.bodyBytes);
								int frameWidth = image.width ~/ 15;
								int frameHeight = (image.height * .6).toInt();
								int xStart = 0;
								if (frameWidth > frameHeight)
									xStart = frameWidth - frameHeight;
								image = copyCrop(image, xStart, 0, frameWidth, frameHeight);
								List<int> bytes = encodePng(image);

								MultipartRequest request = new MultipartRequest("POST",
									                                                Uri.parse(
										                                                "http://childrenofur.com/data/heads/uploadhead.php"));
								request.files.add(new MultipartFile.fromBytes(
									'file', bytes, filename: '$username.head.png'));
								request.send().then((StreamedResponse response) {
									icon_url =
									'http://childrenofur.com/data/heads/$username.head.png';
									_sendMessage(text, username, icon_url);
								});
							});
						}
						//if the username isn't found, just use the cupcake
						else {
							icon_url = 'http://s21.postimg.org/czibb690j/head.png';
							_sendMessage(text, username, icon_url);
						}
					});
				}
				else
					_sendMessage(text, username, icon_url);
			});
		}
		catch (err) {
			log('error sending slack message: $err');
		}
	}

	static void _sendMessage(String text, String username, String icon_url) {
		slack.Slack coUGlobal = new slack.Slack(couWebhook);
		slack.Message message = new slack.Message(text, username: username, icon_url: icon_url);
		coUGlobal.send(message);

		slack.Slack glitchForever = new slack.Slack(glitchForeverWebhook);
		message = new slack.Message(text, username: username, icon_url: icon_url);
		glitchForever.send(message);
	}

	static void cleanupLists(WebSocket ws, {String reason: 'No reason given'}) {
		try {
			KeepAlive.pingList.remove(ws);
			ws.close(4001, reason);
		}
		catch (err) {
			log('error: $err');
		}

		String leavingUser;
		users.forEach((String username, Identifier id) {
			if (id.webSocket == ws) {
				id.webSocket = null;
				leavingUser = username;
			}
		});
		users.remove(leavingUser);

		//send a message to all other clients that this user has disconnected
		Map map = new Map();
		map["message"] = " left.";
		map['channel'] = "Local Chat";
		map["username"] = leavingUser;
		sendAll(JSON.encode(map));
	}

	static processMessage(WebSocket ws, String receivedMessage) async {
		try {
			Map map = JSON.decode(receivedMessage);

			if (map['clientVersion'] != null) {
				if (map['clientVersion'] < MIN_CLIENT_VER)
					ws.add(JSON.encode({'error':'Your client is outdated. Please reload the page.'}));
				return;
			}

			if (map["channel"] == "Global Chat" && (await UserMutes.INSTANCE.userMuted(map["username"]))) {
				// User cannot use global chat
				ws.add(JSON.encode({
					"muted": "true",
					"toastText": "You may not use Global Chat because you are a nuisance to Ur. Please click here to email us if you believe this is an error.",
					"toastClick": "__EMAIL_COU__"
				}));
				return;
			}

			if (map['statusMessage'] == 'pong') {
				KeepAlive.notResponded.remove(ws);
				return;
			} else if (map["statusMessage"] == 'join') {
				//combine the username with the channel name to keep track of the same user in multiple channels
				String userName = map["username"];
				map["statusMessage"] = "true";
				map["message"] = ' joined.';
				String street = map["street"];
				users[userName] = (new Identifier(map["username"], street, map['tsid'], ws));
				users[userName].channelList..add(map['street'])..add("Global Chat");
			} else if (map["statusMessage"] == "changeStreet") {
				List<String> alreadySent = [];
				users.forEach((String username, Identifier id) {
					if (username == map["username"]) {
						id.currentStreet = map["newStreetLabel"];
						id.channelList.remove(map['oldStreetLabel']);
						id.channelList.add(map['newStreetLabel']);
					}
					//others who were on the street with you
					if (!alreadySent.contains(id.username) && id.username != map["username"] &&
					    id.currentStreet == map["oldStreetTsid"]) {
						Map leftForMessage = new Map();
						leftForMessage["statusMessage"] = "leftStreet";
						leftForMessage["username"] = map["username"];
						leftForMessage["streetName"] = map["newStreetLabel"];
						leftForMessage["tsid"] = map["newStreetTsid"];
						leftForMessage["message"] = " has left for ";
						leftForMessage["channel"] = "Local Chat";
						if (users[id.username] != null) {
							users[id.username].webSocket.add(JSON.encode(leftForMessage));
						}
						alreadySent.add(id.username);
					}
					//others who are on the new street
					if (id.currentStreet == map["newStreet"] &&
					    id.username != map["username"])	{
						toast("${map["username"]} is here!", id.webSocket);
					}
				});
				return;
			} else if (map["statusMessage"] == "list") {
				List<String> userList = new List();
				users.forEach((String username, Identifier userId) {
					if (map["channel"] == "Local Chat" && userId.currentStreet == map["street"]) {
						userList.add(userId.username);
					} else if (map["channel"] != "Local Chat") {
						userList.add(userId.username);
					}
				});
				map["users"] = userList;
				map["message"] = "Users in this channel: ";
				users[map["username"]]?.webSocket?.add(JSON.encode(map));
				return;
			}

			sendAll(JSON.encode(map));
		}
		catch (err, st) {
			log("Error handling chat: $err\n$st");
		}
	}

	static void sendAll(String sendMessage) {
		users.forEach((String username, Identifier id) {
			id.webSocket.add(sendMessage);
		});
	}
}

@app.Group("/userMutes")
class UserMutes {
	/**
	 * Check if a user is muted;

		UserMutes.INSTANCE.usermuted("...username...")

		GET => /userMutes/check?username=...username...

	 * Mute a user:

		UserMutes.INSTANCE.mute("...username...")

		POST <Content-Type: application/json> {"username": "...username...", "token": "...redstone token..."} => /userMutes/mute/

	 * Unmute a user:

		UserMutes.INSTANCE.unmute("...username...")

		POST <Content-Type: application/json> {"username": "...username...", "token": "...redstone token..."} => /userMutes/unmute/
	 */

	static UserMutes INSTANCE = new UserMutes();

	static Map<String, bool> _userMutedCache = {};

	@app.Route("/check")
	Future<bool> userMuted(@app.QueryParam("username") String username) async {
		if (_userMutedCache[username] == null) {
			await _checkDatabase(username);
		}

		return _userMutedCache[username];
	}

	@app.Route("/mute", methods: const [app.POST])
	Future<bool> mute(@app.Body(app.JSON) Map data) async {
		String username = data["username"];
		if (username == null || data["token"] != redstoneToken) {
			return false;
		}

		_userMutedCache[username] = true;

		PostgreSql dbConn = await dbManager.getConnection();
		try {
			return (await dbConn.execute(
				"UPDATE users SET chat_disabled = true WHERE username = @username",
				{"username": username}) == 1);
		} catch (e) {
			log("Error muting chat for user $username: $e");
			return false;
		} finally {
			dbManager.closeConnection(dbConn);
		}
	}

	@app.Route("/unmute", methods: const [app.POST])
	Future<bool> unmute(@app.Body(app.JSON) Map data) async {
		String username = data["username"];
		if (username == null || data["token"] != redstoneToken) {
			return false;
		}

		_userMutedCache[username] = false;

		PostgreSql dbConn = await dbManager.getConnection();
		try {
			return (await dbConn.execute(
				"UPDATE users SET chat_disabled = false WHERE username = @username",
				{"username": username}) == 1);
		} catch (e) {
			log("Error unmuting chat for user $username: $e");
			return false;
		} finally {
			dbManager.closeConnection(dbConn);
		}
	}

	static Future<bool> _checkDatabase(String username) async {
		bool result = false;

		PostgreSql dbConn = await dbManager.getConnection();

		try {
			result = (
				await dbConn.query(
					"SELECT chat_disabled FROM users WHERE username = @username", User,
					{"username": username})
			).first.chat_disabled;

			_userMutedCache[username] = result;

			return result;
		} catch (e) {
			log("Error getting chat muted status for user $username: $e");
			return false;
		} finally {
			dbManager.closeConnection(dbConn);
		}
	}
}
