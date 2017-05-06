part of entity;

class Salmon extends NPC {
	Salmon(String id, num x, num y, num z, num rotation, bool h_flip, String streetName) : super(id, x, y, z, rotation, h_flip, streetName) {
		actions.add(
			new Action.withName('pocket')
				..actionWord = 'pocketing'
				..description = 'Put in pocket'
				..energyRequirements = new EnergyRequirements(energyAmount: 4)
		);
		type = "Salmon";
		renameable = true;
		speed = 35;
		ySpeed = 0;
		states = {
			"swimDown15": new Spritesheet(
				"swimRightDown15",
				"https://childrenofur.com/assets/entityImages/npc_salmon__x1_swimRightDown15_png_1354840510.png",
				649,
				74,
				59,
				37,
				22,
				true),
			"swimDown30": new Spritesheet(
				"swimRightDown30",
				"https://childrenofur.com/assets/entityImages/npc_salmon__x1_swimRightDown30_png_1354840511.png",
				649,
				74,
				59,
				37,
				22,
				true),
			"swimUp15": new Spritesheet(
				"swimRightUp15",
				"https://childrenofur.com/assets/entityImages/npc_salmon__x1_swimRightUp15_png_1354840509.png",
				649,
				74,
				59,
				37,
				22,
				true),
			"swimUp30": new Spritesheet(
				"swimRightUp30",
				"https://childrenofur.com/assets/entityImages/npc_salmon__x1_swimRightUp30_png_1354840509.png",
				649,
				74,
				59,
				37,
				22,
				true),
			"swim": new Spritesheet(
				"swimRight",
				"https://childrenofur.com/assets/entityImages/npc_salmon__x1_swimRight_png_1354840508.png",
				649,
				74,
				59,
				37,
				22,
				true),
			"turn": new Spritesheet(
				"turnRight",
				"https://childrenofur.com/assets/entityImages/npc_salmon__x1_turnRight_png_1354840511.png",
				649,
				37,
				59,
				37,
				11,
				false),
			"gone": new Spritesheet(
				"gone",
				"https://childrenofur.com/assets/entityImages/blank.png",
				1,
				1,
				1,
				1,
				1,
				false)
		};
		setState("swim");
		//50/50 chance to face left or right to start
		facingRight = rand.nextInt(2) == 1;
	}

	void update({bool simulateTick: false}) {
		super.update();

		moveXY(yAction: () {
			y += ySpeed~/NPC.updateFps;
		}, ledgeAction: () {});

		if (respawn != null && respawn.compareTo(new DateTime.now()) <= 0) {
			// if we just turned, we should say we're facing the other way, then we should start moving (that's why we turned around after all)
			if (currentState.stateName == 'turn') {
				// if we turned left, we are no longer facing right, etc.
				facingRight = !facingRight;
				// start swimming left
				setState('swim');
			} else {
				//sometimes move around
				int roll = rand.nextInt(10);
				switch (roll) {
					case 0:
					case 1:
					// turn around
						setState('turn');
						ySpeed = 0;
						break;

					case 2:
					// swim up (steeply)
						setState('swimUp30');
						ySpeed = -75;
						break;

					case 3:
					// swim up (unholy)
						setState('swimUp15');
						ySpeed = -40;
						break;

					case 4:
					// swim down (steeply)
						setState('swimDown30');
						ySpeed = 75;
						break;

					case 5:
					// swim down (unholy)
						setState('swimDown15');
						ySpeed = 40;
						break;
				}
			}
		}
	}

	Future<bool> pocket({WebSocket userSocket, String email}) async {
		if (currentState == states['gone']) return false;
		bool success = await super.trySetMetabolics(email, energy: -4, imgMin: 1, imgRange: 5);
		if (!success) return false;

		// 50% chance to get a pocket salmon
		// 50% chance to let it slip out of your hands, you only catch a bubble
		if (new Random().nextInt(2) == 1) {
			await InventoryV2.addItemToUser(email, items['pocket_salmon'].getMap(), 1, id);
			StatManager.add(email, Stat.salmon_pocketed);
			setState("gone");
			respawn = new DateTime.now().add(new Duration(minutes: 2));
			return true;
		} else {
			await InventoryV2.addItemToUser(email, items['salmon_bubble'].getMap(), 1, id);
			say("You missed me, but you managed to grab a bubble.");
			return false;
		}
	}
}
