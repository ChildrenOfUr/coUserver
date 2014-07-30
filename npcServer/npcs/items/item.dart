part of coUserver;

abstract class Item
{
	String iconUrl, spriteUrl, animationUrl, name, description, id;
	int price, stacksTo, iconNum = 4;
	num x,y;
	bool onGround = false;
	List<Map> actions = [];
	
	Map getMap()
	{
		return {"iconUrl":iconUrl,
				"spriteUrl":spriteUrl,
				"animationUrl":animationUrl,
				"name":name,
				"description":description,
				"price":price,
				"stacksTo":stacksTo,
				"iconNum":iconNum,
				"id":id,
				"onGround":onGround,
				"x":x,
				"y":y,
				"actions":actions};
	}
	
	void pickup({WebSocket userSocket})
	{
		Map map = {};
		map['giveItem'] = "true";
		map['item'] = getMap();
		map['num'] = 1;
		map['fromObject'] = id;
		userSocket.add(JSON.encode(map));
		onGround = false;
	}
}