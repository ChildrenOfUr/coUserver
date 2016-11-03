part of item;

abstract class GrainBushel {
	static final String GRAIN = 'grain';
	static final String BUSHEL = 'bushel_of_grain';
	static final int SIZE = items[GRAIN].stacksTo;

	Future<bool> bundle({String username, String streetName, String email, WebSocket userSocket, Map map}) async {
		// Take grain
		int taken = await InventoryV2.takeAnyItemsFromUser(email, GRAIN, SIZE);
		if (taken < SIZE) {
			// Not enough grain
			toast('You need $SIZE grain for a bushel', userSocket);
			return false;
		}

		// Give bushel
		int given = await InventoryV2.addItemToUser(email, BUSHEL, 1);
		return given == 1;
	}

	Future<bool> unbundle({String username, String streetName, String email, WebSocket userSocket, Map map}) async {
		// Take bushel
		Item taken = await InventoryV2.takeItemFromUser(email, map['slot'], map['subSlot'], map['count']);
		if (taken == null) {
			// Nothing taken
			toast("Forget the needle, I can't find the haystack!", userSocket);
			return false;
		}

		// Give grain
		int given = await InventoryV2.addItemToUser(email, GRAIN, SIZE);
		return given == SIZE;
	}
}