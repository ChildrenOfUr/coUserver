part of coUserver;

class Slot {
	//a new instance of a Slot is empty by default
	@Field() String itemType = "";
	@Field() int count = 0;
	@Field() Map<String, dynamic> metadata = {};
}

@app.Group("/inventory")
class InventoryV2 {

	// Globals ////////////////////////////////////////////////////////////////////////////////////

	// Sets how many slots each player has
	final int invSize = 11;

	@Field() int inventory_id, user_id;
	@Field() String inventory_json = '[]';

	List<Slot> get slots {
		List<Slot> s = jsonx.decode(inventory_json, type: new jsonx.TypeHelper<List<Slot>>().type);
		while (s.length < invSize) {
			s.add(new Slot());
		}
		return s;
	}

	//do not make a setter for slots it is a convenience field only

	// Private Methods ////////////////////////////////////////////////////////////////////////////

	String _encodeJson() => jsonx.encode(slots);

//	 Might need this
	void _upgradeItems() {
		if (JSON.decode(inventory_json) is Map) {
			Map<String, int> inventoryMap = JSON.decode(inventory_json);
			List<Slot> slotsToAdd = [];

			inventoryMap.forEach((String itemType, int count) {
				Slot slot = new Slot()
					..itemType = itemType
					..count = count;
				slotsToAdd.add(slot);
			});

			//make sure it totals 11 slots
			while (slotsToAdd.length < invSize) {
				slotsToAdd.add(new Slot());
			}

			inventory_json = jsonx.encode(slotsToAdd);
		} else {
			//inventory was already upgraded
			return;
		}
	}

	Future<int> _addItem(Map itemMap, int count, String email) async {
		//instantiate an item object based on the map
		Item item = decode(itemMap, Item);
		bool hasUsage = (item.durability != null) && (item.durability > 0);

		// Keep a record of how many items we have merged into slots already,
		// and how many more need to find homes
		int toMerge = count, merged = 0;

		// Go through entire inventory and try to find a slot that either:
		// a) has the same type of item in it and is not a full stack, or
		// b) is empty and can accept at least [count] of item
		// TODO: look inside container slots, but only inside bags that accept this type of item
		for (Slot slot in slots) {
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
				if (slot.itemType == item.itemType && slot.count < item.stacksTo) {
					canMerge = true;
				}

				Item slotItem = items[slot.itemType];
				if (slotItem.isContainer && slotItem.subSlotFilter.contains(item.itemType)) {
					canMerge = true;
				}
			}

			// If this slot is suitable...
			if (canMerge) {

				// Figure out how many we can merge
				int diff = toMerge - slot.count;

				// Don"t ever merge more than a full stack
				if (diff > item.stacksTo) {
					diff = item.stacksTo;
				}

				// Don"t merge over a stack if the slot is not empty
				if (diff + slot.count > item.stacksTo) {
					diff = item.stacksTo - slot.count;
				}

				// Merge
				slot.count += diff;

				// Update counters and move to the next slot
				toMerge -= diff;
				merged += diff;

				// If the slot was empty, give it some data
				if (emptySlot) {
					slot.itemType = item.itemType;
				}

				// Give it durability
				if (hasUsage) {
					slot.metadata = {
						"durability_used": item.durabilityUsed
					};
				}

				// Give it empty bag slots
				if (item.isContainer) {
					// TODO: keep original slot contents
					while ((slot.metadata["slots"] as List<Map>).length < item.subSlots) {
						(slot.metadata["slots"] as List<Map>).add(encode(new Slot()));
					}
				}

			} else {
				// If not, skip it
				continue;
			}
		}

		inventory_json = _encodeJson();

		if (toMerge > 0) {
			log("[InventoryV2] Cannot give ${item.itemType} x $count to user with email $email because they ran out of slots before all items were added. ${toMerge.toString()} items skipped.");
		}

		return merged;
	}

	Future<int> _takeItem(Map item, int count, String email) async {
		List<Map> inventory = JSON.decode(inventory_json);

		// Keep a record of how many items we have taken from slots already,
		// and how many more we need to remove
		int toGrab = count;
		int grabbed = 0;

		// Go through entire inventory and try to find a slot that has this item,
		// and continue until all are taken
		// TODO: look inside container slots
		for (Map slot in inventory) {
			// Check if we are done taking, then stop looping
			if (toGrab == 0) {
				break;
			}

			// Skip empty slots
			if (slot["itemType"] == "" && slot["count"] == 0) {
				continue;
			}

			// Figure out how many we can take
			int diff = min(slot["count"], toGrab);

			// Take
			slot["count"] = 0;

			// Update counters and move to the next slot
			toGrab -= diff;
			grabbed += diff;

			// Delete slot data
			slot["itemType"] = "";
			slot["metadata"] = {};
		}

		inventory_json = JSON.encode(inventory);

		if (toGrab > 0) {
			log("[InventoryV2] Cannot take ${item["itemType"]} x $count from user with email $email because they ran out of slots before all items were taken. ${toGrab.toString()} items skipped.");
		}

		return grabbed;
	}

	static Future fireInventoryAtUser(WebSocket userSocket, String email) async {
		InventoryV2 inv = await InventoryV2.getInventory(email);
		List<Map> slotMaps = [];
		for(Slot slot in inv.slots) {
			Item item = null;
			if(slot.itemType != "") {
				item = new Item.clone(slot.itemType);
			}
			Map slotMap = {
				'itemType':slot.itemType,
				'item':encode(item),
				'count':slot.count,
				'metadata':slot.metadata
			};
			slotMaps.add(slotMap);
		}
		Map inventoryMap = {'inventory':'true', 'slots':slotMaps};
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

	@app.Route("/getInventory/:email")
	@Encode()
	static Future<InventoryV2> getInventory(String email) async {
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

	static Future<int> addItemToUser(WebSocket userSocket, String email, Map item, int count, [String fromObject = "_self"]) async {
		InventoryV2 inv = await InventoryV2.getInventory(email);
		int added = await inv._addItem(item, count, email);
		if (added == count) {
			Map send = new Map()
				..["giveItem"] = "true"
				..["item"] = encode(new Item.clone(item["itemType"]))
				..["num"] = count
				..["fromObject"] = fromObject;
			userSocket.add(JSON.encode(send));
			return count;
		} else {
			return -1;
		}
	}

	static Future<int> takeItemFromUser(WebSocket userSocket, String email, String itemType, int count) async {
		InventoryV2 inv = await InventoryV2.getInventory(email);
		int taken = await inv._takeItem(items[itemType].getMap(), count, email);
		if (taken == count) {
			Map send = new Map()
				..["takeItem"] = "true"
				..["itemType"] = itemType
				..["count"] = count;
			userSocket.add(JSON.encode(send));
			return count;
		} else {
			return -1;
		}
	}
}