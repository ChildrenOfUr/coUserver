import 'dart:convert';
import 'dart:async';

import 'test_config.dart';
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

Type listOfSlots = const jsonx.TypeHelper<List<Slot>>().type;

Future main() async {
	app.addPlugin(getMapperPlugin(dbManager));
	//need to call this before loading the items
	app.redstoneSetUp();

	//ignore messages about quest requirements being completed when not on the quest
	messageBus.deadMessageHandler = (harvest.Message m) {};

	//load game items
	await StreetUpdateHandler.loadItems();

	//initialize inventory
	await _setInventoryBlank();

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
			await _setInventoryBlank();

			//this is causing an issue with getInventory on tests after the first
//			app.redstoneTearDown();
		});

		test('Verify Slot object', () async {
			Slot slot = new Slot();
			expect(slot.toString(), equals('Empty inventory slot'));

			slot = new Slot(itemType: 'bean');
			expect(slot.toString(), equals('Empty inventory slot'));

			slot = new Slot(itemType: 'bean', count: 1);
			expect(slot.toString(), equals('Inventory slot containing 1 x bean with metadata: {}'));

			slot = new Slot(itemType: 'bean', count: 1, metadata: {'metaKey':'metaValue'});
			expect(slot.toString(), equals('Inventory slot containing 1 x bean with metadata: {metaKey: metaValue}'));

			slot.itemType = null;
			expect(slot.toString(), equals('Empty inventory slot'));

			slot = new Slot(itemType: 'bean', count: 30);
			expect(slot.toString(), equals('Inventory slot containing 30 x bean with metadata: {}'));

			slot.empty = true;
			expect(slot.toString(), equals('Empty inventory slot'));

			slot = new Slot.withMap({});
			expect(slot.toString(), equals('Empty inventory slot'));

			Map slotMap = {
				'itemType': 'bean',
				'count': 25,
				'metadata': {}
			};
			slot = new Slot.withMap(slotMap);
			expect(slot.toString(), equals('Inventory slot containing 25 x bean with metadata: {}'));
			expect(slot.map, equals(slotMap));
		});

		test('Merge two inventory slots', () async {
			//spills into the second slot
			expect(await InventoryV2.addItemToUser(ut_email, items['cherry'].getMap(), 280), equals(280));
			expect(countItemInInventory(await getInventory(), 'cherry'), equals(280));

			//remove 40 which will be taken from the first slot
			expect(await InventoryV2.takeAnyItemsFromUser(ut_email, 'cherry', 40), equals(40));
			expect(countItemInInventory(await getInventory(), 'cherry'), equals(240));

			expect(await InventoryV2.moveItem(ut_email, fromIndex: 1, toIndex: 0), isTrue);
			Slot slot = (await getInventory()).getSlot(0);
			expect(slot, equals(new Slot.withMap({'itemType':'cherry', 'count':240, 'metadata':{}})));

			//with a bag
			expect(await InventoryV2.addItemToUser(ut_email, items['generic_bag'].getMap(), 1), equals(1));
			expect(await InventoryV2.addItemToUser(ut_email, items['cherry'].getMap(), 60), equals(60));
			expect(await InventoryV2.takeAnyItemsFromUser(ut_email, 'cherry', 40), equals(40));
			expect(await InventoryV2.moveItem(ut_email, fromIndex: 2, toIndex: 1, toBagIndex: 0), isTrue);
			expect(countItemInInventory(await getInventory(), 'cherry'), equals(260));
			expect(await InventoryV2.moveItem(ut_email, fromIndex: 0, toIndex: 1, toBagIndex: 0), isTrue);
			slot = (await getInventory()).getSlot(0);
			expect(slot, equals(new Slot.withMap({'itemType':'cherry', 'count':10, 'metadata':{}})));
			slot = (await getInventory()).getSlot(1, 0);
			expect(slot, equals(new Slot.withMap({'itemType':'cherry', 'count':250, 'metadata':{}})));

			//move them the other way (out of the bag, expect merge with first slot)
			expect(await InventoryV2.moveItem(ut_email, fromIndex: 1, fromBagIndex: 0, toIndex: 0), isTrue);
			slot = (await getInventory()).getSlot(0);
			expect(slot, equals(new Slot.withMap({'itemType':'cherry', 'count':250, 'metadata':{}})));
			slot = (await getInventory()).getSlot(1, 0);
			expect(slot, equals(new Slot.withMap({'itemType':'cherry', 'count':10, 'metadata':{}})));
		});

		test('Add Item to Inventory', () async {
			expect(await InventoryV2.addItemToUser(ut_email, items['cherry'].getMap(), 1), equals(1));

			//verify user has 1 cherry in their inventory
			expect(countItemInInventory(await getInventory(), 'cherry'), equals(1));

			//give user 260 cherries and make sure they get them all (cherries stack to 250)
			expect(await InventoryV2.addItemToUser(ut_email, items['cherry'].getMap(), 260), equals(260));
			expect(countItemInInventory(await getInventory(), 'cherry'), equals(261));

			//add 9 non-stackable items which should overflow
			expect(await InventoryV2.addItemToUser(ut_email, items['bigger_bag'].getMap(), 9), equals(8));
			expect(countItemInInventory(await getInventory(), 'bigger_bag'), equals(8));

			//add a new item which should go into the bags (split across 2 bags)
			expect(await InventoryV2.addItemToUser(ut_email, items['bean'].getMap(), 4001), equals(4001));
			expect(countItemInInventory(await getInventory(), 'bean'), equals(4001));
		});

		test('Move items in Inventory', () async {
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

		test('Take item from specified slot', () async {
			expect(await InventoryV2.addItemToUser(ut_email, items['cherry'].getMap(), 1), equals(1));
			expect(await InventoryV2.addItemToUser(ut_email, items['bean'].getMap(), 300), equals(300));
			expect(await InventoryV2.addItemToUser(ut_email, items['generic_bag'].getMap(), 1), equals(1));
			expect(await InventoryV2.addItemToUser(ut_email, items['red_toolbox'].getMap(), 1), equals(1));
			//the pick should go in the toolbox
			expect(await InventoryV2.addItemToUser(ut_email, items['pick'].getMap(), 1), equals(1));
			inventory = await getInventory();
			expect((await inventory.getItemInSlot(4, 0, ut_email)).itemType, equals('pick'));

			//take 1 bean from slot index 2
			Item item = await InventoryV2.takeItemFromUser(ut_email, 2, -1, 1);
			expect(item.itemType, equals('bean'));
			Slot slot = (await getInventory()).getSlot(1);
			expect(slot.count, equals(250));
			slot = (await getInventory()).getSlot(2);
			expect(slot.count, equals(49));

			//take all beans from slot index 1
			item = await InventoryV2.takeItemFromUser(ut_email, 1, -1, 250);
			expect(item.itemType, equals('bean'));
			slot = (await getInventory()).getSlot(1);
			expect(slot.isEmpty, isTrue);

			//take the pick from the toolbox
			item = await InventoryV2.takeItemFromUser(ut_email, 4, 0, 1);
			expect(item.itemType, equals('pick'));
			slot = (await getInventory()).getSlot(4, 0);
			expect(slot.isEmpty, isTrue);
		});

		test('Take item from Inventory (any slot)', () async {
			expect(await InventoryV2.addItemToUser(ut_email, items['cherry'].getMap(), 1), equals(1));
			expect(await InventoryV2.addItemToUser(ut_email, items['bean'].getMap(), 1), equals(1));

			//make sure the inventory has the cherry and the bean
			expect(countItemInInventory(await getInventory(), 'cherry'), equals(1));
			expect(countItemInInventory(await getInventory(), 'bean'), equals(1));

			//take the bean from the inventory and make sure they have none left
			expect(await InventoryV2.takeAnyItemsFromUser(ut_email, 'bean', 1), equals(1));
			expect(countItemInInventory(await getInventory(), 'bean'), equals(0));

			//give them 260 beans and then take 30 (beans stack to 250)
			expect(await InventoryV2.addItemToUser(ut_email, items['bean'].getMap(), 260), equals(260));
			expect(countItemInInventory(await getInventory(), 'bean'), equals(260));

			expect(await InventoryV2.takeAnyItemsFromUser(ut_email, 'bean', 30), equals(30));
			expect(countItemInInventory(await getInventory(), 'bean'), equals(230));

			//give them a toolbox and 2 picks, one outside (before toolbox) and one in
			//then verify we can take both
			expect(await InventoryV2.addItemToUser(ut_email, items['pick'].getMap(), 1), equals(1));
			expect(await InventoryV2.addItemToUser(ut_email, items['red_toolbox'].getMap(), 1), equals(1));
			expect(await InventoryV2.addItemToUser(ut_email, items['pick'].getMap(), 1), equals(1));
			expect(countItemInInventory(await getInventory(), 'pick'), equals(2));

			expect(await InventoryV2.takeAnyItemsFromUser(ut_email, 'pick', 2), equals(2));
			expect(countItemInInventory(await getInventory(), 'pick'), equals(0));
		});

		test('Has item', () async {
			expect(await InventoryV2.addItemToUser(ut_email, items['cherry'].getMap(), 1), equals(1));
			expect(await InventoryV2.addItemToUser(ut_email, items['bean'].getMap(), 300), equals(300));
			expect(await InventoryV2.addItemToUser(ut_email, items['generic_bag'].getMap(), 1), equals(1));
			expect(await InventoryV2.addItemToUser(ut_email, items['red_toolbox'].getMap(), 1), equals(1));
			expect(await InventoryV2.addItemToUser(ut_email, items['pick'].getMap(), 1), equals(1));

			//does user have 1 cherry?
			expect(await InventoryV2.hasItem(ut_email, 'cherry', 1), isTrue);

			//does user have 2 cherries?
			expect(await InventoryV2.hasItem(ut_email, 'cherry', 2), isFalse);

			//does user have 260 beans?
			expect(await InventoryV2.hasItem(ut_email, 'bean', 260), isTrue);

			//does user have a pick?
			expect(await InventoryV2.hasItem(ut_email, 'pick', 1), isTrue);

			//does user have a fancy_pick?
			expect(await InventoryV2.hasItem(ut_email, 'fancy_pick', 1), isFalse);
		});

		test('Take durability from only one choice (commit d6437e129)', () async {
			expect(await InventoryV2.addItemToUser(ut_email, items['fancy_pick'].getMap(), 1), equals(1));
			expect(await getRemainingDurability(0, -1), equals(200));

			//take away 5 durability from the pick
			expect(await InventoryV2.decreaseDurability(ut_email, 'fancy_pick', amount: 5), isTrue);
			expect(await getRemainingDurability(0, -1), equals(195));
		});

		test('Take durability from items', () async {
			expect(await InventoryV2.addItemToUser(ut_email, items['fancy_pick'].getMap(), 1), equals(1));
			expect(await InventoryV2.addItemToUser(ut_email, items['pick'].getMap(), 1), equals(1));
			expect(await InventoryV2.addItemToUser(ut_email, items['pick'].getMap(), 1), equals(1));

			//verify the pick has 100 durability to start and the fancy has 200
			expect(await getRemainingDurability(0, -1), equals(200));
			expect(await getRemainingDurability(1, -1), equals(100));
			expect(await getRemainingDurability(2, -1), equals(100));

			//take away 5 durability from the pick
			expect(await InventoryV2.decreaseDurability(ut_email, 'pick', amount: 5), isTrue);

			expect(await getRemainingDurability(0, -1), equals(200));
			expect(await getRemainingDurability(1, -1), equals(95));
			expect(await getRemainingDurability(2, -1), equals(100));

			//take away 5 durability from either pick or fancy_pick but expect it to come
			//off of pick since it is already damaged
			expect(await InventoryV2.decreaseDurability(ut_email, ['pick', 'fancy_pick'], amount: 5), isTrue);

			expect(await getRemainingDurability(0, -1), equals(200));
			expect(await getRemainingDurability(1, -1), equals(90));
			expect(await getRemainingDurability(2, -1), equals(100));

			//move the damaged pick after the non-damaged one then take durability
			//and expect the damaged one to still get chosen
			expect(await InventoryV2.moveItem(ut_email, fromIndex: 1, toIndex: 3), isTrue);
			expect(await InventoryV2.decreaseDurability(ut_email, ['pick'], amount: 5), isTrue);

			expect(await getRemainingDurability(0, -1), equals(200));
			expect(await getRemainingDurability(2, -1), equals(100));
			expect(await getRemainingDurability(3, -1), equals(85));

			//take away 5 durability from a fancy_pick only
			expect(await InventoryV2.decreaseDurability(ut_email, ['fancy_pick'], amount: 5), isTrue);

			expect(await getRemainingDurability(0, -1), equals(195));
			expect(await getRemainingDurability(2, -1), equals(100));
			expect(await getRemainingDurability(3, -1), equals(85));

			//move the most damaged pick into a bag and try to damage it again
			expect(await InventoryV2.addItemToUser(ut_email, items['generic_bag'].getMap(), 1), equals(1));
			expect(await InventoryV2.moveItem(ut_email, fromIndex: 3, toIndex: 1, toBagIndex: 0), isTrue);
			expect(await InventoryV2.decreaseDurability(ut_email, ['pick'], amount: 5), isTrue);

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
		return item.durability - (int.parse(item.metadata['durabilityUsed'] ?? '0'));
	} catch (e) {
		log('Error getting durability for $slot,$subSlot: $e');
		return -1;
	}
}

int countItemInInventory(InventoryV2 inventory, String itemType) {
	return inventory.countItem(itemType);
}

Future _setInventoryBlank() async {
	String query = "UPDATE inventories SET inventory_json = '[]' WHERE user_id = $ut_id";
	PostgreSql dbConn = await dbManager.getConnection();
	await dbConn.execute(query);
	dbManager.closeConnection(dbConn);
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