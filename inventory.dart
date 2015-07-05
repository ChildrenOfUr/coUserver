part of coUserver;

class Inventory {
	@Field()
	int inventory_id;

	@Field()
	String inventory_json;

	@Field()
	int user_id;

	factory Inventory() => new Inventory._internal();

	Inventory._internal() {
		this.inventory_json = '[]';
	}

	static Map<String,String> itemTypes = {};

	void upgradeItems() {
		List<Map> slots = JSON.decode(inventory_json);
		for(Map slot in slots) {
			if(!slot['item'].containsKey('itemType')) {
				if(itemTypes.containsKey(slot['item']['name'])) {
					slot['item']['itemType'] = itemTypes[slot['item']['name']];
				} else {
					items.forEach((String itemType, Item item) {
						if(item.name == slot['item']['name']) {
							slot['item']['itemType'] = itemType;
							itemTypes[item.name] = itemType;
						}
					});
				}
			}
		}
		inventory_json = JSON.encode(slots);
	}

	Future<int> addItem(Map item, int count, String email, PostgreSql dbConn) async {
		List<Map> slots = JSON.decode(inventory_json);
		bool found = false;
		for(Map slot in slots) {
			if(found) {
				break;
			}

			if(slot['isContainer']) {
				for(Map slotItem in slot['contents']) {
					if(slotItem['item']['name'] == item['name']) {
						slotItem['count'] += count;
						found = true;
						break;
					}
				}
			}
			else {
				if(slot['item']['name'] == item['name']) {
					slot['count'] += count;
					found = true;
					break;
				}
			}
		}

		if(!found) {
			slots.add({'isContainer':item['isContainer'],
				          'item':item,
				          'count':count});
		}
		inventory_json = JSON.encode(slots);

		String queryString = "UPDATE inventories SET inventory_json = @inventory_json WHERE user_id = @user_id";
		int numRowsUpdated = await dbConn.execute(queryString, this);

		if(numRowsUpdated > 0) {
			return numRowsUpdated;
		}
		else {
			String query = "SELECT * FROM users WHERE email = @email";
			Row row = await dbConn.innerConn.query(query, {'email':email}).first;
			this.user_id = row.id;
			queryString = "INSERT INTO inventories(inventory_json, user_id) VALUES(@inventory_json,@user_id)";
			int result = await dbConn.execute(queryString, this);
			return result;
		}
	}

	Future<int> takeItem(String itemType, int count, PostgreSql dbConn) async {
		List<Map> slots = JSON.decode(inventory_json);
		List<int> removeItems = [];
		List<int> possiblyRemove = [];

		for(int i = 0; i < slots.length; i++) {
			Map slot = slots.elementAt(i);

			if(count <= 0) {
				break;
			}

			if(slot['item']['itemType'] == itemType) {
				if(slot['count'] > count) {
					slot['count'] -= count;
					count = 0;
				}
				if(slot['count'] == count) {
					removeItems.add(i);
					count = 0;
				}
				if(slot['count'] < count) {
					possiblyRemove.add(i);
					count -= slot['count'];
				}
			}
		}

		//always remove these, we know they succeeded
		removeItems.forEach((int index) => slots.removeAt(index));

		//only remove these if the count is now 0
		//otherwise we failed to take enough items
		if(count == 0) {
			possiblyRemove.forEach((int index) => slots.removeAt(index));
		}

		inventory_json = JSON.encode(slots);

		String queryString = "UPDATE inventories SET inventory_json = @inventory_json WHERE user_id = @user_id";
		int numRowsUpdated = await dbConn.execute(queryString, this);
		return numRowsUpdated;
	}

	List<Map> getItems() {
		List<Map> items = [];

		List<Map> slots = JSON.decode(inventory_json);
		slots.forEach((Map slot) {
			for(int i = 0; i < slot['count']; i++) {
				items.add(slot['item']);
			}
		});

		return items;
	}
}

@app.Route('/getInventory/:email')
@Encode()
Future<Inventory> getUserInventory(String email) async {
	PostgreSql dbConn = await dbManager.getConnection();

	String queryString = "SELECT * FROM inventories JOIN users ON users.id = user_id WHERE users.email = @email";
	List<Inventory> inventories = await dbConn.query(queryString, Inventory, {'email':email});

	Inventory inventory = new Inventory();
	if(inventories.length > 0) {
		inventory = inventories.first;
	}

	dbManager.closeConnection(dbConn);
	return inventory;
}

Future<int> addItemToUser(WebSocket userSocket, String email, Map item, int count, String fromObject) async {
	PostgreSql dbConn = await dbManager.getConnection();

	Inventory inventory = await getUserInventory(email);

	//save the item in the user's inventory in the database
	//then send it to the client
	int numRows = await inventory.addItem(item, count, email, dbConn);
	sendItemToUser(userSocket, item, count, fromObject);

	dbManager.closeConnection(dbConn);
	return numRows;
}

Future<bool> takeItemFromUser(WebSocket userSocket, String email, String itemType, int count) async {
	PostgreSql dbConn = await dbManager.getConnection();
	bool success = false;

	Inventory inventory = await getUserInventory(email);
	int num = 0;
	inventory.getItems().forEach((Map item) {
		if(item['itemType'] == itemType) {
			num++;
		}
	});
	if(num >= count) {
		int rowsUpdated = await inventory.takeItem(itemType, count, dbConn);

		if(rowsUpdated > 0) {
			takeItem(userSocket, items[itemType].name, count);
		}

		success = true;
	}

	dbManager.closeConnection(dbConn);

	return success;
}

Future fireInventoryAtUser(WebSocket userSocket, String email) async {
	PostgreSql dbConn = await dbManager.getConnection();

	Inventory inventory = await getUserInventory(email);
	Map<String, Map> itemMap = {};
	Map inventoryMap = {'inventory':'true', 'items':itemMap};
	inventory.getItems().forEach((Map item) {
		if(!itemMap.containsKey(item['name'])) {
			item['count'] = 1;
			itemMap[item['name']] = item;
		}
		else {
			Map i = itemMap[item['name']];
			i['count'] += 1;
			itemMap[item['name']] = i;
		}
		//sendItemToUser(userSocket,item,1,'');
	});
	userSocket.add(JSON.encode(inventoryMap));

	dbManager.closeConnection(dbConn);
}

sendItemToUser(WebSocket userSocket, Map item, int count, String fromObject) {
	Map map = {};
	map['giveItem'] = "true";
	map['item'] = item;
	map['num'] = count;
	map['fromObject'] = fromObject;
	userSocket.add(JSON.encode(map));
}

takeItem(WebSocket userSocket, String itemName, int count) {
	Map map = {};
	map['takeItem'] = "true";
	map['name'] = itemName;
	map['count'] = count;
	userSocket.add(JSON.encode(map));
}