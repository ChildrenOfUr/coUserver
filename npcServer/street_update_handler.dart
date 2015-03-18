part of coUserver;

//handle player update events
class StreetUpdateHandler
{
	static Map<String, Street> streets = new Map();
    static Timer timer = new Timer.periodic(new Duration(seconds: 1), (Timer timer) => simulateStreets());

	static loadItems() async
	{
		try
		{
			String directory = Platform.script.toFilePath();
			directory = directory.substring(0,directory.lastIndexOf('/'));

			File itemsFile = new File('$directory/npcServer/items/items.json');
			Map<String,Map> itemsJson = JSON.decode(await itemsFile.readAsString());
			itemsJson.forEach((String name, Map itemJson) => items[name] = decode(itemJson,Item));
		}
		catch(e)
		{
			log("Problem loading items: $e");
		}
	}

	static void handle(WebSocket ws)
	{
		//querying the isActive seems to spark the timer to start
		//otherwise it does not start from the static declaration above
		timer.isActive;

		ws.listen((message)
		{
			processMessage(ws, message);
	    },
		onError: (error)
		{
			cleanupList(ws);
		},
		onDone: ()
		{
			cleanupList(ws);
		});
	}

	static void simulateStreets()
	{
		List<String> toRemove = [];
		streets.forEach((String streetName, Street street)
		{
			Iterable nonNull = street.occupants.where((WebSocket socket) => socket != null);
			if(nonNull.length > 0) //only simulate street with someone on it
			{
				street.plants.forEach((String id, Plant plant) => plant.update());
				street.quoins.forEach((String id, Quoin quoin) => quoin.update());
				street.npcs.forEach((String id, NPC npc) => npc.update());

				Map<String,List> updates = {"label":streetName,"quoins":[],"npcs":[],"plants":[],"groundItems":[]};
				street.quoins.forEach((String id, Quoin quoin) => updates["quoins"].add(quoin.getMap()));
				street.npcs.forEach((String id, NPC npc) => updates["npcs"].add(npc.getMap()));
				street.plants.forEach((String id, Plant plant) => updates["plants"].add(plant.getMap()));

				List<String> pickedUpItems = [];
				street.groundItems.forEach((String id, Item item)
				{
					updates["groundItems"].add(item.getMap());
					//check if item was picked up and if so delete it
					//(after sending it to the client one more time)
					if(item.onGround == false)
						pickedUpItems.add(id);
				});

				pickedUpItems.forEach((String id) => street.groundItems.remove(id));

				street.occupants.forEach((WebSocket socket)
    			{
    				if(socket != null)
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

	static void cleanupList(WebSocket ws)
	{
		//find and remove ws from whichever street has it
		streets.forEach((String streetName, Street street)
		{
			int index = street.occupants.indexOf(ws);
			if(index > -1)
				street.occupants.removeAt(index);
		});
	}

	static Future processMessage(WebSocket ws, String message)
	{
		//we should receive 3 kinds of messages:
		//player enters street, player exits street, player interacts with object
		//everything else will be outgoing
		try
		{
			Completer c = new Completer();
			Map map = JSON.decode(message);
			String streetName = map["streetName"];
			String username = map["username"];
			String email = map['email'];

			//a player has joined or left the street
			if(map["message"] == "joined")
			{
				//set this player as being on this street
				if(PlayerUpdateHandler.users[username] != null)
					PlayerUpdateHandler.users[username].tsid = map['tsid'];

				if(map['clientVersion'] != null && map['clientVersion'] < minClientVersion)
				{
					ws.add(JSON.encode({'error':'version too low'}));
					c.complete();
				}
				else
				{
					if(!streets.containsKey(streetName))
        				loadStreet(streetName,map['tsid']);
    				//log("${map['username']} joined $streetName");
    				streets[streetName].occupants.add(ws);
    				if(map['firstConnect'])
    				{
    					fireInventoryAtUser(ws,email).then((_) => c.complete());
    				}
    				else
    				{
    					c.complete();
    				}
				}
			}
			else if(map["message"] == "left")
			{
				cleanupList(ws);
				c.complete();
			}

			//if the street doesn't yet exist, create it (maybe it got stored back to the datastore)
			if(!streets.containsKey(streetName))
				loadStreet(streetName,map['tsid']);

			//the said that they collided with a quion, let's check and credit if true
			if(map["remove"] != null)
			{
				if(map["type"] == "quoin")
				{
					Quoin touched = streets[streetName].quoins[map["remove"]];
					Identifier player = PlayerUpdateHandler.users[username];
					if(touched != null && !touched.collected)
					{
						num xDiff = (touched.x - player.currentX).abs();
						num yDiff = (touched.y - player.currentY).abs();

						//print('xDiff: $xDiff, yDiff: $yDiff');
						if(xDiff < 130)// && yDiff < 500)
							MetabolicsEndpoint.addQuoin(touched,username);
						else
							MetabolicsEndpoint.denyQuoin(touched,username);
					}
					else if(touched == null)
						log('(street_update_handler) Could not collect quoin ${map['remove']} for player $username - quoin is null');
				}

				c.complete();
			}

			//callMethod means the player is trying to interact with an entity
			if(map["callMethod"] != null)
			{
				String type = map['type'].replaceAll(" entity","");
				Map entityMap = streets[streetName].entityMaps[type];
				String methodName = normalizeMethodName(map['callMethod']);

				if(entityMap != null && entityMap[map['id']] != null)
				{
					type = map['type'].replaceAll(' ','');
					var entity = entityMap[map['id']];
					//log("user $username calling ${map['callMethod']} on ${entity.id} in $streetName (${map['tsid']})");
					InstanceMirror entityMirror = reflect(entity);
					Map<Symbol,dynamic> arguments = {#userSocket:ws,#email:email};
					if(map['arguments'] != null)
						(map['arguments'] as Map).forEach((key,value) => arguments[new Symbol(key)] = value);
                    entityMirror.invoke(new Symbol(methodName),[],arguments);
				}
				else
				{
					//check if it's an item and not an entity
					InstanceMirror instanceMirror = reflect(items[type]);
					Map<Symbol,dynamic> arguments = {#userSocket:ws,#email:email};
					arguments[#streetName] = map['streetName'];
					arguments[#map] = map['arguments'];
					instanceMirror.invoke(new Symbol(methodName),[],arguments);
				}

				c.complete();
			}

			return c.future;
		}
		catch(error,st)
		{
			log("Error processing message (street_update_handler): $error\n$st");
		}
	}

	static String normalizeMethodName(String name)
	{
		String newName = '';
		List<String> parts = name.split(' ');

		for(int i=0; i<parts.length; i++)
		{
			if(i > 0)
				parts[i] = parts[i].substring(0,1).toUpperCase() + parts[i].substring(1);

			newName += parts[i];
		}

		return newName;
	}

	static void loadStreet(String streetName, String tsid)
	{
		streets[streetName] = new Street(streetName,tsid);
        log("Loaded $streetName ($tsid) into memory.");
	}
}