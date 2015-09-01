part of coUserver;

//handle player update events
class StreetUpdateHandler {
	static Map<String, Street> streets = new Map();
	static Timer timer = new Timer.periodic(new Duration(seconds: 1), (Timer timer) => simulateStreets());

	static loadItems() async {
		try {
			String directory = Platform.script.toFilePath();
			directory = directory.substring(0, directory.lastIndexOf('/'));

			// load items
			await new Directory('$directory/npcServer/items/json').list().forEach((File category) async {
				JSON.decode(await category.readAsString()).forEach((String name, Map itemMap) {
					itemMap['itemType'] = name;
					items[name] = decode(itemMap, Item);
				});
			});

			// load recipes
			await new Directory('$directory/npcServer/items/actions/recipes').list().forEach((File tool) async {
				JSON.decode(await tool.readAsString()).forEach((Map recipeMap) {
					RecipeBook.recipes.add(decode(recipeMap, Recipe));
				});
			});

			// load vendor types
			await JSON.decode(await new File('$directory/npcServer/npcs/vendors/vendors.json').readAsString()).forEach((String street, String type) {
				vendorTypes[street] = type;
			});

			// load stats given for eating/drinking
			await JSON.decode(await new File('$directory/npcServer/items/actions/consume.json').readAsString()).forEach((String item, Map award) {
				Item_Consumable.consumeValues[item] = award;
			});

		}
		catch (e) {
			log("Problem loading items: $e");
		}
	}

	static void handle(WebSocket ws) {
		//querying the isActive seems to spark the timer to start
		//otherwise it does not start from the static declaration above
		timer.isActive;

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

	static void simulateStreets() {
		List<String> toRemove = [];
		streets.forEach((String streetName, Street street) {
			Iterable nonNull = street.occupants.where((WebSocket socket) => socket != null);
			//only simulate street with someone on it
			if (nonNull.length > 0) {
				street.plants.forEach((String id, Plant plant) => plant.update());
				street.quoins.forEach((String id, Quoin quoin) => quoin.update());
				street.npcs.forEach((String id, NPC npc) => npc.update());

				Map<String, List> updates = {"label":streetName, "quoins":[], "npcs":[], "plants":[], "doors":[], "groundItems":[]};
				street.quoins.forEach((String id, Quoin quoin) => updates["quoins"].add(quoin.getMap()));
				street.npcs.forEach((String id, NPC npc) => updates["npcs"].add(npc.getMap()));
				street.plants.forEach((String id, Plant plant) => updates["plants"].add(plant.getMap()));
				street.doors.forEach((String id, Door door) => updates["doors"].add(door.getMap()));

				List<String> pickedUpItems = [];
				street.groundItems.forEach((String id, Item item) {
					updates["groundItems"].add(item.getMap());
					//check if item was picked up and if so delete it
					//(after sending it to the client one more time)
					if (item.onGround == false)
						pickedUpItems.add(id);
				});

				pickedUpItems.forEach((String id) => street.groundItems.remove(id));

				street.occupants.forEach((WebSocket socket) {
					if (socket != null)
						socket.add(JSON.encode(updates));
				});
			}
			else
				toRemove.add(street.label);
		});

		//clean up memory of streets where no players currently are
		//in the future, I imagine this is where the street would be saved to the database
		toRemove.forEach((String label) => streets.remove(label));
	}

	static void cleanupList(WebSocket ws) {
		//find and remove ws from whichever street has it
		streets.forEach((String streetName, Street street) {
			int index = street.occupants.indexOf(ws);
			if (index > -1)
				street.occupants.removeAt(index);
		});
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

			//a player has joined or left the street
			if (map["message"] == "joined") {
				//set this player as being on this street
				if (PlayerUpdateHandler.users[username] != null) {
					PlayerUpdateHandler.users[username].tsid = map['tsid'];
				}

				if (map['clientVersion'] != null && map['clientVersion'] < minClientVersion) {
					ws.add(JSON.encode({'error':'version too low'}));
					return;
				}
				else {
					if (!streets.containsKey(streetName)) {
						loadStreet(streetName, map['tsid']);
					}
					//log("${map['username']} joined $streetName");
					streets[streetName].occupants.add(ws);
					getMetabolics(username: username, email: email).then((Metabolics m) {
						MetabolicsEndpoint.addToLocationHistory(username, map["tsid"]);
					});
					if (map['firstConnect']) {
						await InventoryV2.getInventory(email)..fireInventoryAtUser(ws, email);
					}
					return;
				}
			}
			else if (map["message"] == "left") {
				cleanupList(ws);
				return;
			}

			//if the street doesn't yet exist, create it (maybe it got stored back to the datastore)
			if (!streets.containsKey(streetName)) {
				loadStreet(streetName, map['tsid']);
			}

			//the said that they collided with a quion, let's check and credit if true
			if (map["remove"] != null) {
				if (map["type"] == "quoin") {
					//print('remove quoin');
					Quoin touched = streets[streetName].quoins[map["remove"]];
					Identifier player = PlayerUpdateHandler.users[username];
					if (player == null) {
						log('(street_update_handler) Could not find player $username to collect quoin');
					} else if (touched != null && !touched.collected) {
						num xDiff = (touched.x - player.currentX).abs();
						//num yDiff = (touched.y - player.currentY).abs();

						if (xDiff < 130) {
							await MetabolicsEndpoint.addQuoin(touched, username);
							//print('added');
						}
						else {
							MetabolicsEndpoint.denyQuoin(touched, username);
							log('denied quoin to $username');
						}
					}
					else if (touched == null) {
						log('(street_update_handler) Could not collect quoin ${map['remove']} for player $username - quoin is null');
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
						var entity = entityMap[map['id']];
						//log("user $username calling ${map['callMethod']} on ${entity.id} in $streetName (${map['tsid']})");
						InstanceMirror entityMirror = reflect(entity);
						Map<Symbol, dynamic> arguments = {#userSocket:ws, #email:email};
						if (map['arguments'] != null) {
							(map['arguments'] as Map).forEach((key, value) => arguments[new Symbol(key)] = value);
						}
						entityMirror.invoke(new Symbol(methodName), [], arguments);
					} else {
						//check if it's an item and not an entity
						InstanceMirror instanceMirror = reflect(items[type]);
						Map<Symbol, dynamic> arguments = {#userSocket:ws, #email:email};
						arguments[#streetName] = map['streetName'];
						arguments[#map] = map['arguments'];
						instanceMirror.invoke(new Symbol(methodName), [], arguments);
					}

					return;
				}
			}
		}
		catch (error, st) {
			log("Error processing message (street_update_handler): $error\n$st");
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

	static void loadStreet(String streetName, String tsid) {
		streets[streetName] = new Street(streetName, tsid);
		log("Loaded $streetName ($tsid) into memory.");
	}

	static void _callGlobalMethod(Map map, WebSocket userSocket, String email) {
		ClassMirror classMirror = findClassMirror('StreetUpdateHandler');
		Map<Symbol, dynamic> arguments = {#userSocket:userSocket, #email:email};
		if (map['arguments'] != null) {
			(map['arguments'] as Map).forEach((key, value) => arguments[new Symbol(key)] = value);
		}
		classMirror.invoke(new Symbol(map['callMethod']), [], arguments);
	}

	static Future<bool> teleport({WebSocket userSocket, String email, String tsid}) async {
		Metabolics m = await getMetabolics(email:email);
		if (m.user_id == -1 || m.energy < 50) {
			return false;
		} else {
			m.energy -= 50;
			int result = await setMetabolics(m);
			if (result < 1) {
				return false;
			}
		}

		Map map = {}
			..["gotoStreet"] = "true"
			..["tsid"] = tsid;
		userSocket.add(JSON.encode(map));

		return true;
	}
}