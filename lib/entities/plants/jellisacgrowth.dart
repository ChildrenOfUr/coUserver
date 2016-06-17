part of entity;

class Jellisac extends Plant {
	Jellisac(String id, num x, num y, String streetName) : super(id, x, y, streetName) {
		actionTime = 2000;
		type = "Jellisac Growth";

		EnergyRequirements energyReq = new EnergyRequirements(energyAmount: 4)
			..error = 'You need at least 4 energy to even this about touching this';
		actions.add(
			new Action.withName('grab')
				..actionWord = 'squishing'
				..timeRequired = actionTime
				..energyRequirements = energyReq
		);

		states = {
			"1-2-3-4-5" : new Spritesheet("1-2-3-4-5", "http://childrenofur.com/assets/entityImages/jellisac.png", 210, 49, 42, 49, 5, false),
		};
		setState('1-2-3-4-5');
		state = new Random().nextInt(currentState.numFrames);
		maxState = 5;
	}

	Future<bool> grab({WebSocket userSocket, String email}) async {
		bool success = await super.trySetMetabolics(email,energy:-4,imgMin:2,imgRange:5);
		if(!success) {
			return false;
		}

		state--;
		if(state < 1) {
			respawn = new DateTime.now().add(new Duration(minutes:2));
			return false;
		}

		int numToGive = 1;
		// 1 in 15 chance to get an extra
		if(new Random().nextInt(14) == 14) {
			numToGive = 2;
		}

		StatManager.add(email, Stat.jellisac_harvested).then((int harvested) {
			if (harvested >= 1009) {
				Achievement.find("gloopmeister").awardTo(email);
			} else if (harvested >= 503) {
				Achievement.find("glop_grappler").awardTo(email);
			} else if (harvested >= 283) {
				Achievement.find("sac_bagger").awardTo(email);
			} else if (harvested >= 127) {
				Achievement.find("goo_getter").awardTo(email);
			} else if (harvested >= 41) {
				Achievement.find("slime_harvester").awardTo(email);
			}
		});

		await InventoryV2.addItemToUser(email, items['jellisac'].getMap(), numToGive, id);

		return true;
	}
}
