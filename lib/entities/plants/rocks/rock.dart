part of entity;

abstract class Rock extends Plant {
	static final String SKILL = "mining";

	Rock(String id, int x, int y, String streetName) : super(id, x, y, streetName) {
		maxState = 0;
		actionTime = 5000;

		ItemRequirements itemReq = new ItemRequirements()
			..any = ['pick', 'fancy_pick']
			..error = 'You need some type of pick to mine this.';
		actions.add(
			new Action.withName('mine')
				..actionWord = 'mining'
				..timeRequired = actionTime
				..itemRequirements = itemReq
				..energyRequirements = new EnergyRequirements(energyAmount: 10)
				..associatedSkill = SKILL
		);

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

		if ( state >= currentState.numFrames ) {
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
		if (state >= currentState.numFrames) {
			toast("There's not much left to mine", userSocket);
			return false;
		}

		//make sure the player has a pick that can mine this rock
		Action digAction = actions.singleWhere((Action a) => a.actionName == 'mine');
		List<String> types = digAction.itemRequirements.any;
		int miningSkillLevel = await SkillManager.getLevel(SKILL, email);
		bool success = await InventoryV2.decreaseDurability(email, types, amount: (miningSkillLevel >= 3 ? 1 : 2));
		if(!success) {
			return false;
		}

		//make sure the player has 10 energy to perform this action
		//if so, allow the action and subtract 10 from their energy

		// Get current skill level
		int miningLevel = await SkillManager.getLevel(SKILL, email);

		int energyUsed = 10;
		if (miningLevel >= 3) {
			energyUsed ~/= 4;
		} else if (miningLevel > 1) {
			energyUsed -= 2;
		}

		int imgReward = 5;
		int imgMin = 10;
		if (miningLevel == 4) {
			imgReward *= 2;
			imgMin *= 2;
		} else if (miningLevel >= 3) {
			imgReward += 2;
			imgMin += 2;
		}

		success = await super.trySetMetabolics(email, energy: -energyUsed, imgMin: imgMin, imgRange: imgReward);
		if (!success) {
			return false;
		}

		//rocks spritesheets go from full to empty which is the opposite of trees
		//so mining the rock will actually increase its state number

		say(responses['mine_$type']
			    .elementAt(rand.nextInt(responses['mine_$type'].length)));

		StatManager.add(email, Stat.rocks_mined);
		state++;
		if (state >= currentState.numFrames) {
			say(responses['gone'].elementAt(rand.nextInt(responses['gone'].length)));
			respawn = new DateTime.now().add(new Duration(minutes: 2));
		}

		//chances to get gems:
		//amber = 1 in 5
		//sapphire = 1 in 7
		//ruby = 1 in 10
		//moonstone = 1 in 15
		//diamond = 1 in 20

		int chanceIncreaser = 0;

		if (miningLevel == 4) {
			chanceIncreaser = 2;
		} else if (miningLevel >= 2) {
			chanceIncreaser = 3;
		}

		if (rand.nextInt(5 - chanceIncreaser) == 5 - chanceIncreaser) {
			await InventoryV2.addItemToUser(email, items['pleasing_amber'].getMap(), 1, id);
		}
		if (rand.nextInt(7 - chanceIncreaser) == 5 - chanceIncreaser) {
			await InventoryV2.addItemToUser(email, items['showy_sapphire'].getMap(), 1, id);
		}
		if (rand.nextInt(10 - chanceIncreaser) == 5 - chanceIncreaser) {
			await InventoryV2.addItemToUser(email, items['modestly_sized_ruby'].getMap(), 1, id);
		}
		if (rand.nextInt(15 - chanceIncreaser) == 5 - chanceIncreaser) {
			await InventoryV2.addItemToUser(email, items['luminous_moonstone'].getMap(), 1, id);
		}
		if (rand.nextInt(20 - chanceIncreaser) == 5 - chanceIncreaser) {
			await InventoryV2.addItemToUser(email, items['walloping_big_diamond'].getMap(), 1, id);
		}

		// Award skill points
		SkillManager.learn(SKILL, email);

		return true;
	}
}
