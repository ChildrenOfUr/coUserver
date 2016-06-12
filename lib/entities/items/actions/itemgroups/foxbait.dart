part of item;

class FoxBaitItem {
	Future<bool> placeBait({String streetName, Map map, WebSocket userSocket, String email, String username}) async {
		// Take item
		int taken = await InventoryV2.takeAnyItemsFromUser(email, 'fox_bait', 1);
		if (taken != 1) {
			return false;
		}

		// Create entity
		try {
			Identifier player = PlayerUpdateHandler.users[username];
			num x = player.currentX + 60;
			num y = player.currentY + 150;
			String id = createId(x, y, 'FoxBait', streetName);
			new FoxBait(id, x, y, streetName);
			return true;
		} catch (e) {
			Log.warning('placeBait failed to create entity', e);
			return false;
		}
	}
}
