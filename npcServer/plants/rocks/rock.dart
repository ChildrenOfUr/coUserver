part of coUserver;

abstract class Rock extends Plant {
	Rock(String id, int x, int y) : super(id, x, y) {
		maxState = 0;
		actionTime = 5000;

		actions.add({
			            "action": "mine",
			            "actionWord": "mining",
			            "timeRequired": actionTime,
			            "enabled": true,
			            "requires": [
				            {
					            "num": 1,
					            "of": ["pick", "fancy_pick"],
					            "error": "You need some type of pick to mine this."
				            },
				            {
					            "num": 10,
					            "of": ['energy'],
					            "error": "You need at least 10 energy to mine."
				            }
			            ]
		            });

		responses = {
			'gone': [
				"Oof, where'd I go?",
				"brb",
				"kbye",
				"A la peanut butter sammiches",
				"Alakazam!",
				"*poof*",
				"I'm all mined out!",
				"Gone to the rock quarry in the sky",
				"Yes. You hit rock bottom",
				"All rocked out for now"
			]
		};
	}

	void update() {
		DateTime now = new DateTime.now();
		if (state >= currentState.numFrames && now.compareTo(respawn) >= 0) {
			say(responses['gone'].elementAt(rand.nextInt(responses['gone'].length)));
			setActionEnabled("mine", false);
		}

		if (respawn != null && now.compareTo(respawn) >= 0) {
			state = 0;
			setActionEnabled("mine", true);
			respawn = null;
		}

		if (state < maxState) {
			state = maxState;
		}
	}

	Future<bool> mine({WebSocket userSocket, String email}) async {
		//make sure the player has 10 energy to perform this action
		//if so, allow the action and subtract 10 from their energy
		bool success = await super.trySetMetabolics(email,
			                                            energy: -10, imgMin: 10, imgRange: 5);
		if (!success) {
			return false;
		}

		//rocks spritesheets go from full to empty which is the opposite of trees
		//so mining the rock will actually increase its state number

		say(responses['mine_$type']
			    .elementAt(rand.nextInt(responses['mine_$type'].length)));

		StatBuffer.incrementStat("rocksMined", 1);
		state++;
		if (state >= currentState.numFrames) {
			respawn = new DateTime.now().add(new Duration(minutes: 2));
		}

		//chances to get gems:
		//amber = 1 in 5
		//sapphire = 1 in 7
		//ruby = 1 in 10
		//moonstone = 1 in 15
		//diamond = 1 in 20
		if (rand.nextInt(5) == 5) {
			await InventoryV2.addItemToUser(email, items['pleasing_amber'].getMap(), 1, id);
		}
		if (rand.nextInt(7) == 5) {
			await InventoryV2.addItemToUser(email, items['showy_sapphire'].getMap(), 1, id);
		}
		if (rand.nextInt(10) == 5) {
			await InventoryV2.addItemToUser(email, items['modestly_sized_ruby'].getMap(), 1, id);
		}
		if (rand.nextInt(15) == 5) {
			await InventoryV2.addItemToUser(email, items['luminous_moonstone'].getMap(), 1, id);
		}
		if (rand.nextInt(20) == 5) {
			await InventoryV2.addItemToUser(email, items['walloping_big_diamond'].getMap(), 1, id);
		}

		return true;
	}
}
