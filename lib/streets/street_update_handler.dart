library street_update_handler;

import 'dart:io';
import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'dart:mirrors';

import 'package:coUserver/API_KEYS.dart';
import 'package:coUserver/buffs/buffmanager.dart';
import 'package:coUserver/common/identifier.dart';
import 'package:coUserver/common/mapdata/mapdata.dart';
import 'package:coUserver/common/user.dart';
import 'package:coUserver/common/util.dart';
import 'package:coUserver/endpoints/changeusername.dart';
import 'package:coUserver/endpoints/inventory_new.dart';
import 'package:coUserver/endpoints/metabolics/metabolics.dart';
import 'package:coUserver/entities/entity.dart';
import 'package:coUserver/entities/items/item.dart';
import 'package:coUserver/streets/player_update_handler.dart';
import 'package:coUserver/streets/street.dart';

import 'package:redstone_mapper_pg/manager.dart';
import 'package:redstone_mapper/plugin.dart';
import 'package:redstone/redstone.dart' as app;

//handle player update events
class StreetUpdateHandler {
	static Duration simulateDuration = new Duration(seconds: 1);
	static Duration npcUpdateDuration = new Duration(milliseconds: 1000~/NPC.updateFps);
	static Map<String, Street> streets = new Map();
	static Map<String, WebSocket> userSockets = new Map();
	static Timer simulateTimer = new Timer.periodic(simulateDuration, (Timer timer) => simulateStreets());
	static Timer updateTimer = new Timer.periodic(npcUpdateDuration, (Timer timer) => updateNpcs());

	static Future loadItems() async {
		try {
			await Item.loadItems();
			await Item.loadConsumeValues();
			await Vendor.loadVendorTypes();
		} catch (e, st) {
			Log.error('[StreetUpdateHandler] Problem loading objects from JSON', e, st);
		}
	}

	static void handle(WebSocket ws) {
		//querying the isActive seems to spark the timer to start
		//otherwise it does not start from the static declaration above
		simulateTimer.isActive;
		updateTimer.isActive;

		ws.listen((message) {
			processMessage(ws, message);
		},
			          onError: (error) {
				          cleanupList(ws);
			          },
			          onDone: () {
				          cleanupList(ws);
			          });
	}

	static Map<String, Map<String, NPC>> _pendingNpcs = {};

	static void queueNpcAdd(NPC npc, String action) {
		if (_pendingNpcs[npc.streetName] == null) {
			_pendingNpcs[npc.streetName] = {};
		}
		_pendingNpcs[npc.streetName].addAll({npc.id: npc});
	}

	static void updateNpcs() {
		streets.forEach((String streetName, Street street) {
			if (street.occupants.length > 0) {
				Map<String, dynamic> moveMap = {};
				moveMap['npcMove'] = 'true';
				moveMap['npcs'] = [];

				// Add queued NPCs
				if (_pendingNpcs.length > 0) {
					street.npcs.addAll(_pendingNpcs[streetName] ?? {});
					_pendingNpcs[streetName]?.clear();
				}

				street.npcs.forEach((String id, NPC npc) {
					npc.update();
					if(npc.previousX != npc.x ||
					   npc.previousY != npc.y) {
						moveMap['npcs'].add(npc.getMap());
					}
				});

				String moveMapString = JSON.encode(moveMap);
				street.occupants.forEach((String username, WebSocket socket) async {
					if (socket != null) {
						try {
							socket.add(moveMapString);
						} catch (e, st) {
							Log.error('Error sending moveMap $moveMap to $username', e, st);
						}
					}
				});
			}
		});
	}

	static Future simulateStreets() async {
		List<String> toRemove = [];
		streets.forEach((String streetName, Street street) {
			//only simulate street with someone on it
			if (street.occupants.length > 0) {
				//reset the street's expiry if it has one
				street.expires = null;

				DateTime start = new DateTime.now();
				street.plants.forEach((String id, Plant plant) => plant.update());
				street.quoins.forEach((String id, Quoin quoin) => quoin.update());
				street.npcs.forEach((String id, NPC npc) => npc.update());
				print('update time is : ${new DateTime.now().difference(start).inMilliseconds}ms');

				Map<String, dynamic> updates = {
					"label":streetName,
					"quoins":[],
					"npcs":[],
					"plants":[],
					"doors":[],
					"groundItems":[]
				};
				street.quoins.forEach((String id, Quoin quoin) => updates["quoins"].add(quoin.getMap()));
				street.npcs.forEach((String id, NPC npc) => updates["npcs"].add(npc.getMap()));
				street.plants.forEach((String id, Plant plant) => updates["plants"].add(plant.getMap()));
				street.doors.forEach((String id, Door door) => updates["doors"].add(door.getMap()));

				List<String> pickedUpItems = [];
				street.groundItems.forEach((String id, Item item) {
					updates["groundItems"].add(item.getMap());
					//check if item was picked up and if so delete it
					//(after sending it to the client one more time)
					if (item.onGround == false) {
						pickedUpItems.add(id);
					}
				});

				pickedUpItems.forEach((String id) => street.groundItems.remove(id));

				street.occupants.forEach((String username, WebSocket socket) async {
					if (socket != null) {
						socket.add(JSON.encode(updates));
						String email = await User.getEmailFromUsername(username);

						// SAVANNA: Player buff expired?
						if (
							MapData.isSavannaStreet(streetName)
							&& !(await BuffManager.playerHasBuff('nostalgia', email))
						) {
							// Kick them out
							String outTsid = MapData.savannaEscapeTo(streetName);
							teleport(userSocket: socket, email: email,
								tsid: outTsid, energyFree: true);

							// Prevent reentry
							BuffManager.addToUser('nostalgia_over', email, socket);
						}
					}
				});
			} else {
				toRemove.add(street.label);
			}
		});

		//clean up memory of streets where no players currently are
		//in the future, I imagine this is where the street would be saved to the database
		//you're right past me, this is where i'm doing it
		await Future.forEach(toRemove, (String label) async {
			Street street = streets[label];

			//don't try to clean up a street that was already cleaned up
			if (street != null) {
				DateTime now = new DateTime.now();
				if (street.expires?.isBefore(now) ?? false) {
					if (Street.persistLock.containsKey(label)) {
						Log.verbose('Already in the process of persisting <label=$label> so not doing it again');
						return;
					}
					await street.persistState();
					street.expires = null;
					streets.remove(label);
					Log.verbose('Unloaded street <label=$label> from memory');
				} else if (street.expires == null) {
					street.expires = now.add(new Duration(seconds:5));
				}
			}
		});
	}

	static void cleanupList(WebSocket ws) {
		//find and remove ws from whichever street has it
		String userToRemove;
		streets.forEach((String streetName, Street street) {
			street.occupants.forEach((String username, WebSocket socket) {
				if (socket == ws) {
					userToRemove = username;
				}
			});
			if (userToRemove != null) {
				street.occupants.remove(userToRemove);
			}
		});
		userSockets.forEach((String email, WebSocket socket) {
			if (socket == ws) {
				userToRemove = email;
			}
		});
		userSockets.remove(userToRemove);

		// Stop updating their buffs
		BuffManager.stopUpdatingUser(userToRemove);
	}

	static Future processMessage(WebSocket ws, String message) async {
		//we should receive 3 kinds of messages:
		//player enters street, player exits street, player interacts with object
		//everything else will be outgoing
		try {
			Map map = JSON.decode(message);
			String streetName = map["streetName"]?.trim();
			String username = map["username"]?.trim();
			String email = map['email']?.trim();

			//if the street doesn't yet exist, create it (maybe it got stored back to the datastore)
			if (!streets.containsKey(streetName)) {
				await loadStreet(streetName, map['tsid']);
			}

			//a player has joined or left the street
			if (map["message"] == "joined") {
				//set this player as being on this street
				if (PlayerUpdateHandler.users[username] != null) {
					PlayerUpdateHandler.users[username].tsid = map['tsid'];
				}

				if (map['clientVersion'] != null && map['clientVersion'] < MIN_CLIENT_VER) {
					ws.add(JSON.encode({'error':'version too low'}));
					return;
				} else {
					userSockets[email] = ws;

					try {
						streets[streetName].occupants[username] = ws;
					} catch (e) {
						Log.warning('Adding $username to $streetName. Waiting to retry...', e);
						streets[streetName].load.future.then((_) {
							try {
								streets[streetName].occupants[username] = ws;
							} catch (e, st) {
								Log.error('Adding $username to $streetName. Giving up.', e, st);
							}
						});
					}
					getMetabolics(username: username, email: email).then((Metabolics m) {
						MetabolicsEndpoint.addToLocationHistory(username, email, map["tsid"]);
					});
					if (map['firstConnect']) {
						await InventoryV2.fireInventoryAtUser(ws, email);
						MetabolicsEndpoint.updateDeath(PlayerUpdateHandler.users[username], null, true);
						BuffManager.startUpdatingUser(email);
					}

					// SAVANNA: Start tracking time
					if (
						MapData.isSavannaStreet(streetName)
						&& !(await BuffManager.playerHasBuff('nostalgia', email))
					) {
						BuffManager.addToUser('nostalgia', email, ws);

						// TODO: quest https://github.com/tinyspeck/glitch-GameServerJS/blob/f4cf3e3ed540227b0f1fec26dd5273c03b0f9ead/quests/baqala_nostalgia.js

						// TODO: rock https://github.com/tinyspeck/glitch-GameServerJS/blob/f4cf3e3ed540227b0f1fec26dd5273c03b0f9ead/locations/savanna.js
					}

					return;
				}
			}
			else if (map["message"] == "left") {
				cleanupList(ws);
				return;
			}

			//the client said that they collided with a quion, let's check and credit if true
			if (map["remove"] != null) {
				if (map["type"] == 'quoin') {
					Quoin touched = streets[streetName].quoins[map["remove"]];
					Identifier player = PlayerUpdateHandler.users[username];

					if (player == null) {
						Log.warning('Could not find player $username to collect quoin');
					} else if (touched != null && !touched.collected) {
						num xDiff = (touched.x - player.currentX).abs();
						num yDiff = (touched.y - player.currentY).abs();
						num diff = sqrt(pow(xDiff, 2) + pow(yDiff, 2));

						if (diff < 500) {
							await MetabolicsEndpoint.addQuoin(touched, username);
						} else {
							MetabolicsEndpoint.denyQuoin(touched, username);
							Log.verbose('Denied quoin to $username: too far away ($diff)');
						}
					} else if (touched == null) {
						Log.warning('Could not collect quoin ${map['remove']} for player $username: quoin not found');
					}
				}

				return;
			}

			//callMethod means the player is trying to interact with an entity
			if (map["callMethod"] != null) {
				if (map['id'] == 'global_action_monster') {
					_callGlobalMethod(map, ws, email);
					return;
				} else {
					String type = map['type'].replaceAll("entity", "").trim();
					type = type.replaceAll('groundItemGlow','').trim();
					Map entityMap = streets[streetName].entityMaps[type];
					String methodName = normalizeMethodName(map['callMethod']);

					if (entityMap != null && entityMap[map['id']] != null) {
						try {
							var entity = entityMap[map['id']];
							InstanceMirror entityMirror = reflect(entity);
							Map<Symbol, dynamic> arguments = {#userSocket:ws, #email:email};
							if (map['arguments'] != null) {
								(map['arguments'] as Map).forEach((key, value) => arguments[new Symbol(key)] = value);
							}
							entityMirror.invoke(new Symbol(methodName), [], arguments);
						} catch (e, st) {
							Log.error('Could not invoke entity method $methodName', e, st);
						}
					} else {
						//check if it's an item and not an entity
						try {
							InstanceMirror instanceMirror = reflect(items[type]);
							Map<Symbol, dynamic> arguments = {#userSocket:ws, #email:email};
							arguments[#username] = map['username'];
							arguments[#streetName] = map['streetName'];
							arguments[#map] = map['arguments'];
							instanceMirror.invoke(new Symbol(methodName), [], arguments);
						} catch (e, st) {
							Log.error('Could not invoke item method $methodName', e, st);
						}
					}

					return;
				}
			}
		}
		catch (error, st) {
			Log.error('Error processing street update', error, st);
		}
	}

	static String normalizeMethodName(String name) {
		String newName = '';
		List<String> parts = name.split(' ');

		for (int i = 0; i < parts.length; i++) {
			if (i > 0) {
				parts[i] = parts[i].substring(0, 1).toUpperCase() + parts[i].substring(1);
			}

			newName += parts[i];
		}

		return newName;
	}

	static Future loadStreet(String streetName, String tsid) async {
		streetName = streetName.trim();
		Street street;
		try {
			street = new Street(streetName, tsid);
			streets[streetName] = street;
			await street.loadItems();
			await street.loadJson();
			street.load.complete(true);
			Log.verbose('Loaded street <streetName=$streetName> ($tsid) into memory');
		} catch (e, st) {
			Log.error('Could not load street $tsid', e, st);
			street?.load?.complete(false);
			throw e;
		}
	}

	static void _callGlobalMethod(Map map, WebSocket userSocket, String email) {
		ClassMirror classMirror = findClassMirror('StreetUpdateHandler');
		Map<Symbol, dynamic> arguments = {#userSocket:userSocket, #email:email};
		if (map['callMethod'] == 'pickup' && map.containsKey('streetName')) {
			arguments[#streetName] = map['streetName'];
		}
		if (map['arguments'] != null) {
			(map['arguments'] as Map).forEach((key, value) => arguments[new Symbol(key)] = value);
		}
		classMirror.invoke(new Symbol(map['callMethod']), [], arguments);
	}

	static Future<bool> pickup({WebSocket userSocket, String email, String username, List<String> pickupIds, String streetName}) async {
		//check that they're all the same type and that their metadata
		//is all empty or else they aren't eligible for mass pickup
		String type;
		bool allEligible = true;
		for (String id in pickupIds) {
			Item item = StreetUpdateHandler.streets[streetName].groundItems[id];
			if (type == null) {
				type = item.itemType;
			} else if (type != item.itemType) {
				allEligible = false;
				break;
			} else if (item.metadata.isNotEmpty) {
				allEligible = false;
				break;
			}
		}

		if (allEligible) {
			StreetUpdateHandler.streets[streetName].groundItems[pickupIds.first]
				.pickup(email: email, count: pickupIds.length);
			for (String id in pickupIds) {
				StreetUpdateHandler.streets[streetName].groundItems[id].onGround = false;
			}
		}

		return true;
	}

	static Future<bool> teleport({WebSocket userSocket, String email, String tsid, bool energyFree: false}) async {
		if (!energyFree) {
			Metabolics m = await getMetabolics(email: email);
			if (m.user_id == -1 || m.energy < 50) {
				return false;
			} else {
				m.energy -= 50;
				if (!(await setMetabolics(m))) {
					return false;
				}
			}
		}

		userSocket.add(JSON.encode({
			"gotoStreet": "true",
			"tsid": tsid
		}));

		return true;
	}

	static Future<bool> moveItem({WebSocket userSocket, String email, int fromIndex: -1, int fromBagIndex: -1, int toBagIndex: -1, int toIndex: -1}) async {
		if (fromIndex == -1 || toIndex == -1) {
			//something's wrong
			return false;
		}

		return await InventoryV2.moveItem(email,
			fromIndex: fromIndex, toIndex: toIndex, fromBagIndex: fromBagIndex, toBagIndex: toBagIndex);
	}

	static Future writeNote({WebSocket userSocket, String email, Map noteData}) async {
		Map newNote = await NoteManager.addFromClient(noteData);
		userSocket.add(JSON.encode({
			"note_response": newNote
		}));

		InventoryV2.decreaseDurability(email, NoteManager.tool_item);
	}

	static Future feed2({WebSocket userSocket, String email, String itemType, int count, int slot, int subSlot}) async =>
		BabyAnimals.feed2(userSocket: userSocket, email: email,
			itemType: itemType, count: count, slot: slot, subSlot: subSlot);

	static Future changeClientUsername({WebSocket userSocket, String email, String oldUsername, String newUsername}) async =>
		changeUsername(oldUsername: oldUsername, newUsername: newUsername, userSocket: userSocket);

	static void profile({WebSocket userSocket, String email, String username, String player}) {
		userSocket.add(JSON.encode({
			'open_profile': player
		}));
	}

	static void follow({WebSocket userSocket, String email, String username, String player}) {
		userSocket.add(JSON.encode({
			'follow': player
		}));
	}
}

@app.Route('/getActions')
@Encode()
Future<List<Action>> getActions(@app.QueryParam() String email,
                  @app.QueryParam() String id,
                  @app.QueryParam() String label) async {
	if (email == null || id == null || label == null) {
		Log.verbose('<email=$email> tried to get actions for <id=$id> on <label=$label>');
		return [];
	}
	if (StreetUpdateHandler.streets[label] == null) {
		Log.verbose('<label=$label> is not a currently loaded street');
		return [];
	}

	Actionable entity;
	entity = StreetUpdateHandler.streets[label].npcs[id];
	if (entity == null) {
		entity = StreetUpdateHandler.streets[label].plants[id];
	}
	if (entity == null) {
		entity = StreetUpdateHandler.streets[label].doors[id];
	}
	if (entity == null) {
		entity = StreetUpdateHandler.streets[label].groundItems[id];
	}

	if (entity == null) {
		Log.verbose('<id=$id> is not a valid entity on <label=$label>');
		return [];
	}

	return entity.customizeActions(email);
}

@app.Route('/teleport', methods: const[app.POST])
Future teleportUser(@app.Body(app.FORM) Map data) async {
	String token = data['token'];
	String channel = data['channel_id'];
	String text = data['text'];

	if (token != slackTeleportToken) {
		return 'YOU SHALL NOT PASS';
	}

	if (channel != 'G0277NLQS') {
		return 'Run this from the administration group';
	}

	if (text.split(', ').length != 2) {
		return "U dun mesed ↑ (formatting was probably wrong)";
	}

	String streetName = text.substring(text.lastIndexOf(', ') + 2);
	String username = text.replaceAll(', $streetName', '');

	Map streetMap = MapData.streets[streetName];
	String tsid;
	if(streetMap != null) {
		tsid = streetMap['tsid'];
	} else {
		//Go to Cebarkul if no other street name was passed to the command
		tsid = MapData.streets['Cebarkul']['tsid'];
		streetName = "Cebarkul, not $streetName because I can't find it in the map data @klikini";
	}
	tsid = tsidG(tsid);

	String email = await User.getEmailFromUsername(username);
	if(email == null) {
		return 'I could not get a username from <email=$email>';
	}
	WebSocket userSocket = StreetUpdateHandler.userSockets[email];

	//user probably isn't online so edit the database directly
	if(userSocket == null) {
		PostgreSql dbConn = await dbManager.getConnection();
		try {
			String query = "UPDATE metabolics SET current_street = @tsid"
				" WHERE user_id = (SELECT id FROM users WHERE username = @username)";
			await dbConn.execute(query, {'username': username, 'tsid': tsid});
			return '$username will be in $streetName when they next log on';
		} finally {
			dbManager.closeConnection(dbConn);
		}

	} else {
		await StreetUpdateHandler.teleport(userSocket: userSocket, email: email,
											   tsid: tsid, energyFree: true);
		return '$username has been teleported to $streetName';
	}
}
