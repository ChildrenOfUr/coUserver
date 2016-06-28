part of item;

abstract class NewPlayerPack {
	Future<bool> openPack({String streetName, Map map, WebSocket userSocket, String email, String username}) async {
		int slot = map['slot'];
		int subSlot = map['subSlot'];
		if (slot == null || subSlot == null) {
			return false;
		}

		InventoryV2 inv = await getInventory(email);
		Item itemInSlot = await inv.getItemInSlot(slot, subSlot, email);

		if (await InventoryV2.takeItemFromUser(email, slot, subSlot, 1) == null) {
			return false;
		}

		//give the user all the common items
		await InventoryV2.addItemToUser(email, 'coffee', 10);
		await InventoryV2.addItemToUser(email, 'spinach', 5);
		await InventoryV2.addItemToUser(email, 'awesome_stew', 3);
		await InventoryV2.addItemToUser(email, 'emotional_bear', 1);
		await InventoryV2.addItemToUser(email, 'sneezing_powder', 1);

		//give the user the specific egg item
		if (itemInSlot.itemType == 'new_player_pack_butterfly') {
			await InventoryV2.addItemToUser(email, 'butterfly_egg', 1);
		} else if (itemInSlot.itemType == 'new_player_pack_chicken') {
			await InventoryV2.addItemToUser(email, 'chicken_egg', 1);
		} else if (itemInSlot.itemType == 'new_player_pack_piggy') {
			await InventoryV2.addItemToUser(email, 'piggy_egg', 1);
		}

		return true;
	}
}