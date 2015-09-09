part of coUserver;

class Item {
	@Field() String category, iconUrl, spriteUrl, toolAnimation, name, description, itemType, item_id;
	@Field() int price, stacksTo, iconNum = 4, durability, durabilityUsed = 0, subSlots = 0;
	@Field() num x, y;
	@Field() bool onGround = false, isContainer = false;
	@Field() List<String> subSlotFilter;
	@Field() List<Action> actions = [];
	@Field() Map<String, dynamic> metadata = {};

	Action dropAction = new Action.withName('drop')
		..description = "Drop this item on the ground.";
	Action pickupAction = new Action.withName('pickup')
		..description = "Put this item in your bags.";

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
		subSlots = model.subSlots;
		subSlotFilter = model.subSlotFilter;
		metadata = model.metadata;
		actions = model.actions;

		bool found = false;
		actions.forEach((Action action) {
			if (action.name == 'drop') {
				found = true;
			}
		});

		if (!found) {
			actions.insert(0, dropAction);
		}
	}

	Map getMap() {
		return {
			"iconUrl":iconUrl,
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
			"durability": durability,
			"metadata": metadata
		};
	}

	List<Map> get actionList {
		if (onGround) {
			return [encode(pickupAction)];
		} else {
			List<Map> result = encode(actions);
			bool found = false;
			actions.forEach((Action action) {
				if (action.name == 'drop') {
					found = true;
				}
			});
			if (!found) {
				result.insert(0, encode(dropAction));
			}
			return result;
		}
	}

	// Client-Sent Actions //////////////////////////////////////////////////////////////////////////

	// ////////////////////// //
	// Used by multiple items //
	// ////////////////////// //

	Future<bool> sniff({String streetName, Map map, WebSocket userSocket, String email}) async {
		if (map["dropItem"]["itemType"] == "butterfly_milk") {
			return await Item_Cheese.sniff(userSocket, email);
		} else if (map["dropItem"]["itemType"] == "very_very_stinky_cheese") {
			return await Item_Milk.sniff(userSocket, email);
		} else {
			return false;
		}
	}

	// ////////////// //
	// Butterfly Milk //
	// ////////////// //

	Future<bool> shakeBottle({String streetName, Map map, WebSocket userSocket, String email}) async {
		return await Item_Milk.shakeBottle(userSocket, email);
	}

	// //////////////// //
	// Butterfly Butter //
	// //////////////// //

	Future<bool> compress({String streetName, Map map, WebSocket userSocket, String email}) async {
		return await Item_Butter.compress(userSocket, email);
	}

	// ////// //
	// Cheese //
	// ////// //

	Future<bool> age({String streetName, Map map, WebSocket userSocket, String email}) async {
		return await Item_Cheese.age(map, userSocket, email);
	}

	Future<bool> prod({String streetName, Map map, WebSocket userSocket, String email}) async {
		return await Item_Cheese.prod(userSocket, email);
	}

	Future<bool> sniffCheese(String streetName, Map map, WebSocket userSocket, String email) async {
		return await Item_Cheese.sniff(userSocket, email);
	}

	// //////////////// //
	// Butterfly Lotion //
	// //////////////// //

	Future<bool> taste({String streetName, Map map, WebSocket userSocket, String email}) async {
		toast("That didn't taste as good as it smells. -5 mood", userSocket);
		return await ItemUser.trySetMetabolics(email, mood:-5);
	}

	// /////// //
	// Cubimal //
	// /////// //

	Future<bool> race({String streetName, Map map, WebSocket userSocket, String email}) async {
		return await Item_Cubimal.race(streetName, map, userSocket, email);
	}

	Future<bool> setFree({String streetName, Map map, WebSocket userSocket, String email}) async {
		return await Item_Cubimal.setFree(map, userSocket, email);
	}

	// /////////// //
	// Cubimal Box //
	// /////////// //

	Future<bool> takeOutCubimal({String streetName, Map map, WebSocket userSocket, String email}) async {
		return Item_CubimalBox.takeOutCubimal(map, userSocket, email);
	}

	// ////// //
	// Emblem //
	// ////// //

	Future<bool> caress({String streetName, Map map, WebSocket userSocket, String email}) async {
		return await Item_Emblem.caress(userSocket, email);
	}

	Future<bool> consider({String streetName, Map map, WebSocket userSocket, String email}) async {
		return await Item_Emblem.consider(userSocket, email);
	}

	Future<bool> contemplate({String streetName, Map map, WebSocket userSocket, String email}) async {
		return await Item_Emblem.contemplate(userSocket, email);
	}

	Future<bool> iconize({String streetName, Map map, WebSocket userSocket, String email}) async {
		return await Item_Emblem.iconize(map, userSocket, email);
	}

	// //////////// //
	// Focusing Orb //
	// //////////// //

	Future<bool> levitate({String streetName, Map map, WebSocket userSocket, String email}) async {
		return await Item_Orb.levitate(userSocket);
	}

	Future<bool> focusEnergy({String streetName, Map map, WebSocket userSocket, String email}) async {
		return await Item_Orb.focusEnergy(userSocket, email);
	}

	Future<bool> focusMood({String streetName, Map map, WebSocket userSocket, String email}) async {
		return await Item_Orb.focusMood(userSocket, email);
	}

	Future<bool> radiate({String streetName, Map map, WebSocket userSocket, String email}) async {
		return await Item_Orb.radiate(streetName);
	}

	Future<bool> meditate({String streetName, Map map, WebSocket userSocket, String email}) async {
		return await Item_Orb.meditate(userSocket, email);
	}

	// //// //
	// Food //
	// //// //

	// takes away item and gives the stats specified in items/actions/consume.json

	Future<bool> consume({String streetName, Map map, WebSocket userSocket, String email}) async {
		return await Item_Consumable.consume(map, userSocket, email);
	}

	// these two are just aliases to consume because they do the same thing, but are named differently in the item menu

	Future eat({String streetName, Map map, WebSocket userSocket, String email}) async {
		return await Item_Consumable.consume(map, userSocket, email);
	}

	Future drink({String streetName, Map map, WebSocket userSocket, String email}) async {
		return await Item_Consumable.consume(map, userSocket, email);
	}

	// //// //
	// Icon //
	// //// //

	Future<bool> tithe({String streetName, Map map, WebSocket userSocket, String email}) async {
		StatBuffer.incrementStat("iconsTithed", 11);
		return await ItemUser.trySetMetabolics(email, currants:-100);
	}

	Future<bool> ruminate({String streetName, Map map, WebSocket userSocket, String email}) async {
		StatBuffer.incrementStat("iconsRuminated", 11);
		return await ItemUser.trySetMetabolics(email, mood:50);
	}

	Future<bool> revere({String streetName, Map map, WebSocket userSocket, String email}) async {
		StatBuffer.incrementStat("iconsRevered", 11);
		return await ItemUser.trySetMetabolics(email, energy:50);
	}

	Future<bool> reflect({String streetName, Map map, WebSocket userSocket, String email}) async {
		StatBuffer.incrementStat("iconsTithed", 11);
		return await ItemUser.trySetMetabolics(email, img:50);
	}

	// //// //
	// Item //
	// //// //

	// ground -> inventory

	void pickup({WebSocket userSocket, String email}) {
		onGround = false;
		Item item = new Item.clone(itemType)
			..onGround = false;
		InventoryV2.addItemToUser(userSocket, email, item.getMap(), 1, item_id);
		StatBuffer.incrementStat("itemsPickedup", 1);
	}

	// inventory -> ground

	Future drop({WebSocket userSocket, Map map, String streetName, String email}) async {
		Item droppedItem = jsonx.decode(map['dropItem'], type:Item);
		bool success = (await InventoryV2.takeItemFromUser(userSocket, email, itemType, map['count']) == map['count']);
		if (!success) {
			return;
		}

		String id = "i" + createId(x, y, itemType, map['tsid']);
		Item item = new Item.clone(itemType)
			..x = map['x']
			..y = map['y']
			..item_id = id
			..onGround = true
			..metadata = droppedItem.metadata;

		StreetUpdateHandler.streets[streetName].groundItems[id] = item;

		StatBuffer.incrementStat("itemsDropped", map['count']);
	}

	// /////// //
	// Recipes //
	// /////// //

	// Alchemical Tongs
	Future alchemize({String streetName, Map map, WebSocket userSocket, String email}) async {
		return Recipe.useItem(map, userSocket);
	}

	// Awesome Pot
	Future cook({String streetName, Map map, WebSocket userSocket, String email}) async {
		return Recipe.useItem(map, userSocket);
	}

	// Beaker
	// Test Tube
	Future stir({String streetName, Map map, WebSocket userSocket, String email}) async {
		return Recipe.useItem(map, userSocket);
	}

	// Bean Seasoner
	// Egg Seasoner
	Future season({String streetName, Map map, WebSocket userSocket, String email}) async {
		return Recipe.useItem(map, userSocket);
	}

	// Blender
	Future blend({String streetName, Map map, WebSocket userSocket, String email}) async {
		return Recipe.useItem(map, userSocket);
	}

	// Bubble Tuner
	Future tuneBubbles({String streetName, Map map, WebSocket userSocket, String email}) async {
		return Recipe.useItem(map, userSocket);
	}

	// Cauldron
	Future brew({String streetName, Map map, WebSocket userSocket, String email}) async {
		return Recipe.useItem(map, userSocket);
	}

	// Cocktail Shaker
	Future shake({String streetName, Map map, WebSocket userSocket, String email}) async {
		return Recipe.useItem(map, userSocket);
	}

	// Construction Tool
	Future construct({String streetName, Map map, WebSocket userSocket, String email}) async {
		return Recipe.useItem(map, userSocket);
	}

	// Famous Pugilist Grill
	Future grill({String streetName, Map map, WebSocket userSocket, String email}) async {
		return Recipe.useItem(map, userSocket);
	}

	// Fruit Changing Machine
	// Gassifier
	Future convert({String streetName, Map map, WebSocket userSocket, String email}) async {
		return Recipe.useItem(map, userSocket);
	}

	// Grinders
	Future crush({String streetName, Map map, WebSocket userSocket, String email}) async {
		return Recipe.useItem(map, userSocket);
	}

	// Frying Pan
	Future fry({String streetName, Map map, WebSocket userSocket, String email}) async {
		return Recipe.useItem(map, userSocket);
	}

	// Knife and Board
	Future chop({String streetName, Map map, WebSocket userSocket, String email}) async {
		return Recipe.useItem(map, userSocket);
	}

	// Loomer
	Future loom({String streetName, Map map, WebSocket userSocket, String email}) async {
		return Recipe.useItem(map, userSocket);
	}

	// Saucepan
	Future simmer({String streetName, Map map, WebSocket userSocket, String email}) async {
		return Recipe.useItem(map, userSocket);
	}

	// Smelter
	Future smelt({String streetName, Map map, WebSocket userSocket, String email}) async {
		return Recipe.useItem(map, userSocket);
	}

	// Spice Mill
	Future mill({String streetName, Map map, WebSocket userSocket, String email}) async {
		return Recipe.useItem(map, userSocket);
	}

	// Spindles
	Future spin({String streetName, Map map, WebSocket userSocket, String email}) async {
		return Recipe.useItem(map, userSocket);
	}

	// Tincturing Kit
	Future tincture({String streetName, Map map, WebSocket userSocket, String email}) async {
		return Recipe.useItem(map, userSocket);
	}

	// Tinkertool
	Future tinker({String streetName, Map map, WebSocket userSocket, String email}) async {
		return Recipe.useItem(map, userSocket);
	}
}