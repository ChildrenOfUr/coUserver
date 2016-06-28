part of item;

abstract class Emblem extends Object with MetabolicsChange {
	Future<bool> caress({String streetName, Map map, WebSocket userSocket, String email, String username}) async {
		int amt = rand.nextInt(10) + 5;
		StatManager.add(email, Stat.emblems_caressed);
		toast("+$amt mood for caressing", userSocket);
		return await trySetMetabolics(email, mood: amt);
	}

	Future<bool> consider({String streetName, Map map, WebSocket userSocket, String email, String username}) async {
		int amt = rand.nextInt(10) + 5;
		StatManager.add(email, Stat.emblems_considered);
		toast("+$amt energy for considering", userSocket);
		return await trySetMetabolics(email, energy: amt);
	}

	Future<bool> contemplate({String streetName, Map map, WebSocket userSocket, String email, String username}) async {
		int amt = rand.nextInt(10) + 5;
		StatManager.add(email, Stat.emblems_contemplated);
		toast("+$amt iMG for contemplating", userSocket);
		return await trySetMetabolics(email, imgMin: amt);
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
			StatManager.add(email, Stat.icons_collected);
			return true;
		}
	}
}

abstract class Icon extends Object with MetabolicsChange {
	Future<bool> tithe({String streetName, Map map, WebSocket userSocket, String email, String username}) async {
		StatManager.add(email, Stat.icons_tithed);
		return await trySetMetabolics(email, currants: -100);
	}

	Future<bool> ruminate({String streetName, Map map, WebSocket userSocket, String email, String username}) async {
		StatManager.add(email, Stat.icons_ruminated);
		return await trySetMetabolics(email, mood: 50);
	}

	Future<bool> revere({String streetName, Map map, WebSocket userSocket, String email, String username}) async {
		StatManager.add(email, Stat.icons_revered);
		return await trySetMetabolics(email, energy: 50);
	}

	Future<bool> reflect({String streetName, Map map, WebSocket userSocket, String email, String username}) async {
		return await trySetMetabolics(email, imgMin: 50);
	}
}
