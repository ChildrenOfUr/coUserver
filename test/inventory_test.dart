import 'dart:convert';
import 'dart:async';

import 'package:coUserver/inventory_new.dart';
import 'package:coUserver/common/util.dart';
import 'package:coUserver/street_update_handler.dart';

import 'package:test/test.dart';
import 'package:redstone/redstone.dart' as app;
import 'package:redstone_mapper/plugin.dart';
import 'package:redstone_mapper/mapper.dart';
import 'package:redstone_mapper_pg/manager.dart';
import 'package:harvest/harvest.dart' as harvest;

//some constants
String ut_email = '3fkw19+5xkfumzd5c5e4@sharklasers.com';
int ut_id = 3633;

Future main() async {
	app.addPlugin(getMapperPlugin(dbManager));
	//need to call this before loading the items
	app.redstoneSetUp();

	//ignore messages about quest requirements being completed when not on the quest
	messageBus.deadMessageHandler = (harvest.Message m){};

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

			app.redstoneTearDown();
		});

		test('Add Item to Inventory', () async {
			await InventoryV2.addItemToUser(ut_email, items['cherry'].getMap(), 1);

			//verify user has 1 cherry in their inventory
			expect(countItemInInventory(await getInventory(), 'cherry'), equals(1));

			//give user 260 cherries and make sure they get them all (cherries stack to 250)
			await InventoryV2.addItemToUser(ut_email, items['cherry'].getMap(), 260);
			expect(countItemInInventory(await getInventory(), 'cherry'), equals(261));
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
		});
	});
}

Future<InventoryV2> getInventory() async {
	app.MockRequest req = new app.MockRequest("/getInventory/$ut_email");
	app.MockHttpResponse resp = await app.dispatch(req);

	//verify we get a valid response
	expect(resp.statusCode, equals(200));

	print('got ${resp.mockContent}');
	//decode the inventory
	return decode(JSON.decode(resp.mockContent), InventoryV2);
}

int countItemInInventory(InventoryV2 inventory, String itemType) {
	int count = 0;

	for(Slot slot in inventory.slots) {
		if(slot.itemType == itemType) {
			count += slot.count;
		}
		if(items[itemType].isContainer) {
			if(slot.metadata['slots'] != null) {
				List<Slot> bagSlots = decode(slot.metadata['slots'], Slot);
				for(Slot slot in bagSlots) {
					if(slot.itemType == itemType) {
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
	for(Slot slot in inventory.slots) {
		expect(slot.isEmpty, isTrue);
	}

	return inventory;
}