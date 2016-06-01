// This was used to upgrade the inventories in place so that they had the right key/value pairs.
/*
String query = 'SELECT * FROM inventories';

PostgreSql db = await dbManager.getConnection();

List<InventoryV2> inventories = await db.query(query, InventoryV2);

print('processing ${inventories.length} inventories for upgrade...');

List<Future> futures = [];

query = 'UPDATE inventories SET inventory_json = @inventory_json WHERE inventory_id = inventory_id';

inventories.forEach((InventoryV2 inventory) {
	inventory._upgradeItems();
	futures.add(db.execute(query, inventory));
});

await Future.wait(futures);

print('upgading complete');

dbManager.closeConnection(db);
*/
