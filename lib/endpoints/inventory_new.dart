library inventory;

import 'dart:math';
import 'dart:async';
import 'dart:io';
import 'dart:convert';

import 'package:coUserver/common/util.dart';
import 'package:coUserver/common/user.dart';
import 'package:coUserver/common/identifier.dart';
import 'package:coUserver/entities/items/item.dart';
import 'package:coUserver/quests/quest.dart';
import 'package:coUserver/streets/player_update_handler.dart';
import 'package:coUserver/streets/street_update_handler.dart';

import 'package:jsonx/jsonx.dart' as jsonx;
import 'package:redstone_mapper/mapper.dart';
import 'package:redstone/redstone.dart' as app;
import 'package:redstone_mapper/plugin.dart';
import 'package:redstone_mapper_pg/manager.dart';

Type listOfSlots = const jsonx.TypeHelper<List<Slot>>().type;

///private class for sorting slots by durability used
class DurabilitySlot implements Comparable<DurabilitySlot> {
	num percentRemaining = 100;
	int slot, subSlot;

	DurabilitySlot(this.percentRemaining, this.slot, {this.subSlot: -1});

	@override
	int compareTo(DurabilitySlot other) {
		return percentRemaining.compareTo(other.percentRemaining);
	}

	@override
	String toString() => "Durability $percentRemaining% in $slot.$subSlot";
}

class Slot {
	//a new instance of a Slot is empty by default
	@Field() String itemType = "";
	@Field() int count = 0;
	@Field() Map<String, String> metadata = {};

	/// Create a slot from type, count, and metadata
	Slot({this.itemType: '', this.count: 0, this.metadata: const {}});

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
	Map get map {
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
			return "Empty inventory slot";
		} else {
			return "Inventory slot containing $count x $itemType with metadata: $metadata";
		}
	}

	bool operator ==(Slot other) {
		return (
			itemType == other.itemType &&
			count == other.count &&
			metadata.toString() == other.metadata.toString()
		);
	}
}

@app.Group("/inventory")
class InventoryV2 {
	// Email to list of locks
	static Map<String,List<String>> inventoryLocked = {};
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
			if (slot.itemType == null) {
				slot.itemType = "";
				slot.count = 0;
				slot.metadata = {};
			}
		});
		return s;
	}

	@override
	String toString() {
		String output = '{\n';
		for(Slot slot in slots) {
			output += '  $slot\n';
		}
		output += '}';
		return output;
	}

	//do not make a setter for slots it is a convenience field only

	// Private Methods ////////////////////////////////////////////////////////////////////////////

//	 Might need this
//	void _upgradeItems() {
//		List<Map> slots = JSON.decode(inventory_json);
//		List<Map> newSlots = [];
//		for(Map slot in slots) {
//			if(slot['itemType'] == null) {
//				slot['itemType'] = "";
//			}
//			if(slot['count'] == null) {
//				slot['count'] = 0;
//			}
//			if(slot['metadata'] == null) {
//				slot['metadata'] = {};
//			}
//			newSlots.add(slot);
//		}
//		inventory_json = JSON.encode(newSlots);
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
//			//make sure it totals 10 slots
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
	 * newContents. If newContents is not provided,
	 * the slot will be emptied.
	 * No checking is done for existing slot data, so if you
	 * want to make sure the slot is empty before replacing it,
	 * use Inventory.slots[index].isEmpty first.
	 */
	Slot changeSlot(int index, int subIndex, Slot newContents, {bool merge: true}) {
		//we're putting it into a bag
		if (subIndex > -1) {
			return _changeBagSlot(index, subIndex, newContents, merge: merge);
		}

		// Get the old slot data
		List<Slot> list = slots;

		// Merge them
		Slot origContents = list[index];
		Slot returnSlot = origContents;
		Item origItem = items[origContents.itemType];
		if (merge && origContents.itemType == newContents.itemType) {
			int roomRemaining = origItem.stacksTo - origContents.count;
			int addNum = min(roomRemaining, newContents.count);

			origContents.count += addNum;
			newContents.count -= addNum;
			list[index] = origContents;

			returnSlot = newContents;
			if(returnSlot.count == 0) {
				returnSlot.empty = true;
			}
		} else {
			list[index] = newContents;
		}

		// Save the new inventory slot data
		inventory_json = jsonx.encode(list);
		return returnSlot;
	}

	/**
	 * Replace a slot (bagSlotIndex) of a bag (bagIndex)
	 * in the inventory with the specified newContents.
	 * If newContents is not provided, the slot will be emptied.
	 * No checking is done for existing slot data, so if you
	 * want to make sure the slot is empty before replacing it,
	 * use Inventory.slots[index].isEmpty first.
	 */
	Slot _changeBagSlot(int bagIndex, int bagSlotIndex, Slot newContents, {bool merge: true}) {
		if (newContents != null) {
			Item newItem = items[newContents.itemType];
			if (newContents.itemType != null &&
			    newItem != null && newItem.isContainer) {
				return null;
			}
			if (!items[slots[bagIndex].itemType].filterAllows(itemType: newContents.itemType)) {
				return null;
			}
		}

		// Read down the slot tree
		List<Slot> invSlots = slots; // Hotbar
		Slot bagSlot = invSlots[bagIndex]; // Bag in hotbar
		List<Slot> bagSlots;
		if (bagSlot.metadata["slots"] == null) {
			// If the bag has no slot data (newly created),
			// fill it with empty slots
			bagSlots = _generateEmptySlots(items[bagSlot.itemType].subSlots);
		} else {
			// If the bag already has slot data,
			// load it into the list
			bagSlots = jsonx.decode(bagSlot.metadata["slots"], type: listOfSlots);
		}

		// Bag contents
		Slot origContents = bagSlots[bagSlotIndex]; // Slot inside bag
		Slot returnSlot = origContents;
		Item origItem = items[origContents.itemType];
		if (merge && origContents.itemType == newContents.itemType) {
			int roomRemaining = origItem.stacksTo - origContents.count;
			int addNum = min(roomRemaining, newContents.count);

			origContents.count += addNum;
			newContents.count -= addNum;
			bagSlots[bagSlotIndex] = origContents;

			returnSlot = newContents;
			if(returnSlot.count == 0) {
				returnSlot.empty = true;
			}
		} else {
			// Change out the bag slot
			bagSlots[bagSlotIndex] = newContents; // Slot inside bag
		}

		// Save up the slot tree
		bagSlot.metadata["slots"] = jsonx.encode(bagSlots); // Bag contents
		invSlots[bagIndex] = bagSlot; // Bag in hotbar
		inventory_json = jsonx.encode(invSlots); // Hotbar
		return returnSlot;
	}

	List<Slot> _generateEmptySlots([int amt]) {
		List<Slot> slots = [];

		for (int i = 1; i <= amt; i++) {
			slots.add(new Slot());
		}

		return slots;
	}

	/**
	 * Updates the inventory's JSON representation
	 * with its current slot contents.
	 */
	void updateJson() {
		if (slots is List) {
			inventory_json = jsonx.encode(slots);
		}
	}

	int toMerge, merged;

	Future<int> _addItem(Map itemMap, int count, String email) async {
		//instantiate an item object based on the map
		Item item = jsonx.decode(JSON.encode(itemMap), type: Item);

		if (item.isContainer && item.metadata['slots'] == null) {
			List<Slot> emptySlots = [];
			for (int i = 0; i < item.subSlots; i++) {
				emptySlots.add(new Slot());
			}
			item.metadata['slots'] = jsonx.encode(emptySlots);
		}

		// Keep a record of how many items we have merged into slots already,
		// and how many more need to find homes
		toMerge = count;
		merged = 0;

		// Go through entire inventory and try to find a slot that either:
		// a) has the same type of item in it and is not a full stack, or
		// b) is a specialized container that can accept this item
		// c) is empty and can accept at least [count] of item
		// d) is a generic container and has an available slot
		List<Slot> tmpSlots = slots;

		//check for same itemType already existing in a bag
		for (Slot slot in tmpSlots) {
			if (toMerge == 0) {
				break;
			}

			Item slotItem = items[slot.itemType];
			if (slotItem == null) {
				continue;
			}
			if (slotItem.isContainer && !item.isContainer &&
			    _bagContains(slot, item.itemType)) {
				List<Slot> innerSlots = _getModifiedBag(slot, item);
				slot.metadata['slots'] = jsonx.encode(innerSlots);
			}
		}

		//check for same itemType already existing on the slot bar
		for (Slot slot in tmpSlots) {
			if (toMerge == 0) {
				break;
			}

			// If not, decide if we can merge into the slot
			if (slot.itemType == item.itemType && slot.count < item.stacksTo &&
			    slot.metadata.length == 0) {
				slot = _getModifiedSlot(slot, item);
			}
		}

		//check for specialized bag
		for (Slot slot in tmpSlots) {
			Item slotItem = items[slot.itemType];
			if (slotItem == null) {
				continue;
			}
			if (toMerge == 0) {
				break;
			}

			if (slotItem.isContainer && !item.isContainer &&
			    slotItem.filterAllows(itemType: item.itemType) &&
			    slotItem.subSlotFilter.length != 0) {
				List<Slot> innerSlots = _getModifiedBag(slot, item);
				slot.metadata['slots'] = jsonx.encode(innerSlots);
			}
		}

		//check for emtpy slot in one of the 10
		for (Slot slot in tmpSlots) {
			if (toMerge == 0) {
				break;
			}

			if (slot.itemType.isEmpty || slot.count == 0) {
				slot = _getModifiedSlot(slot, item);
			}
		}

		//check for a generic bag in which we can merge
		for (Slot slot in tmpSlots) {
			if (toMerge == 0) {
				break;
			}

			Item slotItem = items[slot.itemType];
			if (slotItem == null) {
				continue;
			}
			if (slotItem.isContainer && !item.isContainer &&
			    slotItem.subSlotFilter.length == 0) {
				List<Slot> innerSlots = _getModifiedBag(slot, item);
				slot.metadata['slots'] = jsonx.encode(innerSlots);
			}
		}

		inventory_json = jsonx.encode(tmpSlots);

		if (toMerge > 0) {
			Log.verbose('[InventoryV2] Cannot give ${item.itemType} x $count because <email=$email> ran out of slots before all items were added.');
			Identifier playerId = PlayerUpdateHandler.users[await User.getUsernameFromEmail(email)];
			if(playerId != null) {
				item.putItemOnGround(playerId.currentX+40, playerId.currentY, playerId.currentStreet, count: toMerge);
				Log.verbose('[InventoryV2] $toMerge ${item.itemType}(s) dropped.');
			}
		}

		await _updateDatabase(email);

		return merged;
	}

	bool _bagContains(Slot slot, String itemType) {
		List<Slot> innerSlots;
		if (slot.metadata.containsKey('slots')) {
			innerSlots = jsonx.decode(slot.metadata['slots'], type: listOfSlots);
		}

		for(Slot s in innerSlots) {
			if(s.itemType == itemType) {
				return true;
			}
		}

		return false;
	}

	Slot _getModifiedSlot(Slot slot, Item item) {
		bool emptySlot = false;
		if (slot.itemType.isEmpty || slot.count == 0) {
			emptySlot = true;
		}

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

		return slot;
	}

	List<Slot> _getModifiedBag(Slot slot, Item item) {
		List<Slot> innerSlots;
		Item slotItem = items[slot.itemType];

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
			bool canMerge = false,
				emptySlot = false;

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

		return innerSlots;
	}

	Future _updateDatabase(String email) async {
		PostgreSql dbConn = await dbManager.getConnection();

		try {
			String queryString = "UPDATE inventories SET inventory_json = @inventory_json WHERE user_id = @user_id";
			int numRowsUpdated = await dbConn.execute(queryString, this);

			if (numRowsUpdated <= 0) {
				String query = "SELECT * FROM users WHERE email = @email";
				User user = (await dbConn.query(query, User, {'email': email})).first;
				this.user_id = user.id;
				queryString = "INSERT INTO inventories(inventory_json, user_id) VALUES(@inventory_json,@user_id)";
				numRowsUpdated = await dbConn.execute(queryString, this);

				//player just got their first item, let's tell them about bags
				QuestEndpoint.questLogCache[email].offerQuest('Q8');
			}

			return numRowsUpdated;
		} catch (e, st) {
			Log.error('Could not update inventory', e, st);
		} finally {
			dbManager.closeConnection(dbConn);
		}
	}

	Future<Item> _takeItem(int slot, int subSlot, int count, String email, {bool simulate: false}) async {
		try {
			List<Slot> tmpSlots = slots;
			Slot toModify = tmpSlots.elementAt(slot);
			Slot dropped;

			//if we're taking from a bag
			if (subSlot > -1) {
				List<Slot> bagSlots = jsonx.decode(toModify.metadata['slots'], type: listOfSlots);
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
				tmpSlots.removeAt(slot);
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

			if (!simulate) {
				inventory_json = jsonx.encode(tmpSlots);
				await _updateDatabase(email);
			}

			if(dropped.itemType == null || dropped.itemType == '') {
				return null;
			}

			Item droppedItem = new Item.clone(dropped.itemType);
			droppedItem.metadata = dropped.metadata;
			return droppedItem;
		} catch(e) {
			return null;
		}
	}

	Future<int> _takeAnyItems(String itemType, int count, String email, {bool simulate: false}) async {
		Map itemMap = items[itemType]?.getMap();
		if (itemMap == null) {
			Log.warning('Could not get item from type $itemType');
			return 0;
		}

		Item item = jsonx.decode(JSON.encode(itemMap), type: Item);
		// Keep a record of how many items we have taken from slots already,
		// and how many more we need to remove
		int toGrab = count,
			grabbed = 0;

		// Go through entire inventory and try to find a slot that has this item,
		// and continue until all are taken
		List<Slot> tmpSlots = slots;
		for (Slot slot in tmpSlots) {
			// Check if we are done taking, then stop looping
			if (toGrab == 0) {
				break;
			}

			Item slotItem = items[slot.itemType];
			if (slotItem == null) {
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

					int have = slot.count,
						diff;

					if (have >= toGrab) {
						diff = toGrab;
						slot.count -= toGrab;
					} else {
						diff = have;
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

			//skip containers that are not empty
			if(item.isContainer) {
				if (slot.metadata.containsKey('slots')) {
					List<Slot> innerSlots = jsonx.decode(slot.metadata['slots'], type: listOfSlots);
					bool isEmpty = true;
					for (Slot innerSlot in innerSlots) {
						if(innerSlot.itemType != null || innerSlot.itemType != '') {
							isEmpty = false;
						}
					}
					if(!isEmpty) {
						continue;
					}
				}
			}

			int have = slot.count,
				diff;

			if (have >= toGrab) {
				diff = toGrab;
				slot.count -= toGrab;
			} else {
				diff = have;
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
			if (!simulate) {
				Log.warning('[InventoryV2] Cannot take ${item.itemType} x $count because the user ran out of slots before all items were taken. $toGrab items skipped.');
			}
			return 0;
		} else {
			if (!simulate) {
				inventory_json = jsonx.encode(tmpSlots);
				await _updateDatabase(email);
			}
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
							Map<String,String> fixedMeta = {};
							bagSlot.metadata.forEach((String key, dynamic value) {
								fixedMeta[key] = value.toString();
							});
							bagItem.metadata = fixedMeta;
						}
						Map bagSlotMap = {
							'itemType':bagSlot.itemType,
							'item':encode(bagItem),
							'count':bagSlot.count
						};
						bagSlotMaps.add(bagSlotMap);
					});
//					print('num slots (should be): ${item.subSlots}');
//					print('num slots (is)       : ${bagSlotMaps.length}');
//					int slotDiff = item.subSlots-bagSlotMaps.length;
//					for(int i=0; i<slotDiff; i++) {
//						bagSlotMaps.add({'itemType':'','item':null,'count':0});
//					}
					item.metadata['slots'] = jsonx.encode(bagSlotMaps);
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
		userSocket?.add(JSON.encode(inventoryMap));
	}

	// Public Methods /////////////////////////////////////////////////////////////////////////////

	// Return the inventory as a List<Map>, where each slot is a Map in the List
	// Can then be READ by other functions (but not written to)
	List<Map> getItems() {
		return JSON.decode(inventory_json);
	}

	bool _durabilityOk(Slot slot) {
		if (!slot.metadata.containsKey('durabilityUsed')) {
			return true;
		} else {
			int used = int.parse(slot.metadata['durabilityUsed'], onError: (String source) => 0);
			int max = items[slot.itemType].durability;
			if (items[slot.itemType].durability == null) {
				return true;
			} else {
				return (used < max);
			}
		}
	}

	// Returns the number of a certain item a user has
	int countItem(String itemType, {bool includeBroken: true}) {
		int count = 0;

		//count all the normal slots
		slots.forEach((Slot s) {
			if (s.itemType == itemType	&& (includeBroken || _durabilityOk(s))) {
				count += s.count;
			}
		});

		//add the bag contents
		slots.where((Slot s) => !s.itemType.isEmpty && items[s.itemType].isContainer &&
		                        items[s.itemType].subSlots != null).forEach((Slot s) {
			if (s.metadata["slots"] != null && (s.metadata["slots"]).length > 0) {
				List<Slot> bagSlots = jsonx.decode(s.metadata['slots'], type: listOfSlots);
				if (bagSlots != null) {
					bagSlots.forEach((Slot bagSlot) {
						if (bagSlot.itemType == itemType && (includeBroken || _durabilityOk(bagSlot))) {
							count += bagSlot.count;
						}
					});
				}
			}
		});

		return count;
	}

	Future<bool> _decreaseDurability(List<String> validTypes, int amount, String email) async {
		List<DurabilitySlot> possibles = [];

		List<Slot> tmpSlots = slots;
		for(String itemType in validTypes) {
			Item sample = items[itemType];
			//look in the regular slots
			int index = 0;
			for (Slot s in tmpSlots) {
				if (s.itemType != null && s.itemType == itemType) {
					int used = int.parse(s.metadata['durabilityUsed']?.toString() ?? '0');
					if(used + amount > sample.durability) {
						continue;
					}
					possibles.add(new DurabilitySlot(
						100 * ((sample.durability - used) / sample.durability),
						index));
				}
				index++;
			}
		}

		for (String itemType in validTypes) {
			Item sample = items[itemType];
			//add the bag contents
			int index = 0;
			for (Slot s in tmpSlots) {
				if (!s.itemType.isEmpty && items[s.itemType].isContainer &&
				    items[s.itemType].subSlots != null) {
					if (s.metadata["slots"] != null && (s.metadata["slots"]).length > 0) {
						List<Slot> bagSlots = jsonx.decode(s.metadata['slots'], type: listOfSlots);
						if (bagSlots != null) {
							int subIndex = 0;
							for (Slot bagSlot in bagSlots) {
								if (bagSlot.itemType != null && bagSlot.itemType == itemType) {
									int used = int.parse(bagSlot.metadata['durabilityUsed']?.toString() ?? '0');
									if(used+amount > sample.durability) {
										continue;
									}
									possibles.add(new DurabilitySlot(
										100 * ((sample.durability - used) / sample.durability),
										index, subSlot: subIndex));
								}
								subIndex++;
							}
						}
					}
				}
				index++;
			}
		}

		// remove broken tools
		possibles = possibles.where((DurabilitySlot ds) => ds.percentRemaining > 0).toList();

		if(possibles.length > 0) {
			// sort the list and pick the one with the most used already
			possibles.sort();
			DurabilitySlot mostUsed = possibles.removeAt(0);
			String newlyBroken = null;

			//write it to the tmpSlots array
			if(mostUsed.subSlot == -1) {
				Slot slotToModify = tmpSlots[mostUsed.slot];
				int used = int.parse(slotToModify.metadata['durabilityUsed']?.toString() ?? '0');
				used += amount;
				slotToModify.metadata['durabilityUsed'] = used.toString();
				tmpSlots[mostUsed.slot] = slotToModify;

				if (used == items[slotToModify.itemType].durability) {
					newlyBroken = items[slotToModify.itemType].name;
				}
			} else {
				//have to modify a bag slot
				Slot bag = tmpSlots[mostUsed.slot];
				List<Slot> bagSlots = jsonx.decode(bag.metadata['slots'], type: listOfSlots);
				Slot bagSlot = bagSlots[mostUsed.subSlot];
				int used = int.parse(bagSlot.metadata['durabilityUsed']?.toString() ?? '0');
				used += amount;
				bagSlot.metadata['durabilityUsed'] = used.toString();
				bagSlots[mostUsed.subSlot] = bagSlot;
				bag.metadata['slots'] = jsonx.encode(bagSlots);
				tmpSlots[mostUsed.slot] = bag;

				if (used == items[bagSlot.itemType].durability) {
					newlyBroken = items[bagSlot.itemType].name;
				}
			}

			//finally save the array as the new inventory
			inventory_json = jsonx.encode(tmpSlots);
			await _updateDatabase(email);

			if (newlyBroken != null) {
				toast("Yikes! Your $newlyBroken just broke.", StreetUpdateHandler.userSockets[email]);
			}

			return true;
		}

		return false;
	}

	static Future _wait(Duration duration) {
		Completer c = new Completer();
		new Timer(duration, () => c.complete());
		return c.future;
	}

	static Future<bool> _aquireLock(String email, String reason) async {
		int numTriesLeft = 100; //we'll throw an error after 5 seconds of trying
		if (inventoryLocked[email] != null) {
			while (inventoryLocked[email].length > 0 && numTriesLeft > 0) {
				await _wait(new Duration(milliseconds: 50));
				numTriesLeft--;
			}

			if (((inventoryLocked[email] ?? []) as List).length > 0) {
				Log.warning("Could not acquire a lock for inventory of <email=$email> for $reason because ${inventoryLocked[email]}");
				return false;
			}
		}

		inventoryLocked[email] = (inventoryLocked[email] ?? []);
		inventoryLocked[email].add(reason);
		return true;
	}

	static void _releaseLock(String email, String reason) {
		inventoryLocked[email].remove(reason);
	}

	// Static Public Methods //////////////////////////////////////////////////////////////////////
	Future<Item> getItemInSlot(int slot, int subSlot, String email) async {
		Item itemTaken = await _takeItem(slot, subSlot, 0, email, simulate: true);
		return itemTaken;
	}

	///Returns the number of items successfully added to the user's inventory
	static Future<int> addItemToUser(String email, dynamic itemTypeOrMap, int count, [String fromObject = "_self"]) async {
		Map item;
		if (itemTypeOrMap is Map) {
			item = itemTypeOrMap;
		} else if (itemTypeOrMap is String) {
			item = items[itemTypeOrMap].getMap();
		} else {
			throw new ArgumentError('Item must be an item type or item map, not ${item.runtimeType}');
		}

		if(count is! int || count < 1) {
			throw new ArgumentError('Count must be greater than or equal to 1');
		}

		if (!(await _aquireLock(email, 'addItemToUser'))) {
			return 0;
		}

		WebSocket userSocket = StreetUpdateHandler.userSockets[email];
		InventoryV2 inv = await getInventory(email);
		int added = await inv._addItem(item, count, email);
		await fireInventoryAtUser(userSocket, email, update: true);
		if (added > 0) {
			String itemType = item['itemType'];
			messageBus.publish(new RequirementProgress('getItem_$itemType', email, count: count));
			if (itemType == 'pick' || itemType == 'fancy_pick') {
    			//Dullite, Beryl and Sparkly
   			 	QuestEndpoint.questLogCache[email]?.offerQuest('Q6');
			} else if (itemType == 'cocktail_shaker') {
   			 	//Make Me Some Drinks
   			 	QuestEndpoint.questLogCache[email]?.offerQuest('Q12');
			}
		}

		_releaseLock(email, 'addItemToUser');
		return added;
	}

	static Future<Item> takeItemFromUser(String email, int slot, int subSlot, int count) async {
		if(count is! int || count < 1) {
			throw new ArgumentError('Count must be greater than or equal to 1');
		}

		if (!(await _aquireLock(email, 'takeItemFromUser'))) {
			return null;
		}

		WebSocket userSocket = StreetUpdateHandler.userSockets[email];
		InventoryV2 inv = await getInventory(email);
		Item itemTaken = await inv._takeItem(slot, subSlot, count, email);
		if (itemTaken != null) {
			await fireInventoryAtUser(userSocket, email, update: true);
		}
		_releaseLock(email, 'takeItemFromUser');
		return itemTaken;
	}

	static Future<int> takeAnyItemsFromUser(String email, String itemType, int count, {simulate: false}) async {
		if(count is! int || count < 1) {
			try {
				throw new ArgumentError('Count must be greater than or equal to 1');
			} catch (e, st) {
				Log.error('Tried to take <count=$count> <itemType=$itemType>(s) from <email=$email>', e, st);
			}
		}

		if (!(await _aquireLock(email, 'takeAnyItemsFromUser'))) {
			return 0;
		}

		WebSocket userSocket = StreetUpdateHandler.userSockets[email];
		InventoryV2 inv = await getInventory(email);
		int taken = await inv._takeAnyItems(itemType, count, email, simulate: simulate);
		if (taken == count && !simulate) {
			await fireInventoryAtUser(userSocket, email, update: true);
		}

		_releaseLock(email, 'takeAnyItemsFromUser');
		return taken;
	}

	static Future<bool> hasItem(String email, String itemType, int count) async {
		return (await takeAnyItemsFromUser(email, itemType, count, simulate:true)) >= count;
	}

	static Future<bool> hasUnbrokenItem(String email, String itemType, int count, {bool notifyIfBroken: false}) async {
		InventoryV2 inv = await getInventory(email);
		bool result = (await inv.countItem(itemType, includeBroken: false)) >= count;

		if (notifyIfBroken && !result && (await hasItem(email, itemType, count))) {
			// Player has a broken item of the same type
			toast("Your ${items[itemType].name} is broken", StreetUpdateHandler.userSockets[email]);
		}

		return result;
	}

	/**
	 * [validTypes] can be either a String or a List<String> which lists the valid
	 * item type from which to take durability.
	 * [amount] is the amount to add to the item's durabilityUsed
	 */
	static Future<bool> decreaseDurability(String email, dynamic validTypes, {int amount: 1}) async {
		assert(validTypes is String || validTypes is List<String>);

		List<String> types;
		if(validTypes is String) {
			types = [validTypes];
		} else {
			types = validTypes;
		}

		if (!(await _aquireLock(email, 'decreaseDurability'))) {
			return false;
		}

		WebSocket userSocket = StreetUpdateHandler.userSockets[email];
		InventoryV2 inv = await getInventory(email);

		bool success = await inv._decreaseDurability(types, amount, email);

		if(success) {
			await fireInventoryAtUser(userSocket, email, update: true);
		}

		_releaseLock(email, 'decreaseDurability');
		return success;
	}

	/**
	 * Adds [amount] fireflies to a jar in [email]'s inventory.
	 * Returns the number that couldn't fit.
	 */
	static Future<int> addFireflyToJar(String email, WebSocket userSocket, {int amount: 1}) async {
		int toAdd = amount;

		void _addToJar(Slot jar) {
			int inJar = int.parse(jar.metadata['fireflies'] ?? '0');
			if (toAdd < 0 && inJar >= toAdd.abs()) {
				inJar += toAdd;
				toAdd = 0;
			} else {
				while (inJar < 7 && toAdd > 0) {
					inJar++;
					toAdd--;
				}
			}
			jar.metadata['fireflies'] = inJar.toString();
		}

		if(!(await _aquireLock(email, 'addFireflyToJar'))) {
			return toAdd;
		}

		InventoryV2 inv = await getInventory(email);
		List<Slot> tmpSlots = inv.slots;
		for (Slot slot in tmpSlots) {
			// Skip empty slots
			if (slot.itemType.isEmpty) {
				continue;
			}

			// Jars in top-level slots
			if (slot.itemType == 'firefly_jar') {
				_addToJar(slot);
			}

			// Jars in bag slots
			if (items[slot.itemType].isContainer && items[slot.itemType].subSlots != null) {
				List<Slot> bagSlots = jsonx.decode((slot.metadata['slots'] ?? '[]'), type: listOfSlots) ?? [];
				for (Slot bagSlot in bagSlots.where((Slot s) => s.itemType != null && s.itemType == 'firefly_jar')) {
					_addToJar(bagSlot);
				}
				slot.metadata['slots'] = jsonx.encode(bagSlots);
			}
		}

		inv.inventory_json = jsonx.encode(tmpSlots);
		await inv._updateDatabase(email);
		await fireInventoryAtUser(userSocket, email, update: true);
		_releaseLock(email, 'addFireflyToJar');
		return toAdd;
	}

	static Future<bool> moveItem(String email, {int fromIndex: -1,
								int fromBagIndex: -1,
								int toIndex: -1,
								int toBagIndex: -1}) async {
		if (!(await _aquireLock(email, 'moveItem'))) {
			return false;
		}

		// Get the user's inventory to work on
		InventoryV2 inv = await getInventory(email);
		List<Slot> beforeSlots = inv.slots;

		//this has to be atomic so if it throws return the inventory to the original
		try {
			//swap the from and to items
			Slot newContents = inv.slots[fromIndex];
			if (fromBagIndex > -1) {
				Slot bagSlot = inv.slots[fromIndex]; // Bag in hotbar
				List<Slot> bagSlots = jsonx.decode(bagSlot.metadata["slots"], type: listOfSlots); // Bag contents
				newContents = bagSlots[fromBagIndex]; // Slot inside bag
			}
			Slot origContents = inv.changeSlot(toIndex, toBagIndex, newContents);
			if (origContents == null) {
				throw "Could not move ${newContents
					.itemType} to $toIndex.$toBagIndex within inventory";
			}
			// Move old item into other slot
			origContents = inv.changeSlot(fromIndex, fromBagIndex, origContents, merge: false);
			if (origContents == null) {
				throw "Could not move ${newContents
					.itemType} to $toIndex.$toBagIndex within inventory";
			}

			// Update the inventory
			inv.updateJson();
			// Update the database
			await inv._updateDatabase(email);

			// Update the client
			WebSocket userSocket = StreetUpdateHandler.userSockets[email];
			await InventoryV2.fireInventoryAtUser(userSocket, email, update: true);
		} catch (e, st) {
			inv.inventory_json = jsonx.encode(beforeSlots);
			Log.error('Problem moving item', e, st);
			return false;
		} finally {
			_releaseLock(email, 'moveItem');
		}

		return true;
	}

	Slot getSlot(int invIndex, [int bagIndex]) {
		if (bagIndex == null) {
			try {
				return slots[invIndex];
			} catch (e, st) {
				Log.error('Error accessing inventory slot $invIndex', e, st);
				return new Slot();
			}
		} else {
			try {
				String mdsString = slots[invIndex].metadata["slots"];
				Map<String, dynamic> mdsSlot = jsonx.decode(mdsString)[bagIndex];
				return new Slot.withMap(mdsSlot);
			} catch (e, st) {
				Log.error('Error accessing bag slot $bagIndex of inventory slot $invIndex', e, st);
				return new Slot();
			}
		}
	}
}

@app.Route("/getInventory/username/:username")
@Encode()
Future<InventoryV2> getInventoryByUsername(String username) async {
	PostgreSql dbConn = await dbManager.getConnection();

	String queryString = "SELECT * FROM inventories JOIN users ON users.id = user_id WHERE users.username = @username";
	List<InventoryV2> inventories = await dbConn.query(queryString, InventoryV2, {'username':username});

	InventoryV2 inventory = new InventoryV2();
	if (inventories.length > 0) {
		inventory = inventories.first;
	}

	dbManager.closeConnection(dbConn);
	return inventory;
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
