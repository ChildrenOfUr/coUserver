part of coUserver;

class Shrine extends NPC
{
	String description;

	Shrine(String id, int x, int y) : super(id,x,y)
	{
		actionTime = 0;

		actions..add({"action":"donate",
					  "timeRequired":actionTime,
					  "enabled":false,
					  "actionWord":""})
			   ..add({"action":"check favor",
					  "timeRequired":actionTime,
					  "enabled":false,
					  "actionWord":""});
	}

	@override
	void update()
	{

	}

	donate({WebSocket userSocket, Map map})
	{
		//increase the user's favor in the database here

		//then take the item(s) from them
		Map takeMap = {}
			..['takeItem'] = "true"
			..['name'] = map['dropItem']['name']
			..['count'] = map['count'];
		userSocket.add(JSON.encode(takeMap));
	}

	checkFavor({WebSocket userSocket}){}
}