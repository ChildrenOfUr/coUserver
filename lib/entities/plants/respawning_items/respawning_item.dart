part of entity;

abstract class RespawningItem extends Plant {
	String itemType;
	Duration respawnTime;

	RespawningItem(String id, num x, num y, num z, String streetName) : super(id, x, y, z, streetName) {
		actions.add(
			new Action.withName('pick up')
				..actionWord = 'picking up'
				..description = 'Take it for yourself'
		);

		state = 0;
		maxState = 0;
	}

	@override
	void update({bool simulateTick: false}) {
		if (hidden && respawn.isBefore(new DateTime.now())) {
			// Respawn now
			show();
			respawn = null;
		}
	}

	@override
	Map<String,String> getPersistMetadata() => super.getPersistMetadata()
		..['respawn'] = respawn.toString();

	@override
	void restoreState(Map<String, String> metadata) {
		super.restoreState(metadata);

		try {
			respawn = DateTime.parse(metadata["respawn"]);
		} catch (_) {
			respawn = new DateTime.now();
		}
	}

	bool get hidden => (respawn != null);

	void show() {
		state = 0;
		setActionEnabled('pickUp', true);
	}

	void hide([Duration respawnTime]) {
		// Default to the class-defined respawn time if one is not set here
		if (respawnTime == null && this.respawnTime != null) {
			respawnTime = this.respawnTime;
		}

		state = maxState + 1;
		setActionEnabled('pickUp', false);

		if (respawnTime != null) {
			respawn = new DateTime.now().add(respawnTime);
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
