library street_update_handler;

import 'dart:io';
import 'dart:async';
import 'dart:convert';
import 'dart:math' hide log;
import 'dart:mirrors';

import 'package:coUserver/common/util.dart';
import 'package:coUserver/achievements/achievements.dart';
import 'package:coUserver/streets/player_update_handler.dart';
import 'package:coUserver/streets/street.dart';
import 'package:coUserver/entities/entity.dart';
import 'package:coUserver/endpoints/inventory_new.dart';
import 'package:coUserver/endpoints/metabolics/metabolics.dart';
import 'package:coUserver/entities/items/item.dart';
import 'package:coUserver/common/identifier.dart';
import 'package:coUserver/endpoints/changeusername.dart';
import 'package:coUserver/skills/skillsmanager.dart';
import 'package:coUserver/buffs/buffmanager.dart';
import 'package:coUserver/entities/items/actions/recipes/recipe.dart';
import 'package:coUserver/API_KEYS.dart';
import 'package:coUserver/common/user.dart';
import 'package:coUserver/common/mapdata/mapdata.dart';

import 'package:path/path.dart' as path;
import 'package:redstone_mapper/mapper.dart';
import 'package:redstone/redstone.dart' as app;
import 'package:redstone_mapper_pg/manager.dart';

//handle player update events
class StreetUpdateHandler {
	static Duration simulateDuration = new Duration(seconds: 1);
	static Duration npcUpdateDuration = new Duration(milliseconds: 1000~/NPC.updateFps);
	static Map<String, Street> streets = new Map();
	static Map<String, WebSocket> userSockets = new Map();
	static Timer simulateTimer = new Timer.periodic(simulateDuration, (Timer timer) => simulateStreets());
	static Timer updateTimer = new Timer.periodic(npcUpdateDuration, (Timer timer) => updateNpcs());

	static loadItems() async {
		try {
			String directory;
			//this happens when running unit tests
			if (Platform.script.data != null) {
				directory = Directory.current.path;
			} else {
				directory = Platform.script.toFilePath();
				directory = directory.substring(0, directory.lastIndexOf(Platform.pathSeparator));
			}

			directory = directory.replaceAll('coUserver/test', 'coUserver');

			// load items
			String filePath = path.join(directory, 'lib', 'entities', 'items', 'json');
			await new Directory(filePath).list().forEach((File category) async {
				JSON.decode(await category.readAsString()).forEach((String name, Map itemMap) {
					itemMap['itemType'] = name;
					items[name] = decode(itemMap, Item);
				});
			});

			// load recipes
			filePath = path.join(
				directory,
				'lib',
				'entities',
				'items',
				'actions',
				'recipes',
				'json');
			await new Directory(filePath).list().forEach((File tool) async {
				JSON.decode(await tool.readAsString()).forEach((Map recipeMap) {
					RecipeBook.recipes.add(decode(recipeMap, Recipe));
				});
			});

			// load vendor types
			filePath = path.join(directory, 'lib', 'entities', 'npcs', 'vendors', 'vendors.json');
			String fileText = await new File(filePath).readAsString();
			JSON.decode(fileText).forEach((String street, String type) {
				vendorTypes[street] = type;
			});

			// load stats given for eating/drinking
			filePath = path.join(directory, 'lib', 'entities', 'items', 'actions', 'consume.json');
			fileText = await new File(filePath).readAsString();
			JSON.decode(fileText).forEach((String item, Map award) {
				items[item].consumeValues = award;
			});

			// Load achievements
			Achievement.load();

			// Load skills
			SkillManager.loadSkills();

			// Load buffs
			BuffManager.loadBuffs();
		} catch (e, st) {
			Log.error('Problem loading items', e, st);
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

	static void updateNpcs() {
		streets.forEach((String streetName, Street street) {
			if (street.occupants.length > 0) {
				Map<String, dynamic> moveMap = {};
				moveMap['npcMove'] = 'true';
				moveMap['npcs'] = [];
				street.npcs.forEach((String id, NPC npc) {
					npc.update();
					if(npc.previousX != npc.x ||
					   npc.previousY != npc.y) {
						moveMap['npcs'].add(npc.getMap());
					}
				});

				street.occupants.forEach((String username, WebSocket socket) {
					if (socket != null) {
						try {
							socket.add(JSON.encode(moveMap));
						} catch (e, st) {
							Log.error('Error sending moveMap $moveMap to $username', e, st);
						}
					}
				});
			}
		});
	}

	static void simulateStreets() {
		List<String> toRemove = [];
		streets.forEach((String streetName, Street street) {
			//only simulate street with someone on it
			if (street.occupants.length > 0) {
				//reset the street's expiry if it has one
				street.expires = null;

				street.plants.forEach((String id, Plant plant) => plant.update());
				street.quoins.forEach((String id, Quoin quoin) => quoin.update());
				street.npcs.forEach((String id, NPC npc) => npc.update());

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

				street.occupants.forEach((String username, WebSocket socket) {
					if (socket != null) {
						socket.add(JSON.encode(updates));
					}
				});
			}
			else {
				toRemove.add(street.label);
			}
		});

		//clean up memory of streets where no players currently are
		//in the future, I imagine this is where the street would be saved to the database
		//you're right past me, this is where i'm doing it
		Future.forEach(toRemove, (String label) async {
			Street street = streets[label];
			DateTime now = new DateTime.now();
			if (street.expires?.isBefore(now) ?? false) {
				await street.persistState();
				street.expires = null;
				streets.remove(label);
				Log.verbose('Unloaded street $label from memory');
			} else if (street.expires == null) {
				street.expires = now.add(new Duration(seconds:5));
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
			String streetName = map["streetName"];
			String username = map["username"];
			String email = map['email'];

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
					String type = map['type'].replaceAll(" entity", "");
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
		Street street;
		try {
			street = new Street(streetName, tsid);
			streets[streetName] = street;
			await street.loadItems();
			await street.loadJson();
			street.load.complete(true);
			Log.verbose('Loaded street $streetName ($tsid) into memory');
		} catch (e, st) {
			Log.error('Could not load street $tsid', e, st);
			street?.load?.complete(false);
			throw e;
		}
	}

	static void _callGlobalMethod(Map map, WebSocket userSocket, String email) {
		ClassMirror classMirror = findClassMirror('StreetUpdateHandler');
		Map<Symbol, dynamic> arguments = {#userSocket:userSocket, #email:email};
		if (map['arguments'] != null) {
			(map['arguments'] as Map).forEach((key, value) => arguments[new Symbol(key)] = value);
		}
		classMirror.invoke(new Symbol(map['callMethod']), [], arguments);
	}

	static Future<bool> teleport({WebSocket userSocket, String email, String tsid, bool energyFree: false}) async {
		if(!energyFree) {
			Metabolics m = await getMetabolics(email: email);
			if (m.user_id == -1 || m.energy < 50) {
				return false;
			} else {
				m.energy -= 50;
				int result = await setMetabolics(m);
				if (result < 1) {
					return false;
				}
			}
		}

		Map map = {}
			..["gotoStreet"] = "true"
			..["tsid"] = tsid;
		userSocket.add(JSON.encode(map));

		return true;
	}

	static Future<bool> moveItem({WebSocket userSocket, String email,
	int fromIndex: -1,
	int fromBagIndex: -1,
	int toBagIndex: -1,
	int toIndex: -1}) async {
		if (fromIndex == -1 || toIndex == -1) {
			//something's wrong
			return false;
		}

		return await InventoryV2.moveItem(email, fromIndex: fromIndex, toIndex: toIndex,
			                                  fromBagIndex: fromBagIndex, toBagIndex: toBagIndex);
	}

	static Future writeNote({WebSocket userSocket, String email, Map noteData}) async {
		Map newNote = await NoteManager.addFromClient(noteData);
		userSocket.add(JSON.encode({
			                           "note_response": newNote
		                           }));

		InventoryV2.decreaseDurability(email, NoteManager.tool_item);
	}

	static Future feed2({
		WebSocket userSocket, String email, String itemType, int count, int slot, int subSlot}) async =>
		BabyAnimals.feed2(
			userSocket: userSocket, email: email,
			itemType: itemType, count: count, slot: slot, subSlot: subSlot);

	static Future changeClientUsername({
		WebSocket userSocket, String email, String oldUsername, String newUsername}) async =>
		changeUsername(oldUsername: oldUsername, newUsername: newUsername, userSocket: userSocket);
}

@app.Route('/teleport', methods: const[app.POST])
Future teleportUser(@app.Body(app.FORM) Map data) async {
	String token = data['token'];
	String channel = data['channel_id'];
	String text = data['text'];

	if(token != slackTeleportToken) {
		return 'YOU SHALL NOT PASS';
	}

	if (channel != 'G0277NLQS') {
		return 'Run this from the administration group';
	}

	if(text.split(', ').length != 2) {
		return "U dun mesed ↑ (formatting was probably wrong)";
	}

	String streetName = text.substring(text.lastIndexOf(', ') + 2);
	String username = text.replaceAll(', $streetName', '');

	Map streetMap = mapdata_streets[streetName];
	String tsid;
	if(streetMap != null) {
		tsid = streetMap['tsid'];
	} else {
		//Go to Cebarkul if no other street name was passed to the command
		tsid = mapdata_streets['Cebarkul']['tsid'];
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
