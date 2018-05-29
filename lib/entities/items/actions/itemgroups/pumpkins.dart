part of item;

abstract class Pumpkins {
	Future<bool> illuminatePumpkin({String streetName, Map map, WebSocket userSocket, String email, String username}) async {
		bool success = (await InventoryV2.addFireflyToJar(email, userSocket, amount: -5)) == 0;

		if (success) {
			Item pumpkin = await InventoryV2.takeItemFromUser(email, map['slot'], map['subSlot'], 1);
			String lanternType;
			if (pumpkin.itemType == 'hello_pumpkin') {
				lanternType = 'shiny_hello_pumpkin';
			} else {
				lanternType = pumpkin.itemType.replaceAll('_the_pumpkin', '_o_lantern');
			}
			await InventoryV2.addItemToUser(email, lanternType, 1);
		} else {
			toast("Sorry, you need more fireflies to light this up", userSocket);
		}

		return success;
	}

	Future<bool> smash({String streetName, Map map, WebSocket userSocket, String email, String username}) async {
		bool success = (await InventoryV2.takeItemFromUser(email, map['slot'], map['subSlot'], 1)) != null;

		if (success) {
			int amount = rand.nextInt(8) + 3;
			await InventoryV2.addItemToUser(email, 'roasted_pepitas', amount);
		}

		return success;
	}
}
