part of entity;

class Jellisac extends Plant {
	Jellisac(String id, num x, num y, String streetName) : super(id, x, y, streetName) {
		actionTime = 2000;
		type = "Jellisac Growth";

		EnergyRequirements energyReq = new EnergyRequirements(energyAmount: 4)
			..error = 'You need at least 4 energy to even think about touching this';
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
		maxState = 4; //cuz 0-4 = 5
	}

	@override
	void update() {
		if(respawn != null && new DateTime.now().isAfter(respawn)) {
			setActionEnabled("grab", true);
			state = maxState;
			respawn = null;
		}

		if(state < 1 && respawn == null) {
			setActionEnabled("grab", false);
			respawn = new DateTime.now().add(new Duration(minutes:2));
		}
	}

	Future<bool> grab({WebSocket userSocket, String email}) async {
		if(state < 1) {
			say('No more goop');
			return false;
		}
		state--;

		bool success = await super.trySetMetabolics(email,energy:-4,imgMin:2,imgRange:5);
		if(!success) {
			return false;
		}

		int numToGive = 1;
		// 1 in 15 chance to get an extra
		if(new Random().nextInt(15) == 14) {
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

		say();

		return true;
	}
}
