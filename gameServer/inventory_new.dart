part of coUserver;

Type listOfSlots = const jsonx.TypeHelper<List<Slot>>().type;

class Slot {
	//a new instance of a Slot is empty by default
	@Field() String itemType = "";
	@Field() int count = 0;
	@Field() Map metadata = {};

	/// Create a slot from type, count, and metadata
	Slot([this.itemType, this.count, this.metadata]);

	/// Create a slot from a map containg the data
	Slot.withMap(Map data) {
		itemType = data["itemType"];
		count = data["count"];
		metadata = data["metadata"];
	}

	/// Check if the slot is empty
	bool get isEmpty {
		// Fix null slots
		if (itemType == null || count == null) {
			empty = true;
		}

		return (itemType == "" || count == 0);
	}

	/// Empty the slot
	set empty(bool clear) {
		if (clear) {
			itemType = "";
			count = 0;
			metadata = {};
		}
	}

	/// Get a map representing the slot
	Map get toMap {
		return ({
			"itemType": itemType,
			"count": count,
			"metadata": metadata
		});
	}

	/// Get a human-readable string representing the slot
	@override
	String toString() {
		if (isEmpty) {
			return "Empty player inventory slot";
		} else {
			return "Player inventory slot containing $count x $itemType with metadata: $metadata";
		}
	}
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
		s.forEach((Slot slot) {
			if(slot.itemType == null) {
				slot.itemType = "";
				slot.count = 0;
				slot.metadata = {};
			}
		});
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

	/**
	 * Replace a slot in the inventory with the specified
	 * replaceWithSlot. If replaceWithSlot is not provided,
	 * the slot will be emptied.
	 * No checking is done for existing slot data, so if you
	 * want to make sure the slot is empty before replacing it,
	 * use Inventory.slots[index].isEmpty first.
	 */
	Slot changeSlot(int index, int subIndex, Slot newContents) {
		//we're putting it into a bag
		if(subIndex > -1) {
			return _changeBagSlot(index,subIndex,newContents);
		}

		// Get the old slot data
		List<Slot> list = slots;

		// Merge them
		Slot origContents = list[index];
		list[index] = newContents;

		// Save the new inventory slot data
		inventory_json = jsonx.encode(list);
		return origContents;
	}

	/**
	 * Replace a slot (bagSlotIndex) of a bag (bagIndex)
	 * in the inventory with the specified replaceWithSlot.
	 * If replaceWithSlot is not provided, the slot will be emptied.
	 * No checking is done for existing slot data, so if you
	 * want to make sure the slot is empty before replacing it,
	 * use Inventory.slots[index].isEmpty first.
	 */
	Slot _changeBagSlot(int bagIndex, int bagSlotIndex, Slot newContents) {
		try {
			// Make sure the bag accepts this item
			assert(items[slots[bagIndex].itemType].filterAllows(itemType: newContents.itemType));
		} catch(e) {
			return null;
		}

		// Read down the slot tree
		List<Slot> invSlots = slots; // Hotbar
		Slot bagSlot = invSlots[bagIndex]; // Bag in hotbar
		List<Slot> bagSlots = jsonx.decode(bagSlot.metadata["slots"], type: listOfSlots); // Bag contents
		Slot origContents = bagSlots[bagSlotIndex]; // Slot inside bag
		// Change out the bag slot
		bagSlots[bagSlotIndex] = newContents; // Slot inside bag
		// Save up the slot tree
		bagSlot.metadata["slots"] = jsonx.encode(bagSlots); // Bag contents
		invSlots[bagIndex] = bagSlot; // Bag in hotbar
		inventory_json = jsonx.encode(invSlots); // Hotbar
		return origContents;
	}

	/**
	 * Updates the inventory's JSON representation
	 * with its current slot contents.
	 */
	void updateJson() {
		inventory_json = jsonx.encode(slots);
	}

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
				if (slotItem.isContainer && !item.isContainer && slotItem.filterAllows(itemType: item.itemType)) {
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

						if (slot.isEmpty) {
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

	Future<Item> _takeItem(int slot, int subSlot, int count, String email, {bool simulate:false}) async {
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

		if(!simulate) {
			inventory_json = jsonx.encode(tmpSlots);
			await _updateDatabase(email);
		}

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
			if(slotItem == null) {
				continue;
			}
			if (slotItem.isContainer && slotItem.filterAllows(itemType: item.itemType)) {
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
					if (slot.isEmpty) {
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
						slot.empty = true;
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
			if (slot.isEmpty) {
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
				slot.empty = true;
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
			if (slot == null) {
				slot = new Slot();
			}
			if (!slot.isEmpty) {
				item = new Item.clone(slot.itemType);
				item.metadata = slot.metadata;
				if (item.isContainer && item.metadata['slots'] != null) {
					List<Slot> bagSlots = jsonx.decode(item.metadata['slots'], type: listOfSlots);
					List<Map> bagSlotMaps = [];
					bagSlots.forEach((Slot bagSlot) {
						Item bagItem = null;
						if (!bagSlot.isEmpty) {
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

	// Returns the number of a certain item a user has
	int countItem(String itemType) {
		int count = 0;

		//count all the normal slots
		slots.forEach((Slot s) {
			if(s.itemType == itemType) {
				count += s.count;
			}
		});

		//add the bag contents
		slots.where((Slot s) => !s.itemType.isEmpty && items[s.itemType].isContainer && items[s.itemType].subSlots != null).forEach((Slot s) {
			List<Slot> bagSlots = jsonx.decode(s.metadata['slots'], type: listOfSlots);
			if (bagSlots != null) {
				bagSlots.forEach((Slot bagSlot) {
					if (bagSlot.itemType == itemType) {
						count += bagSlot.count;
					}
				});
			}
		});

		return count;
	}

	// Static Public Methods //////////////////////////////////////////////////////////////////////
	Future<Item> getItemInSlot(int slot, int subSlot, String email) async {
		Item itemTaken = await _takeItem(slot, subSlot, 0, email, simulate:true);
		return itemTaken;
	}

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

	Slot getSlot(int invIndex, [int bagIndex]) {
		if (bagIndex == null) {
			try {
				return slots[invIndex];
			} catch (e) {
				log("Error accessing inventory slot $invIndex: $e");
				return new Slot();
			}
		} else {
			try {
				String mdsString = slots[invIndex].metadata["slots"];
				Map<String, dynamic> mdsSlot = jsonx.decode(mdsString)[bagIndex];
				return new Slot(mdsSlot["itemType"], mdsSlot["count"], mdsSlot["metadata"]);
			} catch (e) {
				log("Error accessing bag slot $bagIndex of inventory slot $invIndex: $e");
				return new Slot();
			}
		}
	}

	/// moveItem is in street_update_handler.dart
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