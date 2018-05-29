part of entity;

class Batterfly extends NPC {
	int currentBob = 0,
		minBob = -50,
		maxBob = 50;
	bool bobbingUp = true;

	Batterfly(String id, num x, num y, num z, num rotation, bool h_flip, String streetName) : super(id, x, y, z, rotation, h_flip, streetName) {
		type = "Batterfly";
		speed = 75; //pixels per second
		renameable = true;
		actions.add(
			new Action.withName('feed')
				..actionWord = 'feeding'
		);
		states = {
			"chew": new Spritesheet(
				"chew",
				"https://childrenofur.com/assets/entityImages/npc_batterfly__x1_chew_png_1354831854.png",
				999,
				1344,
				111,
				96,
				120,
				false),
			"front_turned": new Spritesheet(
				"front_turned",
				"https://childrenofur.com/assets/entityImages/npc_batterfly__x1_front_turned_png_1354831847.png",
				888,
				480,
				111,
				96,
				40,
				true),
			"front_waiting": new Spritesheet(
				"front_waiting",
				"https://childrenofur.com/assets/entityImages/npc_batterfly__x1_front_waiting_png_1354831849.png",
				888,
				480,
				111,
				96,
				40,
				true),
			"fly_profile": new Spritesheet(
				"fly_profile",
				"https://childrenofur.com/assets/entityImages/npc_batterfly__x1_profile_png_1354831844.png",
				888,
				480,
				111,
				96,
				40,
				true),
			"fly_profile_turned": new Spritesheet(
				"fly_profile_turned",
				"https://childrenofur.com/assets/entityImages/npc_batterfly__x1_profile_turned_png_1354831846.png",
				888,
				480,
				111,
				96,
				40,
				true)
		};
		setState("fly_profile");
		facingRight = true;
	}

	Future<bool> feed({WebSocket userSocket, String email}) async {
		Map map = {};
		map['id'] = id;
        map['action'] = "feedItem";
		map['openWindow'] = 'itemChooser';
		map['filter'] = 'consumeValues={.*energy:.*}';
		map['windowTitle'] = 'Feed Batterfly What?';
		userSocket.add(jsonEncode(map));
		return true;
	}

	Future<bool> feedItem({WebSocket userSocket, String itemType, int count, String email, int slot, int subSlot}) async {
		bool success = (await InventoryV2.takeAnyItemsFromUser(email, itemType, count)) != null;
		if(!success) {
			return false;
		}


		int energyWorth = (items[itemType].consumeValues['energy'] ?? 0) * count;
		int guanoCount = 0;
		if(energyWorth >= 15 && energyWorth < 50) {
			guanoCount = 1;
		} else if (energyWorth >= 50 && energyWorth < 100) {
			guanoCount = 2;
		} else if (energyWorth >= 100) {
			guanoCount = 3;
		}

		for (int i=0; i<guanoCount; i++) {
			Item item = new Item.clone('guano');
			item.putItemOnGround(x,y,streetName);
		}

		setState('chew', repeat:2);
		return true;
	}

	update({bool simulateTick: false}) {
		super.update();

		if (currentState.stateName.contains("fly")) {
			moveXY(yAction: () {
				// bob up and down a bit
				if (bobbingUp) {
					y--;
					currentBob--;
					if (currentBob < minBob) {
						bobbingUp = false;
					}
				} else {
					y++;
					currentBob++;
					if (currentBob > maxBob) {
						bobbingUp = true;
					}
				}
			}, ledgeAction: () {});
		}

		//if respawn is in the past, it is time to choose a new animation
		if (respawn != null && new DateTime.now().compareTo(respawn) > 0) {
			//1 in 4 chance to change direction
			if (rand.nextInt(4) == 1) {
				facingRight = !facingRight;
			}

			setState('fly_profile', repeat: rand.nextInt(5));
		}
	}
}
