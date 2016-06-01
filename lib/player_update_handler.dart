library player_update_handler;

import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:coUserver/common/harvest_messages.dart';
import 'package:coUserver/common/identifier.dart';
import 'package:coUserver/common/util.dart';
import 'package:coUserver/endpoints/letters.dart';
import 'package:coUserver/endpoints/login_date_tracker.dart';
import 'package:coUserver/endpoints/stats.dart';
import 'package:coUserver/quests/quest.dart';

//handle player update events
class PlayerUpdateHandler {
	static Map<String, Identifier> users = {};
	static Map<String, int> messagePostCounter = {};

	static void handle(WebSocket ws) {
		ws.listen((message) => processMessage(ws, message),
			onError: (error) => cleanupList(ws),
			onDone: () => cleanupList(ws));
	}

	static void cleanupList(WebSocket ws) {
		String leavingUser;

		users.forEach((String username, Identifier id) {
			if (ws == id.webSocket) {
				id.webSocket = null;
				leavingUser = username;
			}
		});

		Identifier leavingID = users.remove(leavingUser);
		if (leavingID != null) {
			Map map = new Map();
			map["disconnect"] = "true";
			map["username"] = leavingUser;
			map["street"] = leavingID.currentStreet;
			sendAll(map);
		}
	}

	static Future processMessage(WebSocket ws, String message) async {
		try {
			Map map = JSON.decode(message);

			if (map['clientVersion'] != null) {
				if (map['clientVersion'] < minClientVersion) {
					ws.add(JSON.encode({'error':'version too low'}));
				}
			}
			else {
				String username = map["username"];
				String email = map.remove('email');
				if (users[username] != null) {
					//we've had an update for this user before
					String previousStreet = users[username].currentStreet;
					if (previousStreet != map["street"]) {
						//the user must have switched streets

						if (map['street'] == 'Louise Pasture') {
							//offer the race to the forest
							QuestEndpoint.questLogCache[email].offerQuest('Q4');
						}

						messageBus.publish(new RequirementProgress('location_${map['street']}', email));

						map["changeStreet"] = map["street"];
						map['previousStreet'] = previousStreet;
						users[username].currentStreet = map["street"];
						map["letter"] = PLAYER_LETTERS.newPlayerLetter(username);
					} else {
						map["letter"] = PLAYER_LETTERS.getPlayerLetter(username);
					}

					try {
						num prevX = users[username].currentX;
						num prevY = users[username].currentY;
						num currentX = num.parse(map['xy'].split(',')[0]);
						num currentY = num.parse(map['xy'].split(',')[1]);
						num xDiff = (currentX - prevX).abs();
						num yDiff = (currentY - prevY).abs();
						//StatBuffer.incrementStat("stepsTaken", (xDiff + yDiff) / 22);

						int newSteps = ((xDiff + yDiff) / 22).ceil().abs();
						StatManager.add(email, Stat.steps_taken, increment: newSteps, buffer: true);

						if (yDiff > 17) {
							// TODO: do this better
							StatManager.add(email, Stat.jumps, buffer: true);
						}

						users[username].currentX = currentX;
						users[username].currentY = currentY;
						//limit the number of position messages that get broadcast
						//1 message every 5th at 30 messages per second would be 6 per second
						if(messagePostCounter[email] == null || messagePostCounter[email] > 5) {
							messageBus.publish(new PlayerPosition(map['street'], email, currentX, currentY));
							messagePostCounter[email] = 0;
						} else {
							messagePostCounter[email]++;
						}
					} catch (e, st) {
						log("(player_update_handler/processMessage): $e\n$st");
					}
				} else {
					// This user must have just connected
					users[username] = new Identifier(username, map["street"], map['tsid'], ws);
					map["letter"] = PLAYER_LETTERS.newPlayerLetter(username);

					// Update last login date
					LoginDateTracker.update(username);

					try {
						num currentX = num.parse(map['xy'].split(',')[0]);
						num currentY = num.parse(map['xy'].split(',')[1]);
						users[username].currentX = currentX;
						users[username].currentY = currentY;
					} catch (e, st) {
						log("(player_update_handler/processMessage): $e\n$st");
					}
				}

				sendAll(map);
			}
		}
		catch (error, st) {
			log("Error processing message (player_update_handler): $error\n$st");
		}
	}

	static void sendAll(Map map) {
		String data = JSON.encode(map);
		users.forEach((String username, Identifier id) {
			if ((map["street"] == id.currentStreet || map['changeStreet'] != null)) {
				id.webSocket.add(data);
			}
		});
	}
}
