part of coUserver;

//handle player update events
class StreetUpdateHandler
{
	static Map<String, Street> streets = new Map();
	static Timer timer = new Timer.periodic(new Duration(seconds: 1), (Timer timer) => simulateStreets());
	
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
				
				Map<String,List> updates = {"quoins":[],"npcs":[],"plants":[],"groundItems":[]};
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
				street.occupants[index] = null;
		});
	}
	
	static void processMessage(WebSocket ws, String message)
	{
		//we should receive 3 kinds of messages:
		//player enters street, player exits street, player interacts with object
		//everything else will be outgoing
		try
		{
			Map map = JSON.decode(message);
			String streetName = map["streetName"];
			String username = map["username"];
			
			//a player has joined or left the street
			if(map["message"] == "joined")
			{
				if(!streets.containsKey(streetName))
    				loadStreet(streetName,map['tsid']);
				log("${map['username']} joined $streetName");
				streets[streetName].occupants.add(ws);
				return;
			}
			else if(map["message"] == "left")
			{
				cleanupList(ws);
				return;
			}
			
			//if the street doesn't yet exist, create it (maybe it got stored back to the datastore)
			if(!streets.containsKey(streetName))
				loadStreet(streetName,map['tsid']);
			
			//the player's hit-box collided with a quion
			if(map["remove"] != null)
			{
				if(map["type"] == "quoin")
				{
					if(streets[streetName].quoins[map["remove"]] != null)
						streets[streetName].quoins[map["remove"]].setCollected();
				}
				
				return;
			}
			
			//callMethod means the player is trying to interact with an entity
			if(map["callMethod"] != null)
			{
				String type = map['type'].replaceAll("entity","").trim();
				var entity = streets[streetName].entityMaps[type][map['id']];
				if(entity != null)
				{
					log("user $username calling ${map['callMethod']} on ${entity.id} in $streetName (${map['tsid']})");
					InstanceMirror entityMirror = reflect(entity);
					Map<Symbol,dynamic> arguments = {#userSocket:ws};
					if(map['arguments'] != null)
						(map['arguments'] as Map).forEach((key,value) => arguments[new Symbol(key)] = value);
                    entityMirror.invoke(new Symbol(map['callMethod']),[],arguments);
				}
				
				return;
			}
			
			//the player is dropping an item either manually or they didn't have enough room in their bags
			if(map["dropItem"] != null)
			{
				ClassMirror classMirror = findClassMirror(map['dropItem']['name'].replaceAll(" ",""));
				InstanceMirror instanceMirror = classMirror.newInstance(new Symbol(""), []);
				//if nothing has gone wrong, we should now have an InstanceMirror for the class of
				//item that was dropped, otherwise an error was thrown
				num x = map['x'], y = map['y'];
				String id = "i" + createId(x,y,map['dropItem']['name'],map['tsid']);
				Item item = instanceMirror.reflectee;
				item.actions.add({"action":"pickup","enabled":true,"timeRequired":0,"actionWord":""});
				item.id = id;
				item.onGround = true;
				item.x = x;
				item.y = y;
				streets[streetName].groundItems[id] = item;
				log("dropped item: ${item.getMap()}");
				return;
			}
		}
		catch(error)
		{
			log("Error processing message: $error");
		}
	}
	
	static void loadStreet(String streetName, String tsid)
	{
		streets[streetName] = new Street(streetName,tsid);
        log("Loaded $streetName ($tsid) into memory.");
	}
}