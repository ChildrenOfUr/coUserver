part of coUserver;

class SkillRequirements {
	@Field()
	Map<String, int> requiredSkillLevels = {};
}

class ItemRequirements {
	@Field()
	List<String> any = [];
	@Field()
	Map<String, int> all = {};
}

class Action {
	@Field()
	String name;
	@Field()
	String description = '';
	@Field()
	int timeRequired = 0;
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

	Action dropAction = new Action.withName('drop')
		..description = "Drop this item on the ground.";
	Action pickupAction = new Action.withName('pickup')
		..description = "Put this item in your bags.";

	Random rand = new Random();

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
			actions.insert(0, dropAction);
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
				result.insert(0, encode(dropAction));
			}
			return result;
		}
	}

	Future<bool> trySetMetabolics(String identity, {int energy:0, int mood:0, int img:0, int currants:0}) async {
		Metabolics m = new Metabolics();
		if(identity.contains("@")) {
			m = await getMetabolics(email:identity);
		} else {
			m = await getMetabolics(username:identity);
		}
		m.energy += energy;
		m.mood += mood;
		m.img += img;
		m.lifetime_img += img;
		m.currants += currants;
		int result = await setMetabolics(m);
		if(result < 1) {
			return false;
		}
		return true;
	}

	// //// //
	// Food //
	// //// //

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
		StatBuffer.incrementStat("foodsConsumed", 1);
		return consume(streetName:streetName, map:map, userSocket:userSocket, email:email);
	}

	Future drink({String streetName, Map map, WebSocket userSocket, String email}) async {
		StatBuffer.incrementStat("drinksConsumed", 1);
		return consume(streetName:streetName, map:map, userSocket:userSocket, email:email);
	}

	// //////////// //
	// Focusing Orb //
	// //////////// //

	Future<bool> levitate({String streetName, Map map, WebSocket userSocket, String email}) async {
		return false;
	}

	Future<bool> focusEnergy({String streetName, Map map, WebSocket userSocket, String email}) async {
		return await trySetMetabolics(email, energy:10);
	}

	Future<bool> focusMood({String streetName, Map map, WebSocket userSocket, String email}) async {
		return await trySetMetabolics(email, mood:10);
	}

	Future<bool> radiate({String streetName, Map map, WebSocket userSocket, String email}) async {
		List<String> users = [];
		List<Identifier> ids = ChatHandler.users.values.where((Identifier id) => id.channelList.contains(streetName)).toList();
		ids.forEach((Identifier id) => users.add(id.username));
		int numUsersOnStreet = users.length;
		if(numUsersOnStreet == 1) {
			return false;
		} else {
			int amt;
			if(numUsersOnStreet < 10) {
				amt = 20;
			} else if(numUsersOnStreet > 10 && numUsersOnStreet < 20) {
				amt = 40;
			} else {
				amt = 60;
			}

			amt = (amt / numUsersOnStreet).ceil();
			users.forEach((String username) {
				trySetMetabolics(username, mood: amt, energy: amt, img: amt);
			});
			return true;
		}
	}

	Future<bool> meditate({String streetName, Map map, WebSocket userSocket, String email}) async {
		return await trySetMetabolics(email, energy:5, mood:5, img: 5);
	}

	// ////// //
	// Emblem //
	// ////// //

	Future<bool> caress({String streetName, Map map, WebSocket userSocket, String email}) async {
		int amt = rand.nextInt(10) + 5;
		StatBuffer.incrementStat("emblemsCaressed", 1);
		return await trySetMetabolics(email, mood:amt);
	}

	Future<bool> consider({String streetName, Map map, WebSocket userSocket, String email}) async {
		int amt = rand.nextInt(10) + 5;
		StatBuffer.incrementStat("emblemsConsidered", 1);
		return await trySetMetabolics(email, energy:amt);
	}

	Future<bool> contemplate({String streetName, Map map, WebSocket userSocket, String email}) async {
		int amt = rand.nextInt(10) + 5;
		StatBuffer.incrementStat("emblemsContemplated", 1);
		return await trySetMetabolics(email, img:amt);
	}

	Future<bool> iconize({String streetName, Map map, WebSocket userSocket, String email}) async {
		int amt = rand.nextInt(10) + 5;
		String emblemType = itemType;
		String iconType = "icon_of_" + itemType.substring(10);
		bool success1 = await takeItemFromUser(userSocket, email, emblemType, 11);
		if (!success1) {
			return false;
		}
		int success2 = await addItemToUser(userSocket, email, items[iconType].getMap(), 1, item_id);
		if (success2 == 0) {
			return false;
		} else {
			StatBuffer.incrementStat("emblemsIconized", 11);
			StatBuffer.incrementStat("iconsCreated", 1);
			return true;
		}
	}

	// //// //
	// Icon //
	// //// //

	Future<bool> tithe({String streetName, Map map, WebSocket userSocket, String email}) async {
		StatBuffer.incrementStat("iconsTithed", 11);
		return await trySetMetabolics(email, currants:-100);
	}

	Future<bool> ruminate({String streetName, Map map, WebSocket userSocket, String email}) async {
		StatBuffer.incrementStat("iconsRuminated", 11);
		return await trySetMetabolics(email, mood:50);
	}

	Future<bool> revere({String streetName, Map map, WebSocket userSocket, String email}) async {
		StatBuffer.incrementStat("iconsRevered", 11);
		return await trySetMetabolics(email, energy:50);
	}

	Future<bool> reflect({String streetName, Map map, WebSocket userSocket, String email}) async {
		StatBuffer.incrementStat("iconsTithed", 11);
		return await trySetMetabolics(email, img:50);
	}

	// /////////// //
	// Cubimal Box //
	// /////////// //

	Future<bool> takeOutS1Cubi({String streetName, Map map, WebSocket userSocket, String email}) async {
		Map cubis = {
			"17.000": "chick",
			"34.000": "piggy",
			"50.000": "butterfly",
			"58.000": "crab",
			"66.000": "batterfly",
			"74.000": "frog",
			"82.000": "firefly",
			"84.000": "bureaucrat",
			"86.000": "cactus",
			"88.000": "snoconevendor",
			"90.000": "squid",
			"92.000": "juju",
			"93.250": "smuggler",
			"94.500": "deimaginator",
			"95.750": "greeterbot",
			"97.000": "dustbunny",
			"97.500": "gwendolyn",
			"98.000": "unclefriendly",
			"98.500": "helga",
			"99.000": "magicrock",
			"99.500": "yeti",
			"99.750": "rube",
			"100.00": "rook"
		};

		openCubiBox(cubis, 1, streetName:streetName, map:map, userSocket:userSocket, email:email);

		return true;
	}

	Future<bool> takeOutS2Cubi({String streetName, Map map, WebSocket userSocket, String email}) async {
		Map cubis = {
			"14.500": "fox",
			"29.000": "sloth",
			"37.000": "emobear",
			"45.000": "foxranger",
			"54.000": "groddlestreetspirit",
			"61.000": "uraliastreetspirit",
			"69.000": "firebogstreetspirit",
			"77.000": "gnome",
			"81.000": "butler",
			"85.000": "craftybot",
			"89.000": "phantom",
			"93.000": "ilmenskiejones",
			"94.000": "trisor",
			"95.000": "toolvendor",
			"96.000": "mealvendor",
			"97.000": "gardeningtoolsvendor",
			"98.000": "maintenancebot",
			"99.000": "senorfunpickle",
			"99.500": "hellbartender",
			"100.50": "scionofpurple"
		};

		openCubiBox(cubis, 2, streetName:streetName, map:map, userSocket:userSocket, email:email);

		return true;
	}

	Future<bool> openCubiBox(Map cubis, int series, {String streetName, Map map, WebSocket userSocket, String email}) async {
		String cubimal = "cubimal_";
		String box = "cubimal_series_" + series.toString() + "_box";
		num seek = rand.nextInt(10000) / 100;
		for (String cubiChance in cubis.keys) {
			if (seek <= num.parse(cubiChance)) {
				cubimal += cubis[cubiChance];
				break;
			}
		}
		bool success = await takeItemFromUser(userSocket, email, box, 1);
		await addItemToUser(userSocket, email, items[cubimal].getMap(), 1, box);

		return success;
	}

	// //// //
	// Item //
	// //// //

	// ground -> inventory

	void pickup({WebSocket userSocket, String email}) {
		onGround = false;
		Item item = new Item.clone(itemType)
			..onGround = false;
		addItemToUser(userSocket, email, item.getMap(), 1, item_id);
		StatBuffer.incrementStat("itemsPickedup", 1);
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

		StatBuffer.incrementStat("itemsDropped", map['count']);
	}
}