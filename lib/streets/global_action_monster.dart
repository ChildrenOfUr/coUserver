part of street_update_handler;

class GlobalActionMonster {
	static Future<bool> pickup({WebSocket userSocket, String email, String username, List<String> pickupIds, String streetName}) async {
		//check that they're all the same type and that their metadata
		//is all empty or else they aren't eligible for mass pickup
		String type;
		bool allEligible = true;
		for (String id in pickupIds) {
			Item item = StreetUpdateHandler.streets[streetName].groundItems[id];
			if (type == null) {
				type = item.itemType;
			} else if (type != item.itemType) {
				allEligible = false;
				break;
			} else if (item.metadata.isNotEmpty) {
				allEligible = false;
				break;
			}
		}

		if (allEligible) {
			StreetUpdateHandler.streets[streetName].groundItems[pickupIds.first]
				.pickup(email: email, count: pickupIds.length);
			for (String id in pickupIds) {
				StreetUpdateHandler.streets[streetName].groundItems[id].onGround = false;
			}
		}

		return true;
	}

	static Future<bool> teleport({WebSocket userSocket, String email, String tsid, bool energyFree: false}) async {
		if (!energyFree) {
			Metabolics m = await getMetabolics(email: email);
			if (m.user_id == -1 || m.energy < 50) {
				return false;
			} else {
				m.energy -= 50;
				int result = await setMetabolics(m);
				if (result < 1) {
					return false;
				}
			}
		}

		userSocket.add(JSON.encode({
			"gotoStreet": "true",
			"tsid": tsid
		}));

		return true;
	}

	static Future<bool> moveItem({WebSocket userSocket, String email, int fromIndex: -1, int fromBagIndex: -1, int toBagIndex: -1, int toIndex: -1}) async {
		if (fromIndex == -1 || toIndex == -1) {
			//something's wrong
			return false;
		}

		return await InventoryV2.moveItem(email,
			fromIndex: fromIndex, toIndex: toIndex, fromBagIndex: fromBagIndex, toBagIndex: toBagIndex);
	}

	static Future writeNote({WebSocket userSocket, String email, Map noteData}) async {
		Map newNote = await NoteManager.addFromClient(noteData);
		userSocket.add(JSON.encode({
			"note_response": newNote
		}));

		InventoryV2.decreaseDurability(email, NoteManager.tool_item);
	}

	static Future feed2({WebSocket userSocket, String email, String itemType, int count, int slot, int subSlot}) async =>
		BabyAnimals.feed2(userSocket: userSocket, email: email,
			itemType: itemType, count: count, slot: slot, subSlot: subSlot);

	static Future changeClientUsername({WebSocket userSocket, String email, String oldUsername, String newUsername}) async =>
		changeUsername(oldUsername: oldUsername, newUsername: newUsername, userSocket: userSocket);

	static void profile({WebSocket userSocket, String email, String username}) {
		userSocket.add(JSON.encode({
			'open_profile': username
		}));
	}

	static void follow({WebSocket userSocket, String email, String username}) {
		userSocket.add(JSON.encode({
			'follow': username
		}));
	}
}
