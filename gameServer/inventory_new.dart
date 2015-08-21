part of coUserver;

@app.Group("/inventory")
class InventoryV2 {

	// Globals ////////////////////////////////////////////////////////////////////////////////////

	// Sets how many slots each player has
	final int invSize = 11;

	// Used to fill slots without items, for future use
	final Map emptySlotTemplate = {
		"itemType": "",
		"count": 0,
		"isContainer": false,
		"metadata": {}
	};

	@Field()
	int inventory_id;

	@Field()
	String inventory_json;

	@Field()
	int user_id;

	// Private Methods ////////////////////////////////////////////////////////////////////////////

	factory InventoryV2() => new InventoryV2._internal();

	InventoryV2._internal() {
		// Create a new InventoryV2
		List<Map> inventory = new List();
		// Fill it with blank slots (add on to existing ones)
		while (inventory.length < invSize) {
			inventory.add(emptySlotTemplate);
		}
		// Store as JSON
		this.inventory_json = JSON.encode(inventory);
	}

	// Might need this
//	static Future<bool> _upgradeItems() async {
//		return false;
//	}

	Future<int> _addItem(Map item, int count, String email) async {
		List<Map> inventory = JSON.decode(inventory_json);

		// Get some basic item data
		String type = item["itemType"];
		int max_stack = items[type].stacksTo;
		bool hasUsage = (items[type].durability != null) && (items[type].durability > 0);
		bool isContainer = items[type].isContainer;

		// Keep a record of how many items we have merged into slots already,
		// and how many more need to find homes
		int toMerge = count;
		int merged = 0;

		// Go through entire inventory and try to find a slot that either:
		// a) has the same type of item in it and is not a full stack, or
		// b) is empty and can accept a full stack
		// TODO: look inside container slots, but only inside bags that accept this type of item
		for (Map slot in inventory) {
			// Check if we are done merging, then stop looping
			if (toMerge == 0) {
				break;
			}

			// If not, decide if we can merge into the slot

			bool canMerge = false;
			bool emptySlot = false;

			if (slot["itemType"] == "" || slot["count"] == 0) {
				canMerge = true;
				emptySlot = true;
			}

			if (slot["itemType"] == item["itemType"] && slot["count"] < max_stack) {
				canMerge = true;
			}

			if (slot["isContainer"] && slot["subSlotFilter"].contains(type)) {
				canMerge = true;
			}

			// If this slot is suitable...
			if (canMerge) {

				// Figure out how many we can merge
				int diff = toMerge - slot["count"];

				// Don"t ever merge more than a full stack
				if (diff > max_stack) diff = max_stack;

				// Don"t merge over a stack if the slot is not empty
				if (diff + slot["count"] > max_stack) diff = max_stack - slot["count"];

				// Merge
				slot["count"] += diff;

				// Update counters and move to the next slot
				toMerge -= diff;
				merged += diff;

				// If the slot was empty, give it some data
				if (emptySlot) {
					slot["itemType"] = item["itemType"];
				}

				// Give it durability
				if (hasUsage) {
					slot["metadata"] = {
						"durability_used": item["durability_used"]
					};
				}

				// Give it empty bag slots
				if (isContainer) {
					// TODO: keep original slot contents
					while ((slot["metadata"]["slots"] as List<Map>).length < items[type].subSlots) {
						(slot["metadata"]["slots"] as List<Map>).add(emptySlotTemplate);
					}
				}

			} else {
				// If not, skip it
				continue;
			}
		}

		inventory_json = JSON.encode(inventory);

		if (toMerge > 0) {
			log("[InventoryV2] Cannot give ${item["itemType"]} x $count to user with email $email because they ran out of slots before all items were added. ${toMerge.toString()} items skipped.");
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
			if (toGrab == 0) break;

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

	static _fireInventoryAtUser(WebSocket userSocket, String email) async {
		InventoryV2 inv = await InventoryV2.getInventory(email);
		userSocket.add(inv.inventory_json);
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
		return await new InventoryV2();
		//TODO: find the user's inventory by email, instead of just an empty inventory
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