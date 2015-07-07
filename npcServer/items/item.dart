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
	String description = '';
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
	List<Action> actions = [];

	Action dropAction = new Action.withName('drop')..description="Drop this item on the ground.";
	Action pickupAction = new Action.withName('pickup')..description="Put this item in your bags.";

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

		bool found = false;
		actions.forEach((Action action) {
			if(action.name == 'drop') {
				found = true;
			}
		});

		if(!found) {
			actions.insert(0,dropAction);
		}
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
			List<Map> result = encode(actions);
			bool found = false;
			actions.forEach((Action action) {
				if(action.name == 'drop') {
					found = true;
				}
			});
			if(!found) {
				result.insert(0,encode(dropAction));
			}
			return result;
		}
	}

	// used for consuming

	Future<bool> trySetMetabolics(String email, {int energy:0, int mood:0, int img:0}) async {
		Metabolics m = await getMetabolics(email:email);
		m.energy += energy;
		m.mood += mood;
		m.img += img;
		int result = await setMetabolics(m);
		if(result < 1) {
			return false;
		}
		return true;
	}

	// takes away item and gives the stats specified in items/actions/consume.json

	Future<bool> consume({String streetName, Map map, WebSocket userSocket, String email}) async {
		bool success = await takeItemFromUser(userSocket, email, map['dropItem']['itemType'], map['count']);
		if(!success) {
			return false;
		}

		int energyAward = consumeValues[map['dropItem']['itemType']]['energy'];
		int moodAward = consumeValues[map['dropItem']['itemType']]['mood'];
		int imgAward = consumeValues[map['dropItem']['itemType']]['img'];

		return await trySetMetabolics(email, energy:energyAward, mood:moodAward, img:imgAward);
	}

	// these two are just aliases to consume because they do the same thing, but are named differently in the item menu

	Future eat({String streetName, Map map, WebSocket userSocket, String email}) async {
		return consume(streetName:streetName, map:map, userSocket:userSocket, email:email);
	}

	Future drink({String streetName, Map map, WebSocket userSocket, String email}) async {
		return consume(streetName:streetName, map:map, userSocket:userSocket, email:email);
	}

	// ground -> inventory

	void pickup({WebSocket userSocket, String email}) {
		onGround = false;
		Item item = new Item.clone(itemType)..onGround = false;
		addItemToUser(userSocket, email, item.getMap(), 1, item_id);
	}

	// inventory -> ground

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