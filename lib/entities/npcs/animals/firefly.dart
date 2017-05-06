part of entity;

class Firefly extends NPC {
	static final int ENERGY_AMT = 3;

	static final ItemRequirements REQ_ITEM = new ItemRequirements()
		..any = ['firefly_jar']
		..error = "Fireflies won't stay in your hands. You need a jar.";

	static final EnergyRequirements REQ_ENERGY = new EnergyRequirements(energyAmount: ENERGY_AMT)
		..error = "Chasing fireflies is hard work, so you'll need at least 3 energy.";

	Clock ffClock = new Clock();

	Firefly(String id, num x, num y, num z, num rotation, bool h_flip, String streetName) : super(id, x, y, z, rotation, h_flip, streetName) {
		type = 'Firefly';

		actionTime = 4000;
		actions.add(new Action.withName('collect')
			..timeRequired = actionTime
			..actionWord = 'chasing'
			..itemRequirements = REQ_ITEM
			..energyRequirements = REQ_ENERGY);

		speed = 5; //pixels per second
		states = {
			'fullPath': new Spritesheet('fullPath', 'https://childrenofur.com/assets/entityImages/npc_firefly__x1_fullPath_png_1354833043.png', 870, 360, 87, 40, 89, true),
			'halfPath': new Spritesheet('halfPath', 'https://childrenofur.com/assets/entityImages/npc_firefly__x1_halfPath_png_1354833044.png', 870, 160, 87, 40, 40, true),
			'smallPath': new Spritesheet('smallPath', 'https://childrenofur.com/assets/entityImages/npc_firefly__x1_smallPath_png_1354833044.png', 870, 80, 87, 40, 20, true)
		};
		setState('fullPath');
	}

	Future<bool> collect({WebSocket userSocket, String email}) async {
		int adding = rand.nextInt(3)+1;
		int skipped = adding;
		try {
			skipped = await InventoryV2.addFireflyToJar(email, userSocket, amount: adding);
		} catch (e) {
			Log.warning('Could not collect fireflies for <email=$email>', e);
		}
		int added = adding - skipped;

		if (added == 0) {
			toast("You don't have any room in your jar!", userSocket);
			return false;
		} else {
			toast('You caught $added firefl${added == 1 ? 'y' : 'ies'}', userSocket);
			await trySetMetabolics(email, energy: -ENERGY_AMT);

			// Small flight path for 10 seconds
			setState('smallPath');

			return true;
		}
	}

	update({bool simulateTick: false}) {
		bool am = ffClock.time.contains('am');
		int hour = int.parse(ffClock.time.split(':')[0]);
		int minute = int.parse(ffClock.time.split(':')[1].substring(0, 2));
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
						setState('fullPath');
						break;
					case 2:
					case 3:
						setState('halfPath');
						break;
					case 4:
						setState('smallPath');
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