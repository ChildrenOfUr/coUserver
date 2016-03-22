import 'dart:convert';
import 'dart:async';

import 'package:coUserver/inventory_new.dart';
import 'package:coUserver/common/util.dart';
import 'package:coUserver/street_update_handler.dart';
import 'package:coUserver/entities/items/item.dart';

import 'package:test/test.dart';
import 'package:redstone/redstone.dart' as app;
import 'package:redstone_mapper/plugin.dart';
import 'package:redstone_mapper/mapper.dart';
import 'package:redstone_mapper_pg/manager.dart';
import 'package:harvest/harvest.dart' as harvest;
import 'package:jsonx/jsonx.dart' as jsonx;

//some constants
String ut_email = '3fkw19+5xkfumzd5c5e4@sharklasers.com';
int ut_id = 3633;
Type listOfSlots = const jsonx.TypeHelper<List<Slot>>().type;

Future main() async {
	app.addPlugin(getMapperPlugin(dbManager));
	//need to call this before loading the items
	app.redstoneSetUp();

	//ignore messages about quest requirements being completed when not on the quest
	messageBus.deadMessageHandler = (harvest.Message m) {};

	//load game items
	await StreetUpdateHandler.loadItems();

	group('Inventory:', () {
		InventoryV2 inventory;

		setUp(() async {
			await app.redstoneSetUp([#inventory]);

			//load the tester's inventory
			inventory = await getInventory();

			//validate inventory
			await _verifyInventoryIsEmpty(inventory);
		});
		tearDown(() async {
			//make sure to reset the unittester's inventory to blank
			String query = "UPDATE inventories SET inventory_json = '[]' WHERE user_id = $ut_id";
			PostgreSql dbConn = await dbManager.getConnection();
			await dbConn.execute(query);
			dbManager.closeConnection(dbConn);

			//this is causing an issue with getInventory on tests after the first
//			app.redstoneTearDown();
		});

		test('Add Item to Inventory', () async {
			await InventoryV2.addItemToUser(ut_email, items['cherry'].getMap(), 1);

			//verify user has 1 cherry in their inventory
			expect(countItemInInventory(await getInventory(), 'cherry'), equals(1));

			//give user 260 cherries and make sure they get them all (cherries stack to 250)
			await InventoryV2.addItemToUser(ut_email, items['cherry'].getMap(), 260);
			expect(countItemInInventory(await getInventory(), 'cherry'), equals(261));

			//add 9 non-stackable items which should overflow
			expect(await InventoryV2.addItemToUser(ut_email, items['bigger_bag'].getMap(), 9), equals(8));
			expect(countItemInInventory(await getInventory(), 'bigger_bag'), equals(8));

			//add a new item which should go into the bags (split across 2 bags)
			await InventoryV2.addItemToUser(ut_email, items['bean'].getMap(), 4001);
			expect(countItemInInventory(await getInventory(), 'bean'), equals(4001));
		});

		test('Take item from Inventory (specified slot)', () async {
			//load up an inventory (try adding all items at once to verify locking works)
			List<Future> addList = [];
			addList.add(InventoryV2.addItemToUser(ut_email, items['cherry'].getMap(), 1));
			addList.add(InventoryV2.addItemToUser(ut_email, items['bigger_bag'].getMap(), 1));
			addList.add(InventoryV2.addItemToUser(ut_email, items['bigger_blue_bag'].getMap(), 1));
			addList.add(InventoryV2.addItemToUser(ut_email, items['bean'].getMap(), 1));
			await Future.wait(addList);

			InventoryV2 inventory = await getInventory();

			//make sure the items are in the same order as added
			expect((await inventory.getItemInSlot(0, -1, ut_email)).itemType, equals('cherry'));
			expect((await inventory.getItemInSlot(1, -1, ut_email)).itemType, equals('bigger_bag'));
			expect((await inventory.getItemInSlot(2, -1, ut_email)).itemType, equals('bigger_blue_bag'));
			expect((await inventory.getItemInSlot(3, -1, ut_email)).itemType, equals('bean'));

			//move it inside the bag
			expect(await InventoryV2.moveItem(ut_email, fromIndex: 3, fromBagIndex: -1,
				                                  toIndex: 1, toBagIndex: 0), isTrue);

			//verify the item was moved
			inventory = await getInventory();
			expect((await inventory.getItemInSlot(3, -1, ut_email)), isNull);
			expect((await inventory.getItemInSlot(1, 0, ut_email)).itemType, equals('bean'));

			//move it into the other bag
			expect(await InventoryV2.moveItem(ut_email, fromIndex: 1, fromBagIndex: 0,
				                                  toIndex: 2, toBagIndex: 0), isTrue);

			//verify the item was moved
			inventory = await getInventory();
			expect((await inventory.getItemInSlot(1, 0, ut_email)), isNull);
			expect((await inventory.getItemInSlot(2, 0, ut_email)).itemType, equals('bean'));

			//move it from the bag to the last bar slot
			expect(await InventoryV2.moveItem(ut_email, fromIndex: 2, fromBagIndex: 0,
				                                  toIndex: 9, toBagIndex: -1), isTrue);

			//verify the item was moved
			inventory = await getInventory();
			expect((await inventory.getItemInSlot(2, 0, ut_email)), isNull);
			expect((await inventory.getItemInSlot(9, -1, ut_email)).itemType, equals('bean'));
		});

		test('Take item from Inventory (any slot)', () async {
			await InventoryV2.addItemToUser(ut_email, items['cherry'].getMap(), 1);
			await InventoryV2.addItemToUser(ut_email, items['bean'].getMap(), 1);

			//make sure the inventory has the cherry and the bean
			expect(countItemInInventory(await getInventory(), 'cherry'), equals(1));
			expect(countItemInInventory(await getInventory(), 'bean'), equals(1));

			//take the bean from the inventory and make sure they have none left
			await InventoryV2.takeAnyItemsFromUser(ut_email, 'bean', 1);
			expect(countItemInInventory(await getInventory(), 'bean'), equals(0));

			//give them 260 beans and then take 30 (beans stack to 250)
			await InventoryV2.addItemToUser(ut_email, items['bean'].getMap(), 260);
			expect(countItemInInventory(await getInventory(), 'bean'), equals(260));

			await InventoryV2.takeAnyItemsFromUser(ut_email, 'bean', 30);
			expect(countItemInInventory(await getInventory(), 'bean'), equals(230));

			//give them a toolbox and 2 picks, one outside (before toolbox) and one in
			//then verify we can take both
			await InventoryV2.addItemToUser(ut_email, items['pick'].getMap(), 1);
			await InventoryV2.addItemToUser(ut_email, items['red_toolbox'].getMap(), 1);
			await InventoryV2.addItemToUser(ut_email, items['pick'].getMap(), 1);
			expect(countItemInInventory(await getInventory(), 'pick'), equals(2));

			await InventoryV2.takeAnyItemsFromUser(ut_email, 'pick', 2);
			expect(countItemInInventory(await getInventory(), 'pick'), equals(0));
		});

		test('Take durability from items', () async {
			await InventoryV2.addItemToUser(ut_email, items['fancy_pick'].getMap(), 1);
			await InventoryV2.addItemToUser(ut_email, items['pick'].getMap(), 1);
			await InventoryV2.addItemToUser(ut_email, items['pick'].getMap(), 1);

			//verify the pick has 100 durability to start and the fancy has 200
			expect(await getRemainingDurability(0, -1), equals(200));
			expect(await getRemainingDurability(1, -1), equals(100));
			expect(await getRemainingDurability(2, -1), equals(100));

			//take away 5 durability from the pick
			await InventoryV2.decreaseDurability(ut_email, 'pick', amount: 5);

			expect(await getRemainingDurability(0, -1), equals(200));
			expect(await getRemainingDurability(1, -1), equals(95));
			expect(await getRemainingDurability(2, -1), equals(100));

			//take away 5 durability from either pick or fancy_pick but expect it to come
			//off of pick since it is already damaged
			await InventoryV2.decreaseDurability(ut_email, ['pick', 'fancy_pick'], amount: 5);

			expect(await getRemainingDurability(0, -1), equals(200));
			expect(await getRemainingDurability(1, -1), equals(90));
			expect(await getRemainingDurability(2, -1), equals(100));

			//move the damaged pick after the non-damaged one then take durability
			//and expect the damaged one to still get chosen
			await InventoryV2.moveItem(ut_email, fromIndex: 1, toIndex: 3);
			await InventoryV2.decreaseDurability(ut_email, ['pick'], amount: 5);

			expect(await getRemainingDurability(0, -1), equals(200));
			expect(await getRemainingDurability(2, -1), equals(100));
			expect(await getRemainingDurability(3, -1), equals(85));

			//take away 5 durability from a fancy_pick only
			await InventoryV2.decreaseDurability(ut_email, ['fancy_pick'], amount: 5);

			expect(await getRemainingDurability(0, -1), equals(195));
			expect(await getRemainingDurability(2, -1), equals(100));
			expect(await getRemainingDurability(3, -1), equals(85));

			//move the most damaged pick into a bag and try to damage it again
			await InventoryV2.addItemToUser(ut_email, items['generic_bag'].getMap(), 1);
			await InventoryV2.moveItem(ut_email, fromIndex: 3, toIndex: 1, toBagIndex: 0);
			await InventoryV2.decreaseDurability(ut_email, ['pick'], amount: 5);

			expect(await getRemainingDurability(0, -1), equals(195));
			expect(await getRemainingDurability(1, 0), equals(80));
			expect(await getRemainingDurability(2, -1), equals(100));
		});
	});
}

Future<InventoryV2> getInventory() async {
	app.MockRequest req = new app.MockRequest("/getInventory/$ut_email");
	app.MockHttpResponse resp = await app.dispatch(req);

	//verify we get a valid response
	expect(resp.statusCode, equals(200));

	//decode the inventory
	InventoryV2 inventory = decode(JSON.decode(resp.mockContent), InventoryV2);

	//verify inventory has 10 slots
	expect(inventory.slots.length, equals(10));

	return inventory;
}

Future<int> getRemainingDurability(int slot, int subSlot) async {
	InventoryV2 inventory = await getInventory();

	Item item = await inventory.getItemInSlot(slot, subSlot, ut_email);
	try {
		return item.durability - (item.metadata['durabilityUsed'] ?? 0);
	} catch(e) {
		return -1;
	}
}

int countItemInInventory(InventoryV2 inventory, String itemType) {
	int count = 0;

	for (Slot slot in inventory.slots) {
		if (slot.itemType == itemType) {
			count += slot.count;
		}
		if (items.containsKey(slot.itemType) && items[slot.itemType].isContainer) {
			if (slot.metadata['slots'] != null) {
				List<Slot> bagSlots = jsonx.decode(slot.metadata['slots'], type: listOfSlots);
				for (Slot slot in bagSlots) {
					if (slot.itemType == itemType) {
						count += slot.count;
					}
				}
			}
		}
	}

	return count;
}

InventoryV2 _verifyInventoryIsEmpty(InventoryV2 inventory) {
	//verify the inventory length
	expect(inventory.slots.length, equals(10));

	//verify the inventory is empty
	for (Slot slot in inventory.slots) {
		expect(slot.isEmpty, isTrue);
	}

	return inventory;
}