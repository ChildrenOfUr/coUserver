library street_update_handler;

import 'dart:io';
import 'dart:async';
import 'dart:convert';
import 'dart:math';
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
		String dir = serverDir.path;
		String filePath, fileText;

		try {
			// load items
			filePath = path.join(dir, 'lib', 'entities', 'items', 'json');
			await Future.forEach(await new Directory(filePath).list().toList(), (File cat) async {
				fileText = await cat.readAsString();
				JSON.decode(fileText).forEach((String name, Map itemMap) {
					itemMap['itemType'] = name;
					items[name] = decode(itemMap, Item);
				});
			});
			Log.verbose('Items loaded');

			// load recipes
			filePath = path.join(
				dir,
				'lib',
				'entities',
				'items',
				'actions',
				'recipes',
				'json');
			await Future.forEach(await new Directory(filePath).list().toList(), (File tool) async {
				fileText = await tool.readAsString();
				JSON.decode(fileText).forEach((Map recipeMap) {
					RecipeBook.recipes.add(decode(recipeMap, Recipe));
				});
			});
			Log.verbose('Recipes loaded');

			// load vendor types
			filePath = path.join(dir, 'lib', 'entities', 'npcs', 'vendors', 'vendors.json');
			fileText = await new File(filePath).readAsString();
			JSON.decode(fileText).forEach((String street, String type) {
				vendorTypes[street] = type;
			});
			Log.verbose('Vendor types loaded');

			// load stats given for eating/drinking
			filePath = path.join(dir, 'lib', 'entities', 'items', 'actions', 'consume.json');
			fileText = await new File(filePath).readAsString();
			JSON.decode(fileText).forEach((String item, Map award) {
				try {
					items[item].consumeValues = award;
				} catch (e) {
					Log.error('Error setting consume values for $item to $award', e);
				}
			});
			Log.verbose('Consume values loaded');

			// Load achievements
			Achievement.load();
			Log.verbose('Achievements loaded');

			// Load skills
			SkillManager.loadSkills();
			Log.verbose('Skills loaded');

			// Load buffs
			BuffManager.loadBuffs();
			Log.verbose('Buffs loaded');
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
				street.npcs.addAll(_pendingNpcs[streetName] ?? {});
				_pendingNpcs[streetName]?.clear();

				// Remove queued NPCs
				new Map.from(street.npcs).forEach((String id, NPC npc) {
					if (npc.removing) {
						street.npcs.remove(id);
					}
				});

				street.npcs.forEach((String id, NPC npc) {
					npc.update();
					if(npc.previousX != npc.x ||
					   npc.previousY != npc.y) {
						moveMap['npcs'].add(npc.getMap());
					}
				});

				street.occupants.forEach((String username, WebSocket socket) async {
					if (socket != null) {
						String email = await User.getEmailFromUsername(username);
						//we need to modify the actions list for the npcs and plants
						//to take into account the players skills so that the costs are right
						await Future.forEach(moveMap['npcs'], (Map npcMove) async {
							NPC npc = street.npcs[npcMove['id']];
							if (npc != null) {
								npcMove['actions'] = encode(await npc.customizeActions(email));
							}
						});
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

	static Future simulateStreets() async {
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

				street.occupants.forEach((String username, WebSocket socket) async {
					if (socket != null) {
						String email = await User.getEmailFromUsername(username);
						//we need to modify the actions list for the npcs and plants
						//to take into account the players skills so that the costs are right
						await Future.forEach(updates['npcs'], (Map npcMap) async {
							NPC npc = street.npcs[npcMap['id']];
							if (npc != null) {
								npcMap['actions'] = encode(await npc.customizeActions(email));
							}
						});
						await Future.forEach(updates['plants'], (Map plantMap) async {
							Plant plant = street.plants[plantMap['id']];
							if (plant != null) {
								plantMap['actions'] = encode(await plant.customizeActions(email));
							}
						});

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
