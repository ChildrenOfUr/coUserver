part of coUserver;

class SkillRequirements {
	@Field()
	Map<String, int> requiredSkillLevels = {};
}

class ItemRequirements {
	@Field()
	List<String> any = [];
	@Field()
	List<String> all = [];
}

class Action {
	@Field()
	String name;
	@Field()
	ItemRequirements itemRequirements = new ItemRequirements();
	@Field()
	SkillRequirements skillRequirements = new SkillRequirements();

	Action();

	Action.withName(this.name);

	@override
	String toString() {
		String returnString = "$name requires any of ${itemRequirements.any}, all of ${itemRequirements.all} and at least ";
		skillRequirements.requiredSkillLevels.forEach((String skill, int level) {
			returnString += "$level level of $skill, ";
		});
		returnString = returnString.substring(0, returnString.length - 1);

		return returnString;
	}
}

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
	List<Action> actions;

	Action dropAction = new Action.withName('drop');
	Action pickupAction = new Action.withName('pickup');

	Item();

	Item.clone(this.itemType) {
		Item model = items[itemType];
		category = model.category;
		iconUrl = model.iconUrl;
		spriteUrl = model.spriteUrl;
		toolAnimation = model.toolAnimation;
		name = model.name;
		description = model.description;
		price = model.price;
		stacksTo = model.stacksTo;
		iconNum = model.iconNum;
		durability = model.durability;
		x = model.x;
		y = model.y;
		isContainer = model.isContainer;
		actions = model.actions;
	}

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
			"actions":actionList,
			"tool_animation": toolAnimation,
			"durability": durability};
	}

	List<Map> get actionList {
		if(onGround) {
			return [encode(pickupAction)];
		} else {
			List result = [encode(dropAction)];
			if(actions != null) {
				result.addAll(encode(actions));
			}
			return result;
		}
	}

	Future eat({String streetName, Map map, WebSocket userSocket, String email}) async {
		bool success = await takeItemFromUser(userSocket, email, map['dropItem']['itemType'], map['count']);
		if(!success) {
			return;
		}
	}

	void pickup({WebSocket userSocket, String email}) {
		onGround = false;
		Item item = new Item.clone(itemType)..onGround = false;
		addItemToUser(userSocket, email, item.getMap(), 1, item_id);
	}

	Future drop({WebSocket userSocket, Map map, String streetName, String email}) async {
		bool success = await takeItemFromUser(userSocket, email, map['dropItem']['itemType'], map['count']);
		if(!success) {
			return;
		}

		String id = "i" + createId(x, y, map['dropItem']['itemType'], map['tsid']);
		Item item = new Item.clone(itemType)
			..x = map['x']
			..y = map['y']
			..item_id = id
			..onGround = true;

		StreetUpdateHandler.streets[streetName].groundItems[id] = item;
	}
}