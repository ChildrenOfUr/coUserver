part of entity;

class SnoConeVendingMachine extends Vendor {
	int openCount = 0;

	SnoConeVendingMachine(String id, String streetName, String tsid, int x, int y) : super(id, streetName, tsid, x, y) {
		type = 'Sno Cone Vending Machine';
		itemsForSale = [
			items["snocone_blue"].getMap(),
			items["snocone_green"].getMap(),
			items["snocone_orange"].getMap(),
			items["snocone_red"].getMap(),
			items["snocone_purple"].getMap(),
		];
		itemsPredefined = true;
		speed = 40;
		states = {
			"attract": new Spritesheet(
				"attract",
				"http://childrenofur.com/assets/entityImages/npc_sno_cone_vending_machine__x1_attract_png_1354830747.png",
				940,
				1547,
				188,
				221,
				34,
				true),
			"idle_stand": new Spritesheet(
				"idle_stand",
				"http://childrenofur.com/assets/entityImages/npc_sno_cone_vending_machine__x1_idle_stand_png_1354830751.png",
				940,
				2873,
				188,
				221,
				62,
				true),
			"talk": new Spritesheet(
				"talk",
				"http://childrenofur.com/assets/entityImages/npc_sno_cone_vending_machine__x1_talk_png_1354830743.png",
				940,
				884,
				188,
				221,
				20,
				false),
			"walk_end": new Spritesheet(
				"walk_end",
				"http://childrenofur.com/assets/entityImages/npc_sno_cone_vending_machine__x1_walk_end_png_1354830741.png",
				940,
				884,
				188,
				221,
				14,
				false),
			"walk_left": new Spritesheet(
				"walk_left",
				"http://childrenofur.com/assets/entityImages/npc_sno_cone_vending_machine__x1_walk_left_png_1354830740.png",
				752,
				442,
				188,
				221,
				7,
				true),
			"walk_right": new Spritesheet(
				"walk_right",
				"http://childrenofur.com/assets/entityImages/npc_sno_cone_vending_machine__x1_walk_right_png_1354830737.png",
				752,
				442,
				188,
				221,
				7,
				true)
		};
		facingRight = true;
		currentState = states['idle_stand'];
		respawn = new DateTime.now().add(new Duration(seconds: 5));
	}

	void update() {
		if (respawn != null && respawn.compareTo(new DateTime.now()) <= 0) {
			int roll = rand.nextInt(5);
			switch (roll) {
				case 0:
				// try to attract buyers
					currentState = states['attract'];
					respawn = new DateTime.now().add(
						new Duration(milliseconds: (currentState.numFrames / 30 * 1000).toInt()));
					break;

				case 1:
				// walk for 3 seconds
					if (x >= 3800) {
						speed = -40;
						facingRight = false;
						currentState = states['walk_left'];
						respawn = new DateTime.now().add(new Duration(seconds: 3));
					} else {
						speed = 40;
						facingRight = true;
						currentState = states['walk_right'];
						respawn = new DateTime.now().add(new Duration(seconds: 3));
					}
					x += speed;
					break;

				case 2:
				case 3:
				case 4:
				// do nothing
					currentState = states['idle_stand'];
					respawn = new DateTime.now().add(new Duration(seconds: 10));
					break;
			}
			return;
		}
	}

	void buy({WebSocket userSocket, String email}) {
		currentState = states['talk'];
		//don't go to another state until closed
		respawn = new DateTime.now().add(new Duration(days: 50));
		openCount++;

		super.buy(userSocket: userSocket, email: email);
	}

	void sell({WebSocket userSocket, String email}) {
		currentState = states['talk'];
		//don't go to another state until closed
		respawn = new DateTime.now().add(new Duration(days: 50));
		openCount++;

		super.sell(userSocket: userSocket, email: email);
	}

	void close({WebSocket userSocket, String email}) {
		openCount -= 1;
		//if no one else has them open
		if (openCount <= 0) {
			openCount = 0;
			currentState = states['idle_stand'];
			respawn = new DateTime.now().add(new Duration(seconds: 3));
		}
	}
}
