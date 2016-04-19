part of item;

// ////// //
// Emblem //
// ////// //

abstract class Emblem extends Object with MetabolicsChange {
	Future<bool> caress({String streetName, Map map, WebSocket userSocket, String email, String username}) async {
		int amt = rand.nextInt(10) + 5;
		StatBuffer.incrementStat("emblemsCaressed", 1);
		toast("+$amt mood for caressing", userSocket);
		return await trySetMetabolics(username, mood:amt);
	}

	Future<bool> consider({String streetName, Map map, WebSocket userSocket, String email, String username}) async {
		int amt = rand.nextInt(10) + 5;
		StatBuffer.incrementStat("emblemsConsidered", 1);
		toast("+$amt energy for considering", userSocket);
		return await trySetMetabolics(username, energy:amt);
	}

	Future<bool> contemplate({String streetName, Map map, WebSocket userSocket, String email, String username}) async {
		int amt = rand.nextInt(10) + 5;
		StatBuffer.incrementStat("emblemsContemplated", 1);
		toast("+$amt iMG for contemplating", userSocket);
		return await trySetMetabolics(username, imgMin:amt);
	}

	Future<bool> iconize({String streetName, Map map, WebSocket userSocket, String email, String username}) async {
		InventoryV2 inv = await getInventory(email);
		Item itemInSlot = await inv.getItemInSlot(map['slot'], map['subSlot'], email);
		String emblemType = itemInSlot.itemType;
		String iconType = "icon_of_" + emblemType.substring(10);
		bool success1 = (await InventoryV2.takeAnyItemsFromUser(email, emblemType, 11) == 11);
		if (!success1) {
			return false;
		}
		int success2 = await InventoryV2.addItemToUser(email, items[iconType].getMap(), 1);
		if (success2 == 0) {
			return false;
		} else {
			messageBus.publish(new RequirementProgress('iconGet', email));
			StatBuffer.incrementStat("emblemsIconized", 11);
			StatBuffer.incrementStat("iconsCreated", 1);
			return true;
		}
	}
}