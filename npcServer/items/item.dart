part of coUserver;
abstract class Item
{
	String iconUrl, spriteUrl, name, description, id;
	int price, stacksTo, iconNum = 4;
	num x,y;
	bool onGround = false, isContainer = false;
	List<Map> actions = [{"action":"drop",
						  "timeRequired":0,
						  "enabled":true,
						  "actionWord":""}];
	List<Map> groundActions = [{"action":"pickup","enabled":true,"timeRequired":0,"actionWord":""}];

	Map getMap()
	{
		return {"iconUrl":iconUrl,
				"spriteUrl":spriteUrl,
				"name":name,
				"isContainer":isContainer,
				"description":description,
				"price":price,
				"stacksTo":stacksTo,
				"iconNum":iconNum,
				"id":id,
				"onGround":onGround,
				"x":x,
				"y":y,
				"actions":onGround?groundActions:actions};
	}

	void pickup({WebSocket userSocket, String username})
	{
		onGround = false;
		addItemToUser(userSocket,username,getMap(),1,id);
	}

	void drop({WebSocket userSocket, Map map, String streetName, String username})
	{
		takeItemFromUser(userSocket,username,map['dropItem']['name'],map['count'])
			.then((int numRows)
			{
				if(numRows < 1)
					return;

				num x = map['x'], y = map['y'];
        		String id = "i" + createId(x,y,map['dropItem']['name'],map['tsid']);
        		this.id = id;
        		onGround = true;
        		this.x = x;
        		this.y = y;
        		StreetUpdateHandler.streets[streetName].groundItems[id] = this;
        		//log("dropped item: ${getMap()}");
			});
	}
}