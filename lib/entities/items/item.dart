library item;

import 'dart:async';
import 'dart:math';
import 'dart:convert';
import 'dart:io';

import 'package:coUserver/achievements/achievements.dart';
import 'package:coUserver/achievements/stats.dart';
import 'package:coUserver/buffs/buffmanager.dart';
import 'package:coUserver/common/identifier.dart';
import 'package:coUserver/common/mapdata/mapdata.dart';
import 'package:coUserver/common/user.dart';
import 'package:coUserver/common/util.dart';
import 'package:coUserver/endpoints/chat_handler.dart';
import 'package:coUserver/endpoints/inventory_new.dart';
import 'package:coUserver/endpoints/metabolics/metabolics.dart';
import 'package:coUserver/entities/entity.dart';
import 'package:coUserver/entities/items/actions/recipes/recipe.dart';
import 'package:coUserver/quests/quest.dart';
import 'package:coUserver/skills/skillsmanager.dart';
import 'package:coUserver/streets/player_update_handler.dart';
import 'package:coUserver/streets/street_update_handler.dart';
import 'package:coUserver/streets/street.dart';

import 'package:redstone_mapper_pg/manager.dart';
import 'package:redstone_mapper/mapper.dart';
import 'package:redstone/redstone.dart' as app;

part 'actions/action.dart';

part 'actions/itemgroups/baby_animals.dart';

part 'actions/itemgroups/consume.dart';

part 'actions/itemgroups/cubimals.dart';

part 'actions/itemgroups/emblems-icons.dart';

part 'actions/itemgroups/milk-butter-cheese.dart';

part 'actions/itemgroups/orb.dart';

part 'actions/itemgroups/piggy_plop.dart';

part 'actions/itemgroups/potions.dart';

part 'actions/itemgroups/quill.dart';

part 'actions/itemgroups/recipe-tool.dart';

part 'actions/note.dart';

part 'item_user.dart';

Map<String, Item> items = {};

class Item extends Object
	with
		MetabolicsChange,
		BabyAnimals,
		Consumable,
		Cubimal,
		CubimalBox,
		Emblem,
		FocusingOrb,
		Icon,
		MilkButterCheese,
		PiggyPlop,
		Potions,
		Quill,
		RecipeTool {
	// Discounts, stored as itemType: part paid out of 1 (eg. 0.8 for 20% off)
	static Map<String, num> discountedItems = {};

	// Properties

	@Field() String category;
	@Field() String iconUrl;
	@Field() String spriteUrl;
	@Field() String brokenUrl;
	@Field() String toolAnimation;
	@Field() String name;
	@Field() String description;
	@Field() String itemType;
	@Field() String item_id;
	@Field() int price;
	@Field() int stacksTo;
	@Field() int iconNum = 4;
	@Field() int durability;
	@Field() int subSlots = 0;
	@Field() num x, y;
	@Field() bool onGround = false;
	@Field() bool isContainer = false;
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

	num get discount => discountedItems[itemType] ?? 1;

	// Constructors

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

	// Exporters

	Map getMap() => {
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

	@override
	String toString() => "An item of type $itemType with metadata $metadata";

	// Getters

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
		// Allow an empty slot
		if (testItem == null && itemType == null) {
			return true;
		}

		if (itemType != null && itemType.isEmpty) {
			// Bags except empty item types (this is an empty slot)
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

	// Generic item actions

	Future<bool> openQuest({String streetName, Map map, WebSocket userSocket, String email, String username}) async {
		InventoryV2 inv = await getInventory(email);
		Item itemInSlot = await inv.getItemInSlot(map['slot'], map['subSlot'], email);
		Quest quest = decode(JSON.decode(itemInSlot.metadata['questData']), Quest);

		// Install the quest in the map of available quests
		quests[quest.id] = quest;
		QuestEndpoint.questLogCache[email].offerQuest(
			quest.id, fromItem: true, slot: map['slot'], subSlot: map['subSlot']
			);

		return true;
	}

	// Client: ground -> inventory
	Future pickup({WebSocket userSocket, String email, String username, int count: 1}) async {
		onGround = false;

		Item item = new Item.clone(itemType)
			..onGround = false
			..metadata = this.metadata;

		await InventoryV2.addItemToUser(email, item.getMap(), count, item_id);
		StatManager.add(email, Stat.items_picked_up, increment: count);
	}

	// Client: inventory -> ground
	Future drop({WebSocket userSocket, Map map, String streetName, String email, String username}) async {
		Item droppedItem = await InventoryV2.takeItemFromUser(
			email, map['slot'], map['subSlot'], map['count']
			);

		Identifier playerId = PlayerUpdateHandler.users[username];

		if (droppedItem == null|| playerId == null) {
			return;
		}

		for (int i = 0; i < map['count']; i++) {
			droppedItem.putItemOnGround(playerId.currentX+40, playerId.currentY, streetName);
		}

		StatManager.add(email, Stat.items_dropped, increment: map['count']);
	}

	// Place the item in the street
	void putItemOnGround(num x, num y, String streetName, {String id}) {
		Street street = StreetUpdateHandler.streets[streetName];
		if (street == null) {
			return;
		}

		if (id == null) {
			String randString = new Random().nextInt(1000).toString();
			id = "i" + createId(x, y, itemType, streetName + randString);
		}

		Item item = new Item.clone(itemType)
			..x = x
			..y = y
			..item_id = id
			..onGround = true
			..metadata = this.metadata;
		item.y = street.getYFromGround(item.x, item.y, 1, 1);

		street.groundItems[id] = item;
	}
}
