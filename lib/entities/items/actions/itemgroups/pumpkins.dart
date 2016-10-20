part of item;

abstract class Pumpkins extends Object with MetabolicsChange {
	Future<bool> illuminatePumpkin({String streetName, Map map, WebSocket userSocket, String email, String username}) async {
		bool success = (await InventoryV2.addFireflyToJar(email, userSocket, amount: -5)) == 0;

		if (success) {
			Item pumpkin = await InventoryV2.takeItemFromUser(email, map['slot'], map['subSlot'], 1);
			String lanternType = pumpkin.itemType.replaceAll('_the_pumpkin', '_o_lantern');
			await InventoryV2.addItemToUser(email, lanternType, 1);
		} else {
			toast("Sorry, you need more fireflies to light this up", userSocket);
		}

		return success;
	}
}
