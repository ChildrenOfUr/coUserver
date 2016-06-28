part of entity;

abstract class RespawningItem extends Plant {
	String itemType;

	RespawningItem(String id, num x, num y, String streetName) : super(id, x, y, streetName) {
		actions.add(
			new Action.withName('pick up')
				..actionWord = 'picking up'
				..description = 'Take it for yourself'
		);

		state = 0;
		maxState = 0;
	}

	@override
	void update() {
		if (hidden && new DateTime.now().compareTo(respawn) >= 0) {
			// Respawn now
			show();
			respawn = null;
		}
	}

	bool get hidden => (respawn != null);

	void show() {
		state = 0;
		setActionEnabled('pickUp', true);
	}

	void hide([Duration respawnIn]) {
		state = maxState + 1;
		setActionEnabled('pickUp', false);

		if (respawnIn != null) {
			respawn = new DateTime.now().add(respawnIn);
		}
	}

	Future pickUp({WebSocket userSocket, String email}) async {
		int added = await InventoryV2.addItemToUser(email, items[itemType].getMap(), 1);

		if (added == 1) {
			hide(new Duration(minutes: 1));
			return true;
		} else {
			return false;
		}
	}
}
