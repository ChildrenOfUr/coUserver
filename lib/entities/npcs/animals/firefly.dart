part of entity;

class Firefly extends NPC {
	Clock ffClock = new Clock();

	Firefly(String id, num x, num y, String streetName) : super(id, x, y, streetName) {
		actionTime = 4000;
		type = "Firefly";
		ItemRequirements itemReq = new ItemRequirements()
			..any = ['firefly_jar']
			..error = "Fireflies won't stay in your hands. You need a jar.";
		EnergyRequirements energyReq = new EnergyRequirements(energyAmount: 3)
			..error = "Chasing fireflies is hard work, so you'll need at least 3 energy.";
		actions.add(
			new Action.withName('collect')
				..timeRequired = actionTime
				..actionWord = 'chasing'
				..energyRequirements = energyReq
				..itemRequirements = itemReq
		);
		speed = 5; //pixels per second
		states = {
			"fullPath": new Spritesheet("fullPath", "http://childrenofur.com/assets/entityImages/npc_firefly__x1_fullPath_png_1354833043.png", 870, 360, 87, 40, 89, true),
			"halfPath": new Spritesheet("halfPath", "http://childrenofur.com/assets/entityImages/npc_firefly__x1_halfPath_png_1354833044.png", 870, 160, 87, 40, 40, true),
			"smallPath": new Spritesheet("smallPath", "http://childrenofur.com/assets/entityImages/npc_firefly__x1_smallPath_png_1354833044.png", 870, 80, 87, 40, 20, true)
		};
		setState("fullPath");
	}

	Future<bool> collect({WebSocket userSocket, String email}) async {
		//uncomment this bit when collection works
//		if (!(await hasRequirements('collect', email))) {
//			return false;
//		}

		// small flight path for 10 seconds
		setState("smallPath");

		// no such action yet
		return false;
	}

	update() {
		bool am = ffClock.time.contains("am");
		int hour = int.parse(ffClock.time.split(":")[0]);
		int minute = int.parse(ffClock.time.split(":")[1].substring(0, 2));
		if ((am && hour < 6) || (!am && hour > 8 && minute >= 30)) {
			// firefly time is 8:30PM to 6:00 AM

			//if respawn is in the past, it is time to choose a new animation
			if(respawn != null && new DateTime.now().compareTo(respawn) > 0) {
				// 50% chance to move the other way...gradually
				if (rand.nextInt(1) == 0) {
					facingRight = !facingRight;
				}

				switch (rand.nextInt(4)) {
					case 0:
					case 1:
						setState("fullPath");
						break;
					case 2:
					case 3:
						setState("halfPath");
						break;
					case 4:
						setState("smallPath");
				}

				// stay for 10 seconds
				int length = (10000 * (currentState.numFrames / 30 * 1000)).toInt();
				respawn = new DateTime.now().add(new Duration(milliseconds:length));
			}
		} else {
			// not firefly time
		}
	}
}