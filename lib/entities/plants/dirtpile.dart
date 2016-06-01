part of entity;

class DirtPile extends Plant {
	DirtPile(String id, int x, int y, String streetName) : super(id, x, y, streetName) {
		actionTime = 3000;
		type = "Dirt Pile";

		actions.add({
			            "action": "dig",
			            "actionWord": "digging",
			            "timeRequired": actionTime,
			            "enabled": true,
			            "requires": [
				            {
					            "num": 1,
					            "of": ["shovel", "ace_of_spades"],
					            "error": "What, you were going to dig with your bare hands?"
				            },
				            {
					            "num": 8,
					            "of": ['energy'],
					            "error": "You need at least 8 energy to dig."
				            }
			            ]
		            });

		states = {
			"maturity_1": new Spritesheet(
				"maturity_1",
				"http://childrenofur.com/assets/entityImages/dirt_pile_dirt_state_x11_1_variant_dirt1_1_png_1354833756.png",
				780,
				213,
				195,
				71,
				11,
				false),
			"maturity_2": new Spritesheet(
				"maturity_2",
				"http://childrenofur.com/assets/entityImages/dirt_pile_dirt_state_x11_1_variant_dirt2_1_png_1354833757.png",
				780,
				213,
				195,
				71,
				11,
				false)
		};
		int maturity = new Random().nextInt(states.length) + 1;
		setState('maturity_$maturity');
		state = new Random().nextInt(currentState.numFrames);
		maxState = 0;
	}

	@override
	void update() {
		if (state >= currentState.numFrames) {
			setActionEnabled("dig", false);
		}

		if (respawn != null && new DateTime.now().compareTo(respawn) >= 0) {
			state = 0;
			setActionEnabled("dig", true);
			respawn = null;
		}

		if (state < maxState) {
			state = maxState;
		}
	}

	Future<bool> dig({WebSocket userSocket, String email}) async {
		//make sure the player has a shovel that can dig this dirt
		Map mineAction = actions.firstWhere((Map action) => action['action'] == 'dig');
		List<String> types = mineAction['requires'][0]['of'];
		bool success = await InventoryV2.decreaseDurability(email, types);
		if(!success) {
			return false;
		}

		success = await trySetMetabolics(email, energy: -8, imgMin: 10, imgRange: 5);
		if (!success) {
			return false;
		}

		state++;
		if (state >= currentState.numFrames) {
			respawn = new DateTime.now().add(new Duration(minutes: 2));
		}

		//give the player the 'fruits' of their labor
		await InventoryV2.addItemToUser(email, items['earth'].getMap(), 1, id);

		//1 in 10 chance to get a lump of loam as well
		if (new Random().nextInt(10) == 5) {
			await InventoryV2.addItemToUser(email, items['loam'].getMap(), 1, id);
		}

		StatManager.add(email, Stat.dirt_dug).then((int dug) {
			if (dug >= 503) {
				Achievement.find("dirt_diggler").awardTo(email);
			} else if (dug >= 251) {
				Achievement.find("dirtomancer").awardTo(email);
			} else if (dug >= 127) {
				Achievement.find("loamist").awardTo(email);
			} else if (dug >= 61) {
				Achievement.find("dirt_monkey").awardTo(email);
			} else if (dug >= 29) {
				Achievement.find("shovel_jockey").awardTo(email);
			}
		});

		return true;
	}
}
