part of coUserver;
//
//class Inventory {
//	@Field()
//	int inventory_id;
//
//	@Field()
//	String inventory_json;
//
//	@Field()
//	int user_id;
//
//	factory Inventory() => new Inventory._internal();
//
//	Inventory._internal() {
//		this.inventory_json = '{}';
//	}
//
//	void upgradeItems() {
//		//if it's not a list of map, then we've already upgraded
//		if(JSON.decode(inventory_json) is! List<Map>) {
//			return;
//		}
//
//		List<Map> slots = JSON.decode(inventory_json);
//		Map<String,int> newInventory = {};
//		for(Map slot in slots) {
//			String itemType = slot['item']['itemType'];
//			if(itemType != null) {
//				if(!newInventory.containsKey(itemType)) {
//					newInventory[itemType] = slot['count'];
//				} else {
//					newInventory[itemType] = newInventory[itemType] + slot['count'];
//				}
//			}
//		}
//		print(newInventory);
//		inventory_json = JSON.encode(newInventory);
//	}
//
//	Future<int> addItem(Map item, int count, String email) async {
//		Map<String,int> slots = JSON.decode(inventory_json);
//		String newItem = item['itemType'];
//		if(slots.containsKey(newItem)) {
//			slots[newItem] = slots[newItem] + count;
//		} else {
//			slots[newItem] = count;
//		}
//
//		inventory_json = JSON.encode(slots);
//
//		PostgreSql dbConn = await dbManager.getConnection();
//
//		String queryString = "UPDATE inventories SET inventory_json = @inventory_json WHERE user_id = @user_id";
//		int numRowsUpdated = await dbConn.execute(queryString, this);
//
//		dbManager.closeConnection(dbConn);
//
//		if(numRowsUpdated > 0) {
//			return numRowsUpdated;
//		}
//		else {
//			String query = "SELECT * FROM users WHERE email = @email";
//			Row row = await dbConn.innerConn.query(query, {'email':email}).first;
//			this.user_id = row.id;
//			queryString = "INSERT INTO inventories(inventory_json, user_id) VALUES(@inventory_json,@user_id)";
//			int result = await dbConn.execute(queryString, this);
//			return result;
//		}
//	}
//
//	Future<int> takeItem(String itemType, int count) async {
//		Map<String,int> slots = JSON.decode(inventory_json);
//		if(slots.containsKey(itemType)) {
//			int have = slots[itemType];
//			if(have > count) {
//				slots[itemType] = slots[itemType] - count;
//			} else if(have == count) {
//				slots.remove(itemType);
//			} else {
//				return 0;
//			}
//		}
//
//		inventory_json = JSON.encode(slots);
//
//		PostgreSql dbConn = await dbManager.getConnection();
//		String queryString = "UPDATE inventories SET inventory_json = @inventory_json WHERE user_id = @user_id";
//		int numRowsUpdated = await dbConn.execute(queryString, this);
//		dbManager.closeConnection(dbConn);
//
//		return numRowsUpdated;
//	}
//
//	List<Map> getItems() {
//		List<Map> results = [];
//
//		Map<String,int> slots = JSON.decode(inventory_json);
//		slots.forEach((String itemType, int count) {
//			for(int i = 0; i < count; i++) {
//				results.add(items[itemType].getMap());
//			}
//		});
//
//		return results;
//	}
//}
//
//@app.Route('/getInventory/:email')
//@Encode()
//Future<Inventory> getUserInventory(String email) async {
//	PostgreSql dbConn = await dbManager.getConnection();
//
//	String queryString = "SELECT * FROM inventories JOIN users ON users.id = user_id WHERE users.email = @email";
//	List<Inventory> inventories = await dbConn.query(queryString, Inventory, {'email':email});
//
//	Inventory inventory = new Inventory();
//	if(inventories.length > 0) {
//		inventory = inventories.first;
//	}
//
//	dbManager.closeConnection(dbConn);
//	return inventory;
//}
//
//Future<int> addItemToUser(WebSocket userSocket, String email, Map item, int count, String fromObject) async {
//	Inventory inventory = await getUserInventory(email);
//
//	//save the item in the user's inventory in the database
//	//then send it to the client
//	int numRows = await inventory.addItem(item, count, email);
//	sendItemToUser(userSocket, item, count, fromObject);
//
//	return numRows;
//}
//
//Future<bool> takeItemFromUser(WebSocket userSocket, String email, String itemType, int count) async {
//	bool success = false;
//
//	Inventory inventory = await getUserInventory(email);
//	int num = 0;
//	inventory.getItems().forEach((Map item) {
//		if(item['itemType'] == itemType) {
//			num++;
//		}
//	});
//	if(num >= count) {
//		int rowsUpdated = await inventory.takeItem(itemType, count);
//
//		if(rowsUpdated > 0) {
//			takeItem(userSocket, itemType, count);
//		}
//
//		success = true;
//	}
//
//	return success;
//}
//
//Future fireInventoryAtUser(WebSocket userSocket, String email) async {
//	Inventory inventory = await getUserInventory(email);
//	Map<String,Map> itemMap = {};
//	Map inventoryMap = {'inventory':'true', 'items':itemMap};
//	inventory.getItems().forEach((Map item) {
//		if(!itemMap.containsKey(item['name'])) {
//			Map newItem = {'count':1,'item':items[item['itemType']].getMap()};
//			itemMap[item['name']] = newItem;
//		} else {
//			Map existingItem = itemMap[item['name']];
//			existingItem['count'] = existingItem['count'] + 1;
//			itemMap[item['name']] = existingItem;
//		}
//	});
//	//{'inventory':'true','items':{'apple':{'count':5,'item':Item},...}}
//	userSocket.add(JSON.encode(inventoryMap));
//}
//
//sendItemToUser(WebSocket userSocket, Map item, int count, String fromObject) {
//	Map map = {};
//	map['giveItem'] = "true";
//	map['item'] = encode(new Item.clone(item['itemType']));
//	map['num'] = count;
//	map['fromObject'] = fromObject;
//	userSocket.add(JSON.encode(map));
//}
//
//takeItem(WebSocket userSocket, String itemType, int count) {
//	Map map = {};
//	map['takeItem'] = "true";
//	map['itemType'] = itemType;
//	map['count'] = count;
//	userSocket.add(JSON.encode(map));
//}