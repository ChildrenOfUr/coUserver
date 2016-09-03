part of entity;

abstract class Tree extends Plant {
	static final String SKILL = "arborology";
	String rewardItemType;
	DateTime lastWeatherUpdate = new DateTime.now();

	int maturity;

	Tree(String id, num x, num y, num z, String streetName) : super(id, x, y, z, streetName) {
		ItemRequirements itemReq = new ItemRequirements()
			..any = ['watering_can', 'irrigator_9000']
			..error = "Trees don't like to be peed on. Go find some clean water, please.";
		actions.addAll([
			new Action.withName('pet')
				..actionWord = 'petting'
				..description = 'Pet this tree'
				..timeRequired = actionTime
				..energyRequirements = new EnergyRequirements(energyAmount: 2)
				..associatedSkill = SKILL,
			new Action.withName('water')
				..actionWord = 'watering'
				..description = 'Water this tree'
				..timeRequired = actionTime
				..energyRequirements = new EnergyRequirements(energyAmount: 2)
				..itemRequirements = itemReq
				..associatedSkill = SKILL,
			new Action.withName('harvest')
				..actionWord = 'harvesting'
				..description = 'Harvest this tree'
				..timeRequired = actionTime
				..energyRequirements = new EnergyRequirements(energyAmount: 5)
				..associatedSkill = SKILL
		]);
	}

	@override
	void restoreState(Map<String, String> metadata) {
		if (metadata.containsKey('maturity')) {
			maturity = JSON.decode(metadata['maturity']);
			setState('maturity_$maturity');
			maxState = currentState.numFrames - 1;
		}
		if (metadata.containsKey('state')) {
			state = JSON.decode(metadata['state']);
		}
	}

	@override
	Map<String, String> getPersistMetadata() {
		Map<String, String> map = {
			'maturity': JSON.encode(maturity),
			'state': JSON.encode(state),
		};

		return map;
	}

	Future update() async {
		super.update();

		if (
		(await WeatherEndpoint.rainingIn(MapData.getStreetByName(streetName)['tsid'])) &&
			new DateTime.now()
				.difference(lastWeatherUpdate)
				.inSeconds > 23
		) {
			// Every 23 seconds while raining
			state = (state + 1).clamp(0, maxState);
			lastWeatherUpdate = new DateTime.now();
		}
	}

	Future<bool> harvest({WebSocket userSocket, String email}) async {
		if (state == 0) {
			return false;
		}

		int harvestLevel = await SkillManager.getLevel(SKILL, email);
		int rewardMultiplier = 1;
		int energy = 5;
		int imgBoost = harvestLevel;

		if (harvestLevel == 5) {
			rewardMultiplier = 4 + (rand.nextInt(2) == 2 ? 1 : 0);
			imgBoost += 1;
		} else if (harvestLevel >= 4) {
			rewardMultiplier = 4 + (rand.nextInt(3) == 3 ? 1 : 0);
		} else if (harvestLevel >= 3) {
			rewardMultiplier = 3 + (rand.nextInt(5) == 5 ? 1 : 0);
		} else if (harvestLevel > 1) {
			rewardMultiplier = 2;
		}

		if (harvestLevel >= 3) {
			energy -= 2;
		}

		//make sure the player has 5 energy to perform this action
		//if so, allow the action and subtract 5 from their energy
		bool success = await trySetMetabolics(email, energy: -energy, mood: 1 + (rewardMultiplier ~/ 2), imgMin: 5 + imgBoost, imgRange: 5);
		if (!success) {
			return false;
		}

		//say a witty thing
		say(responses['harvest'].elementAt(rand.nextInt(responses['harvest'].length)));

		state--;

		//give the player the 'fruits' of their labor
		await InventoryV2.addItemToUser(email, items[rewardItemType].getMap(), rewardMultiplier, id);

		if (state < 0) {
			state = 0;
		}

		SkillManager.learn(SKILL, email);

		// Chance for musicblock
		if (rand.nextInt(15) == 7) {
			Item musicblock = items[Crab.randomMusicblock()];
			await InventoryV2.addItemToUser(email, musicblock.getMap(), 1, id);
			toast(
				"You got a ${musicblock.name}!", userSocket,
				onClick: "iteminfo|${musicblock.name}"
			);
		}

		return true;
	}

	Future<bool> water({WebSocket userSocket, String email}) async {
		//make sure the player has a watering can that water this tree
		Action digAction = actions.singleWhere((Action a) => a.actionName == 'water');
		List<String> types = digAction.itemRequirements.any;
		bool success = await InventoryV2.decreaseDurability(email, types);
		if (!success) {
			return false;
		}

		if (state == maxState) {
			return false;
		}

		success = await trySetMetabolics(email, energy: -2, mood: 2, imgMin: 3, imgRange: 2);
		if (!success) {
			return false;
		}

		//say a witty thing
		say(responses['water'].elementAt(rand.nextInt(responses['water'].length)));

		// Award achievements
		Map<Stat, int> stats = await StatManager.getAll(email);
		int totalWatered = 0
			+ stats[Stat.bean_trees_watered]
			+ stats[Stat.bubble_trees_watered]
			+ stats[Stat.egg_plants_watered]
			+ stats[Stat.fruit_trees_watered]
			+ stats[Stat.gas_plants_watered]
			+ stats[Stat.spice_plants_watered]
			+ stats[Stat.wood_trees_watered];

		if (totalWatered >= 127) {
			Achievement.find("secondrate_rainmaker").awardTo(email);
		} else if (totalWatered >= 41) {
			Achievement.find("firstrate_rainmaker").awardTo(email);
		} else if (totalWatered >= 7) {
			Achievement.find("novice_precipitator").awardTo(email);
		}

		state++;

		SkillManager.learn(SKILL, email);

		if (state > maxState) {
			state = maxState;
		}

		return true;
	}

	Future<bool> pet({WebSocket userSocket, String email}) async {
		bool success = await trySetMetabolics(email, energy: -2, mood: 2, imgMin: 3, imgRange: 2);
		if (!success) {
			return false;
		}

		//say a witty thing
		say(responses['pet'].elementAt(rand.nextInt(responses['pet'].length)));

		// Award achievements
		Map<Stat, int> stats = await StatManager.getAll(email);
		int totalPetted = 0
			+ stats[Stat.bean_trees_petted]
			+ stats[Stat.bubble_trees_petted]
			+ stats[Stat.egg_plants_petted]
			+ stats[Stat.fruit_trees_petted]
			+ stats[Stat.gas_plants_petted]
			+ stats[Stat.spice_plants_petted]
			+ stats[Stat.wood_trees_petted];

		if (totalPetted >= 1009) {
			Achievement.find("finallyprettygood_tree_hugger").awardTo(email);
		} else if (totalPetted >= 503) {
			Achievement.find("definitelymuchbetter_tree_hugger").awardTo(email);
		} else if (totalPetted >= 283) {
			Achievement.find("extremely_promising_tree_hugger").awardTo(email);
		} else if (totalPetted >= 41) {
			Achievement.find("decent_tree_hugger").awardTo(email);
		} else if (totalPetted >= 7) {
			Achievement.find("okbutneedsimprovement_tree_hugger").awardTo(email);
		}

		//offer the tree petter quest
		QuestEndpoint.questLogCache[email].offerQuest('Q2');

		messageBus.publish(new RequirementProgress('treePet$type', email));

		SkillManager.learn(SKILL, email);

		return true;
	}

	@override
	Future<List<Action>> customizeActions(String email) async {
		int arbologyLevel = await SkillManager.getLevel(SKILL, email);
		List<Action> personalActions = [];
		await Future.forEach(actions, (Action action) async {
			Action personalAction = new Action.clone(action);
			if (action.actionName == 'harvest') {
				if (arbologyLevel > 2) {
					personalAction.energyRequirements = new EnergyRequirements(energyAmount: 3);
				}
				if (state <= 0) {
					personalAction.enabled = false;
					personalAction.error = "There's nothing to harvest right now. Try giving me some water.";
				}
			}
			if (action.actionName == 'water') {
				if (state >= maxState) {
					personalAction.enabled = false;
					personalAction.error = "I'm not thirsty right now.";
				}
				if (await WeatherEndpoint.rainingIn(MapData.getStreetByName(streetName)['tsid'])) {
					personalAction.enabled = false;
					personalAction.error = "It's already raining, I don't need any more water.";
				}
			}
			personalActions.add(personalAction);
		});

		return personalActions;
	}
}
