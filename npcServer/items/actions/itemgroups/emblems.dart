part of coUserver;

abstract class Item_Emblem {
	static Future<bool> caress(WebSocket userSocket, String email) async {
		int amt = ItemUser.rand.nextInt(10) + 5;
		StatBuffer.incrementStat("emblemsCaressed", 1);
		toast("+$amt mood for caressing", userSocket);
		return await ItemUser.trySetMetabolics(email, mood:amt);
	}

	static Future<bool> consider(WebSocket userSocket, String email) async {
		int amt = ItemUser.rand.nextInt(10) + 5;
		StatBuffer.incrementStat("emblemsConsidered", 1);
		toast("+$amt energy for considering", userSocket);
		return await ItemUser.trySetMetabolics(email, energy:amt);
	}

	static Future<bool> contemplate(WebSocket userSocket, String email) async {
		int amt = ItemUser.rand.nextInt(10) + 5;
		StatBuffer.incrementStat("emblemsContemplated", 1);
		toast("+$amt iMG for contemplating", userSocket);
		return await ItemUser.trySetMetabolics(email, img:amt);
	}

	static Future<bool> iconize(Map map, WebSocket userSocket, String email) async {
		String emblemType = map["dropItem"]["itemType"];
		String iconType = "icon_of_" + emblemType.substring(10);
		bool success1 = (await InventoryV2.takeItemFromUser(userSocket, email, emblemType, 11) == 11);
		if (!success1) {
			return false;
		}
		int success2 = await InventoryV2.addItemToUser(userSocket, email, items[iconType].getMap(), 1, "_self");
		if (success2 == 0) {
			return false;
		} else {
			StatBuffer.incrementStat("emblemsIconized", 11);
			StatBuffer.incrementStat("iconsCreated", 1);
			return true;
		}
	}
}