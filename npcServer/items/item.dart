part of coUserver;

class Item {
	@Field()
	String category;
	@Field()
	String iconUrl;
	@Field()
	String spriteUrl;
	@Field()
	String toolAnimation;
	@Field()
	String name;
	@Field()
	String description;
	@Field()
	String item_id;
	@Field()
	String itemType;
	@Field()
	int user_id;
	@Field()
	int price;
	@Field()
	int stacksTo;
	@Field()
	int iconNum = 4;
	@Field()
	int durability;
	@Field()
	num x;
	@Field()
	num y;
	@Field()
	bool onGround = false;
	@Field()
	bool isContainer = false;
	@Field()
	List<Map> actions = [{"action":"drop",
		"timeRequired":0,
		"enabled":true,
		"actionWord":""}];
	List<Map> groundActions = [{"action":"pickup",
		"enabled":true,
		"timeRequired":0,
		"actionWord":""}];

	Map getMap() {
		return {"iconUrl":iconUrl,
			"spriteUrl":spriteUrl,
			"name":name,
			"itemType":itemType,
			"category":category,
			"isContainer":isContainer,
			"description":description,
			"price":price,
			"stacksTo":stacksTo,
			"iconNum":iconNum,
			"id":item_id,
			"onGround":onGround,
			"x":x,
			"y":y,
			"actions":onGround ? groundActions : actions,
			"tool_animation": toolAnimation,
			"durability": durability};
	}

	void pickup({WebSocket userSocket, String email}) {
		onGround = false;
		addItemToUser(userSocket, email, getMap(), 1, item_id);
	}

	Future drop({WebSocket userSocket, Map map, String streetName, String email}) async {
		bool success = await takeItemFromUser(userSocket, email, map['dropItem']['itemType'], map['count']);
		if(!success) {
			return;
		}

		num x = map['x'], y = map['y'];
		String id = "i" + createId(x, y, map['dropItem']['itemType'], map['tsid']);
		this.item_id = id;
		onGround = true;
		this.x = x;
		this.y = y;
		StreetUpdateHandler.streets[streetName].groundItems[id] = this;
		//log("dropped item: ${getMap()}");
	}
}