part of coUserver;

//handle player update events
class StreetUpdateHandler
{
	static Map<String, Street> streets = new Map();
	
	StreetUpdateHandler(WebSocket ws)
	{		
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
		
		new Timer.periodic(new Duration(seconds: 1), (Timer timer)
		{
			streets.forEach((String streetName, Street street)
			{
				Iterable nonNull = street.occupants.where((WebSocket socket) => socket != null);
				if(nonNull.length > 0) //only simulate street with someone on it
				{
					street.plants.forEach((Plant plant) => plant.update());
					street.quoins.forEach((String id, Quoin quoin) => quoin.update());
					street.npcs.forEach((NPC npc) => npc.update());
				}
			});
		});
	}
	
	cleanupList(WebSocket ws)
	{
		//find and remove ws from whichever street has it
		streets.forEach((String streetName, Street street)
		{
			street.occupants[street.occupants.indexOf(ws)] = null;
		});
	}
	
	processMessage(WebSocket ws, String message)
	{
		//we should receive 3 kinds of messages - player enters street, player exits street, player interacts with object
		//everything else will be outgoing
		try
		{
			Map map = JSON.decode(message);
			String streetName = map["streetName"];
			
			if(map["remove"] != null)
			{
				if(map["type"] == "quoin")
					streets[streetName].quoins[map["remove"]].setCollected();
				
				streets[streetName].occupants.forEach((WebSocket socket)
				{
					if(socket != null)
						socket.add(JSON.encode(map));
				});
				return;
			}
			
			String username = map["username"];
			if(!streets.containsKey(streetName))
				streets[streetName] = new Street(streetName);
			
			if(map["message"] == "joined")
				streets[streetName].occupants.add(ws);
			else if(map["message"] == "left")
				streets[streetName].occupants.remove(ws);
		}
		catch(error)
		{
			print("Error processing message: $error");
		}
	}
}