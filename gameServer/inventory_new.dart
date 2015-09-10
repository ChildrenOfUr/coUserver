part of coUserver;

Type listOfSlots = new jsonx.TypeHelper<List<Slot>>().type;

class Slot {
	//a new instance of a Slot is empty by default
	@Field() String itemType = "";
	@Field() int count = 0;
	@Field() Map metadata = {};
}

@app.Group("/inventory")
class InventoryV2 {

	// Globals ////////////////////////////////////////////////////////////////////////////////////

	// Sets how many slots each player has
	final int invSize = 10;

	@Field() int inventory_id, user_id;
	@Field() String inventory_json = '[]';

	List<Slot> get slots {
		List<Slot> s = jsonx.decode(inventory_json, type: listOfSlots);
		while (s.length < invSize) {
			s.add(new Slot());
		}
		return s;
	}

	//do not make a setter for slots it is a convenience field only

	// Private Methods ////////////////////////////////////////////////////////////////////////////

//	 Might need this
//	void _upgradeItems() {
//		if (JSON.decode(inventory_json) is Map) {
//			Map<String, int> inventoryMap = JSON.decode(inventory_json);
//			List<Slot> slotsToAdd = [];
//
//			inventoryMap.forEach((String itemType, int count) {
//				Slot slot = new Slot()
//					..itemType = itemType
//					..count = count;
//				slotsToAdd.add(slot);
//			});
//
//			//make sure it totals 11 slots
//			while (slotsToAdd.length < invSize) {
//				slotsToAdd.add(new Slot());
//			}
//
//			inventory_json = jsonx.encode(slotsToAdd);
//		} else {
//			//inventory was already upgraded
//			return;
//		}
//	}

	Future<int> _addItem(Map itemMap, int count, String email) async {
		//instantiate an item object based on the map
		Item item = jsonx.decode(JSON.encode(itemMap), type:Item);

		// Keep a record of how many items we have merged into slots already,
		// and how many more need to find homes
		int toMerge = count, merged = 0;

		// Go through entire inventory and try to find a slot that either:
		// a) has the same type of item in it and is not a full stack, or
		// b) is empty and can accept at least [count] of item
		// c) is a container and has an available slot
		List<Slot> tmpSlots = slots;
		for (Slot slot in tmpSlots) {
			// Check if we are done merging, then stop looping
			if (toMerge == 0) {
				break;
			}

			// If not, decide if we can merge into the slot
			bool canMerge = false, emptySlot = false;

			if (slot.itemType.isEmpty || slot.count == 0) {
				canMerge = true;
				emptySlot = true;
			} else {
				if (slot.itemType == item.itemType &&
				    slot.count < item.stacksTo &&
				    slot.metadata.length == 0) {
					canMerge = true;
				}

				Item slotItem = items[slot.itemType];
				if (slotItem.isContainer &&
				    (slotItem.subSlotFilter.contains(item.itemType) || slotItem.subSlotFilter.length == 0)) {
					List<Slot> innerSlots;
					if (slot.metadata.containsKey('slots')) {
						innerSlots = jsonx.decode(slot.metadata['slots'], type: listOfSlots);
					} else {
						innerSlots = [];
						while (innerSlots.length < slotItem.subSlots) {
							innerSlots.add(new Slot());
						}
					}
					for (Slot slot in innerSlots) {
						// Check if we are done merging, then stop looping
						if (toMerge == 0) {
							break;
						}

						// If not, decide if we can merge into the slot
						bool canMerge = false, emptySlot = false;

						if (slot.itemType == "" || slot.count == 0) {
							canMerge = true;
							emptySlot = true;
						} else {
							if (slot.itemType == item.itemType &&
							    slot.count < item.stacksTo &&
							    slot.metadata.length == 0) {
								canMerge = true;
							}
						}
						// If this slot is suitable...
						if (canMerge) {
							// Figure out how many we can merge
							int availInStack = item.stacksTo - slot.count;

							if (availInStack >= toMerge) {
								slot.count += toMerge;
								merged += toMerge;
								toMerge = 0;
							} else {
								slot.count += availInStack;
								merged += availInStack;
								toMerge -= availInStack;
							}

							// If the slot was empty, give it some data
							if (emptySlot) {
								slot.itemType = item.itemType;
								slot.metadata = item.metadata;
							}
						} else {
							// If not, skip it
							continue;
						}
					}
					slot.metadata['slots'] = jsonx.encode(innerSlots);
				}
			}

			// If this slot is suitable...
			if (canMerge) {
				// Figure out how many we can merge
				int availInStack = item.stacksTo - slot.count;

				if (availInStack >= toMerge) {
					slot.count += toMerge;
					merged += toMerge;
					toMerge = 0;
				} else {
					slot.count += availInStack;
					merged += availInStack;
					toMerge -= availInStack;
				}

				// If the slot was empty, give it some data
				if (emptySlot) {
					slot.itemType = item.itemType;
					slot.metadata = item.metadata;
				}
			} else {
				// If not, skip it
				continue;
			}
		}

		inventory_json = jsonx.encode(tmpSlots);

		if (toMerge > 0) {
			log("[InventoryV2] Cannot give ${item.itemType} x $count to user with email $email because they ran"
			    + " out of slots before all items were added. $toMerge items skipped.");
//			item.putItemOnGround()
		}

		await _updateDatabase(email);

		return merged;
	}

	Future _updateDatabase(String email) async {
		PostgreSql dbConn = await dbManager.getConnection();

		String queryString = "UPDATE inventories SET inventory_json = @inventory_json WHERE user_id = @user_id";
		int numRowsUpdated = await dbConn.execute(queryString, this);

		if (numRowsUpdated <= 0) {
			String query = "SELECT * FROM users WHERE email = @email";
			Row row = await dbConn.innerConn.query(query, {'email':email}).first;
			this.user_id = row.id;
			queryString = "INSERT INTO inventories(inventory_json, user_id) VALUES(@inventory_json,@user_id)";
			int result = await dbConn.execute(queryString, this);
			return result;
		}

		dbManager.closeConnection(dbConn);
	}

	Future<Item> _takeItem(int slot, int subSlot, int count, String email) async {
		List<Slot> tmpSlots = slots;
		Slot toModify = tmpSlots.elementAt(slot);
		Slot dropped;

		//if we're taking from a bag
		if (subSlot > -1) {
			List<Slot> bagSlots = jsonx.decode(toModify.metadata['slots'], type:listOfSlots);
			Slot bagSlotToModify = bagSlots.elementAt(subSlot);
			if (bagSlotToModify.count < count) {
				return null;
			} else {
				if (bagSlotToModify.count == count) {
					bagSlotToModify = new Slot();
				} else {
					bagSlotToModify.count -= count;
				}
			}

			dropped = bagSlots.removeAt(subSlot);
			bagSlots.insert(subSlot, bagSlotToModify);
			toModify.metadata['slots'] = jsonx.encode(bagSlots);
			tmpSlots.remove(slot);

		} else {
			if (toModify.count < count) {
				return null;
			}
			if (toModify.count == count) {
				toModify = new Slot();
			} else {
				toModify.count -= count;
			}

			dropped = tmpSlots.removeAt(slot);
		}

		tmpSlots.insert(slot, toModify);

		inventory_json = jsonx.encode(tmpSlots);
		await _updateDatabase(email);

		Item droppedItem = new Item.clone(dropped.itemType);
		droppedItem.metadata = dropped.metadata;
		return droppedItem;
	}

	Future<int> _takeAnyItems(Map itemMap, int count, String email) async {
		Item item = jsonx.decode(JSON.encode(itemMap), type:Item);
		// Keep a record of how many items we have taken from slots already,
		// and how many more we need to remove
		int toGrab = count, grabbed = 0;

		// Go through entire inventory and try to find a slot that has this item,
		// and continue until all are taken
		List<Slot> tmpSlots = slots;
		for (Slot slot in tmpSlots) {
			// Check if we are done taking, then stop looping
			if (toGrab == 0) {
				break;
			}

			Item slotItem = items[slot.itemType];
			if (slotItem.isContainer &&
			    (slotItem.subSlotFilter.contains(item.itemType) || slotItem.subSlotFilter.length == 0)) {
				Type listOfSlots = new jsonx.TypeHelper<List<Slot>>().type;
				List<Slot> innerSlots = [];
				if (slot.metadata.containsKey('slots')) {
					innerSlots = jsonx.decode(slot.metadata['slots'], type: listOfSlots);
				}
				for (Slot slot in innerSlots) {
					//does this slot have the type of item we are taking?
					if (slot.itemType != item.itemType) {
						continue;
					}

					// Skip empty slots
					if (slot.itemType == "" && slot.count == 0) {
						continue;
					}

					int have = slot.count, diff;

					if (have >= toGrab) {
						diff = toGrab;
						slot.count -= toGrab;
					} else {
						diff = toGrab - have;
						slot.count = 0;
					}

					if (slot.count == 0) {
						slot.itemType = "";
						slot.metadata = {};
					}

					// Update counters and move to the next slot
					toGrab -= diff;
					grabbed += diff;
				}
				slot.metadata['slots'] = jsonx.encode(innerSlots);
			}

			//does this slot have the type of item we are taking?
			if (slot.itemType != item.itemType) {
				continue;
			}

			// Skip empty slots
			if (slot.itemType == "" && slot.count == 0) {
				continue;
			}

			int have = slot.count, diff;

			if (have >= toGrab) {
				diff = toGrab;
				slot.count -= toGrab;
			} else {
				diff = toGrab - have;
				slot.count = 0;
			}

			if (slot.count == 0) {
				slot.itemType = "";
				slot.metadata = {};
			}

			// Update counters and move to the next slot
			toGrab -= diff;
			grabbed += diff;
		}

		if (toGrab > 0) {
			//abort - if we can't have it all, we can't have any
			log("[InventoryV2] Cannot take ${item.itemType} x $count from user with email $email because they ran"
			    + " out of slots before all items were taken. $toGrab items skipped.");
			return 0;
		} else {
			inventory_json = jsonx.encode(tmpSlots);
			await _updateDatabase(email);
			return grabbed;
		}
	}

	static Future fireInventoryAtUser(WebSocket userSocket, String email, {bool update: false}) async {
		InventoryV2 inv = await getInventory(email);
		List<Map> slotMaps = [];
		for (Slot slot in inv.slots) {
			Item item = null;
			if (slot.itemType != "") {
				item = new Item.clone(slot.itemType);
				item.metadata = slot.metadata;
				if (item.isContainer && item.metadata['slots'] != null) {
					List<Slot> bagSlots = jsonx.decode(item.metadata['slots'], type: listOfSlots);
					List<Map> bagSlotMaps = [];
					bagSlots.forEach((Slot bagSlot) {
						Item bagItem = null;
						if (bagSlot.itemType != "") {
							bagItem = new Item.clone(bagSlot.itemType);
							bagItem.metadata = bagSlot.metadata;
						}
						Map bagSlotMap = {
							'itemType':bagSlot.itemType,
							'item':encode(bagItem),
							'count':bagSlot.count
						};
						bagSlotMaps.add(bagSlotMap);
					});
					item.metadata['slots'] = bagSlotMaps;
				}
			}
			Map slotMap = {
				'itemType':slot.itemType,
				'item':encode(item),
				'count':slot.count,
			};
			slotMaps.add(slotMap);
		}
		Map inventoryMap = {'inventory':'true', 'update':update, 'slots':slotMaps};
		userSocket.add(JSON.encode(inventoryMap));
	}

	// Public Methods /////////////////////////////////////////////////////////////////////////////

	// Return the inventory as a List<Map>, where each slot is a Map in the List
	// Can then be READ by other functions (but not written to)
	List<Map> getItems() {
		return JSON.decode(inventory_json);
	}

	// Returns true if the user has the given amount of an item, false if not
	// If no amount is given, it checks if they have any at all (at least 1)
	bool containsItem(String itemType, [int count = 1]) {
		List<Map> inventory = JSON.decode(inventory_json);

		int toFind = count;

		inventory.forEach((Map slot) {
			if (slot["itemType"] == itemType) {
				toFind -= slot["count"];
			}
		});

		if (toFind == 0) {
			return true;
		} else {
			return false;
		}
	}

	// Returns the number of a certain item a user has
	int countItem(String itemType) {
		List<Map> inventory = JSON.decode(inventory_json);

		int found = 0;

		inventory.forEach((Map slot) {
			if (slot["itemType"] == itemType) {
				found += slot["count"];
			}
		});

		return found;
	}

	// Static Public Methods //////////////////////////////////////////////////////////////////////

	static Future<int> addItemToUser(WebSocket userSocket, String email, Map item, int count, [String fromObject = "_self"]) async {
		InventoryV2 inv = await getInventory(email);
		int added = await inv._addItem(item, count, email);
		if (added == count) {
			await fireInventoryAtUser(userSocket, email, update:true);
			return count;
		} else {
			return -1;
		}
	}

	static Future<Item> takeItemFromUser(WebSocket userSocket, String email, int slot, int subSlot, int count) async {
		InventoryV2 inv = await getInventory(email);
		Item itemTaken = await inv._takeItem(slot, subSlot, count, email);
		if (itemTaken != null) {
			await fireInventoryAtUser(userSocket, email, update:true);
		}
		return itemTaken;
	}

	static Future<int> takeAnyItemsFromUser(WebSocket userSocket, String email, String itemType, int count) async {
		InventoryV2 inv = await getInventory(email);
		int taken = await inv._takeAnyItems(items[itemType].getMap(), count, email);
		if (taken == count) {
			await fireInventoryAtUser(userSocket, email, update:true);
			return count;
		} else {
			return -1;
		}
	}
}

@app.Route("/getInventory/:email")
@Encode()
Future<InventoryV2> getInventory(String email) async {
	PostgreSql dbConn = await dbManager.getConnection();

	String queryString = "SELECT * FROM inventories JOIN users ON users.id = user_id WHERE users.email = @email";
	List<InventoryV2> inventories = await dbConn.query(queryString, InventoryV2, {'email':email});

	InventoryV2 inventory = new InventoryV2();
	if (inventories.length > 0) {
		inventory = inventories.first;
	}

	dbManager.closeConnection(dbConn);
	return inventory;
}