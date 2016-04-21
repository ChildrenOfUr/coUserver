library item;

import 'dart:async';
import 'dart:math' hide log;
import 'dart:convert';
import 'dart:io';

import 'package:coUserver/inventory_new.dart';
import 'package:coUserver/endpoints/metabolics/metabolics.dart';
import 'package:coUserver/common/util.dart';
import 'package:coUserver/common/user.dart';
import 'package:coUserver/quests/quest.dart';
import 'package:coUserver/common/stat_buffer.dart';
import 'package:coUserver/street_update_handler.dart';
import 'package:coUserver/entities/items/actions/recipes/recipe.dart';
import 'package:coUserver/achievements/achievements.dart';
import 'package:coUserver/buffs/buffmanager.dart';
import 'package:coUserver/skills/skillsmanager.dart';
import 'package:coUserver/chat_handler.dart';
import 'package:coUserver/common/identifier.dart';
import 'package:coUserver/street.dart';

import 'package:redstone_mapper/mapper.dart';
import 'package:redstone_mapper_pg/manager.dart';
import 'package:redstone/redstone.dart' as app;

part 'item_user.dart';
part 'actions/action.dart';
part 'actions/note.dart';
part 'actions/itemgroups/consume.dart';
part 'actions/itemgroups/cubimals.dart';
part 'actions/itemgroups/emblems.dart';
part 'actions/itemgroups/milk-butter-cheese.dart';
part 'actions/itemgroups/orb.dart';
part 'actions/itemgroups/piggy_plop.dart';

class Item extends Object with MetabolicsChange, Consumable, Cubimal, CubimalBox, Emblem {
	/// Discounts, stored as itemType: part paid out of 1 (eg. 0.8 for 20% off)
	static Map<String, num> discountedItems = {
		"knife_and_board": 0.75
	};

	@Field() String category, iconUrl, spriteUrl, brokenUrl, toolAnimation, name, description, itemType,
		item_id;
	@Field() int price,
		stacksTo,
		iconNum = 4,
		durability,
		subSlots = 0;
	@Field() num x, y;
	@Field() bool onGround = false,
		isContainer = false;
	@Field() List<String> subSlotFilter;
	@Field() List<Action> actions = [];
	@Field() Map<String, int> consumeValues = {};
	@Field() Map<String, String> metadata = {};

	Action dropAction = new Action.withName('drop')
		..description = "Drop this item on the ground."
		..multiEnabled = true;
	Action pickupAction = new Action.withName('pickup')
		..description = "Put this item in your bags."
		..multiEnabled = true;

	num get discount {
		if (discountedItems[itemType] != null) {
			return discountedItems[itemType];
		} else {
			return 1;
		}
	}

	@override
	String toString() {
		return 'An item of type $itemType with metadata $metadata';
	}

	Item();

	Item.clone(this.itemType) {
		Item model = items[itemType];
		category = model.category;
		iconUrl = model.iconUrl;
		spriteUrl = model.spriteUrl;
		brokenUrl = model.brokenUrl;
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
		consumeValues = model.consumeValues;

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
			"iconUrl": iconUrl,
			"spriteUrl": spriteUrl,
			"brokenUrl": brokenUrl,
			"name": name,
			"itemType": itemType,
			"category": category,
			"isContainer": isContainer,
			"description": description,
			"price": price,
			"stacksTo": stacksTo,
			"iconNum": iconNum,
			"id": item_id,
			"onGround": onGround,
			"x": x,
			"y": y,
			"actions": actionList,
			"tool_animation": toolAnimation,
			"durability": durability,
			"subSlots": subSlots,
			"metadata": metadata,
			"discount": discount,
			"consumeValues": consumeValues
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

	bool filterAllows({Item testItem, String itemType}) {
		//allow an empty slot
		if(testItem == null && itemType == null) {
			return true;
		}

		if (itemType != null && itemType.isEmpty) {
			//bags except empty item types (this is an empty slot)
			return true;
		}

		if (testItem == null) {
			testItem = items[itemType];
		}

		if (subSlotFilter.length == 0) {
			return !testItem.isContainer;
		} else {
			return subSlotFilter.contains(testItem.itemType);
		}
	}

	// Client-Sent Actions //////////////////////////////////////////////////////////////////////////

	// ////////////////////// //
	// Used by multiple items //
	// ////////////////////// //

	Future<bool> sniff({String streetName, Map map, WebSocket userSocket, String email, String username}) async {
		InventoryV2 inv = await getInventory(email);
		Item itemInSlot = await inv.getItemInSlot(map['slot'], map['subSlot'], email);
		if (itemInSlot.itemType == "butterfly_milk") {
			return await Item_Cheese.sniff(userSocket, email);
		} else if (itemInSlot.itemType == "very_very_stinky_cheese") {
			return await Item_Milk.sniff(userSocket, username);
		} else if (itemInSlot.itemType == 'piggy_plop') {
			return await PiggyPlop.sniff(userSocket);
		} else {
			return false;
		}
	}

	Future<bool> openQuest({String streetName, Map map, WebSocket userSocket, String email, String username}) async {
		InventoryV2 inv = await getInventory(email);
		Item itemInSlot = await inv.getItemInSlot(map['slot'], map['subSlot'], email);
		Quest quest = decode(JSON.decode(itemInSlot.metadata['questData']), Quest);

		//install the quest in the map of available quests
		quests[quest.id] = quest;
		QuestEndpoint.questLogCache[email].offerQuest(
			quest.id, fromItem: true, slot: map['slot'], subSlot: map['subSlot']);
		return true;
	}

	// ////////////// //
	// Butterfly Milk //
	// ////////////// //

	Future<bool> shakeBottle({String streetName, Map map, WebSocket userSocket, String email, String username}) async {
		return await Item_Milk.shakeBottle(userSocket, username, email);
	}

	// //////////////// //
	// Butterfly Butter //
	// //////////////// //

	Future<bool> compress({String streetName, Map map, WebSocket userSocket, String email, String username}) async {
		return await Item_Butter.compress(userSocket, email);
	}

	// ////// //
	// Cheese //
	// ////// //

	Future<bool> age({String streetName, Map map, WebSocket userSocket, String email, String username}) async {
		return await Item_Cheese.age(map, userSocket, email);
	}

	Future<bool> prod({String streetName, Map map, WebSocket userSocket, String email, String username}) async {
		return await Item_Cheese.prod(userSocket, email);
	}

	Future<bool> sniffCheese(String streetName, Map map, WebSocket userSocket, String email,
		String username) async {
		return await Item_Cheese.sniff(userSocket, email);
	}

	// //////////////// //
	// Butterfly Lotion //
	// //////////////// //

	Future<bool> taste({String streetName, Map map, WebSocket userSocket, String email, String username}) async {
		InventoryV2 inv = await getInventory(email);
		Item itemInSlot = await inv.getItemInSlot(map['slot'], map['subSlot'], email);
		if(itemInSlot.itemType == 'butterfly_lotion') {
			toast("That didn't taste as good as it smells. -5 mood", userSocket);
			return await ItemUser.trySetMetabolics(username, mood: -5);
		} else if(itemInSlot.itemType == 'piggy_plop') {
			return PiggyPlop.taste(userSocket);
		} else {
			return false;
		}
	}

	// //////////// //
	// Focusing Orb //
	// //////////// //

	Future<bool> levitate({String streetName, Map map, WebSocket userSocket, String email, String username}) async {
		return await Item_Orb.levitate(userSocket);
	}

	Future<bool> focusEnergy({String streetName, Map map, WebSocket userSocket, String email, String username}) async {
		return await Item_Orb.focusEnergy(userSocket, username);
	}

	Future<bool> focusMood({String streetName, Map map, WebSocket userSocket, String email, String username}) async {
		return await Item_Orb.focusMood(userSocket, username);
	}

	Future<bool> radiate({String streetName, Map map, WebSocket userSocket, String email, String username}) async {
		return await Item_Orb.radiate(streetName, username);
	}

	Future<bool> meditate({String streetName, Map map, WebSocket userSocket, String email, String username}) async {
		return await Item_Orb.meditate(userSocket, username);
	}

	Future<bool> examine({String streetName, Map map, WebSocket userSocket, String email, String username}) async {
		return await PiggyPlop.examine(userSocket, email, map);
	}

	// //// //
	// Icon //
	// //// //

	Future<bool> tithe({String streetName, Map map, WebSocket userSocket, String email, String username}) async {
		StatBuffer.incrementStat("iconsTithed", 11);
		return await ItemUser.trySetMetabolics(username, currants: -100);
	}

	Future<bool> ruminate({String streetName, Map map, WebSocket userSocket, String email, String username}) async {
		StatBuffer.incrementStat("iconsRuminated", 11);
		return await ItemUser.trySetMetabolics(username, mood: 50);
	}

	Future<bool> revere({String streetName, Map map, WebSocket userSocket, String email, String username}) async {
		StatBuffer.incrementStat("iconsRevered", 11);
		return await ItemUser.trySetMetabolics(username, energy: 50);
	}

	Future<bool> reflect({String streetName, Map map, WebSocket userSocket, String email, String username}) async {
		StatBuffer.incrementStat("iconsTithed", 11);
		return await ItemUser.trySetMetabolics(username, img: 50);
	}

	// //// //
	// Item //
	// //// //

	// ground -> inventory

	Future pickup({WebSocket userSocket, String email, String username}) async {
		onGround = false;
		Item item = new Item.clone(itemType)
			..onGround = false
			..metadata = this.metadata;
		await InventoryV2.addItemToUser(email, item.getMap(), 1, item_id);
		StatBuffer.incrementStat("itemsPickedup", 1);
	}

	// inventory -> ground

	Future drop({WebSocket userSocket, Map map, String streetName, String email, String username}) async {
		Item droppedItem = await InventoryV2.takeItemFromUser(
			email, map['slot'], map['subSlot'], map['count']);
		if (droppedItem == null) {
			return;
		}

		for(int i=0; i<map['count']; i++) {
			droppedItem.putItemOnGround(map['x'], map['y'], streetName);
		}

		StatBuffer.incrementStat("itemsDropped", map['count']);
	}

	int getYFromGround(String streetName) {
		int returnY = y;
		Street street = StreetUpdateHandler.streets[streetName];
		if (street == null) {
			return returnY;
		}

		CollisionPlatform platform = street.getBestPlatform(y, x, 1, 1);
		if (platform != null) {
			num goingTo = y + street.groundY;
			num slope = (platform.end.y - platform.start.y) / (platform.end.x - platform.start.x);
			num yInt = platform.start.y - slope * platform.start.x;
			num lineY = slope * x + yInt;

			if (goingTo >= lineY) {
				returnY = lineY - street.groundY;
			}
		}

		return returnY ~/ 1;
	}

	void putItemOnGround(num x, num y, String streetName) {
		String randString = new Random().nextInt(1000).toString();
		String id = "i" + createId(x, y, itemType, streetName + randString);
		Item item = new Item.clone(itemType)
			..x = x
			..y = y
			..item_id = id
			..onGround = true
			..metadata = this.metadata;
		item.y = item.getYFromGround(streetName);

		StreetUpdateHandler.streets[streetName].groundItems[id] = item;
	}

	// /////// //
	// Potions //
	// /////// //

	Future growYourself({WebSocket userSocket, Map map, String streetName, String email, String username}) async {
		await BuffManager.removeFromUser("shrink", email, userSocket);
		BuffManager.addToUser("grow", email, userSocket);
	}

	Future shrinkYourself({WebSocket userSocket, Map map, String streetName, String email, String username}) async {
		await BuffManager.removeFromUser("grow", email, userSocket);
		BuffManager.addToUser("shrink", email, userSocket);
	}

	// ///// //
	// Quill //
	// ///// //

	Future writeNote({WebSocket userSocket, Map map, String streetName, String email, String username}) async {
		userSocket.add(JSON.encode({
			"note_write": true
		}));
	}

	Future readNote({WebSocket userSocket, Map map, String streetName, String email, String username}) async {
		userSocket.add(JSON.encode({
			"note_read": map["itemdata"]["note_id"]
		}));
	}

	// /////// //
	// Recipes //
	// /////// //

	// Alchemical Tongs
	Future alchemize({String streetName, Map map, WebSocket userSocket, String email, String username}) async {
		return Recipe.useItem(map, userSocket, email);
	}

	// Awesome Pot
	Future cook({String streetName, Map map, WebSocket userSocket, String email, String username}) async {
		return Recipe.useItem(map, userSocket, email);
	}

	// Beaker
	// Test Tube
	Future stir({String streetName, Map map, WebSocket userSocket, String email, String username}) async {
		return Recipe.useItem(map, userSocket, email);
	}

	// Bean Seasoner
	// Egg Seasoner
	Future season({String streetName, Map map, WebSocket userSocket, String email, String username}) async {
		return Recipe.useItem(map, userSocket, email);
	}

	// Blender
	Future blend({String streetName, Map map, WebSocket userSocket, String email, String username}) async {
		return Recipe.useItem(map, userSocket, email);
	}

	// Bubble Tuner
	Future tuneBubbles({String streetName, Map map, WebSocket userSocket, String email, String username}) async {
		return Recipe.useItem(map, userSocket, email);
	}

	// Cauldron
	Future brew({String streetName, Map map, WebSocket userSocket, String email, String username}) async {
		return Recipe.useItem(map, userSocket, email);
	}

	// Cocktail Shaker
	Future shake({String streetName, Map map, WebSocket userSocket, String email, String username}) async {
		return Recipe.useItem(map, userSocket, email);
	}

	// Construction Tool
	Future construct({String streetName, Map map, WebSocket userSocket, String email, String username}) async {
		return Recipe.useItem(map, userSocket, email);
	}

	// Famous Pugilist Grill
	Future grill({String streetName, Map map, WebSocket userSocket, String email, String username}) async {
		return Recipe.useItem(map, userSocket, email);
	}

	// Fruit Changing Machine
	Future convertFruit({String streetName, Map map, WebSocket userSocket, String email, String username}) async {
		return Recipe.useItem(map, userSocket, email);
	}

	// Gassifier
	Future convertGas({String streetName, Map map, WebSocket userSocket, String email, String username}) async {
		return Recipe.useItem(map, userSocket, email);
	}

	// Grinders
	Future crush({String streetName, Map map, WebSocket userSocket, String email, String username}) async {
		return Recipe.useItem(map, userSocket, email);
	}

	// Frying Pan
	Future fry({String streetName, Map map, WebSocket userSocket, String email, String username}) async {
		return Recipe.useItem(map, userSocket, email);
	}

	// Knife and Board
	Future chop({String streetName, Map map, WebSocket userSocket, String email, String username}) async {
		return Recipe.useItem(map, userSocket, email);
	}

	// Loomer
	Future loom({String streetName, Map map, WebSocket userSocket, String email, String username}) async {
		return Recipe.useItem(map, userSocket, email);
	}

	// Saucepan
	Future simmer({String streetName, Map map, WebSocket userSocket, String email, String username}) async {
		return Recipe.useItem(map, userSocket, email);
	}

	// Smelter
	Future smelt({String streetName, Map map, WebSocket userSocket, String email, String username}) async {
		return Recipe.useItem(map, userSocket, email);
	}

	// Spice Mill
	Future mill({String streetName, Map map, WebSocket userSocket, String email, String username}) async {
		return Recipe.useItem(map, userSocket, email);
	}

	// Spindles
	Future spin({String streetName, Map map, WebSocket userSocket, String email, String username}) async {
		return Recipe.useItem(map, userSocket, email);
	}

	// Tincturing Kit
	Future tincture({String streetName, Map map, WebSocket userSocket, String email, String username}) async {
		return Recipe.useItem(map, userSocket, email);
	}

	// Tinkertool
	Future tinker({String streetName, Map map, WebSocket userSocket, String email, String username}) async {
		return Recipe.useItem(map, userSocket, email);
	}
}