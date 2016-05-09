part of entity;

abstract class Tree extends Plant {
	static final String SKILL = "arborology";
	String rewardItemType;
	DateTime lastWeatherUpdate = new DateTime.now();

	int maturity;

	Tree(String id, int x, int y, String streetName) : super(id, x, y, streetName) {
		actions..add({"action":"harvest",
			"timeRequired":actionTime,
			"enabled":true,
			"actionWord":"harvesting",
			"requires":[{
					'num':5,
					'of':['energy'],
					"error": "You need at least 5 energy to harvest."
				}],
				"associatedSkill": SKILL
			})..add({"action":"water",
			"timeRequired":actionTime,
			"enabled":true,
			"actionWord":"watering",
			"requires":[
				{
					"num":1,
					"of":["watering_can", "irrigator_9000"],
					"error": "Trees don't like to be peed on. Go find some clean water, please."
				},
				{
					"num": 2,
					"of": ['energy'],
					"error": "You need at least 2 energy to water."
				}
			],
			"associatedSkill": SKILL
		})..add({"action":"pet",
			"timeRequired":actionTime,
			"enabled":true,
			"actionWord":"petting",
			"requires":[
				{
					'num':2,
					'of':['energy'],
					'error': "You need at least 2 energy to pet."
				}
			],
			"associatedSkill": SKILL
		});
	}

	void update() {
		super.update();

		if (state > 0) {
			setActionEnabled("harvest", true);
		} else {
			setActionEnabled("harvest", false);
		}

		if (
			WeatherEndpoint.currentState == WeatherState.RAINING &&
			new DateTime.now().difference(lastWeatherUpdate).inSeconds > 23
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

		StatBuffer.incrementStat("treesHarvested", 1);
		respawn = new DateTime.now().add(new Duration(seconds: 30));
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
		Map mineAction = actions.firstWhere((Map action) => action['action'] == 'water');
		List<String> types = mineAction['requires'][0]['of'];
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

		//StatBuffer.incrementStat("treesWatered", 1);
		Stat stat;
		switch (type) {
			case "Bean Tree":
				stat = Stat.bean_trees_watered;
				break;
			case "Bubble Tree":
				stat = Stat.bubble_trees_watered;
				break;
			case "Egg Plant":
				stat = Stat.egg_plants_watered;
				break;
			case "Fruit Tree":
				stat = Stat.fruit_trees_watered;
				break;
			case "Gas Plant":
				stat = Stat.gas_plants_watered;
				break;
			case "Spice Plant":
				stat = Stat.spice_plants_watered;
				break;
			case "Wood Tree":
				stat = Stat.wood_trees_watered;
				break;
		}
		if (stat != null) {
			StatManager.add(email, stat);
		}

		respawn = new DateTime.now().add(new Duration(seconds: 30));
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

		//offer the tree petter quest
		QuestEndpoint.questLogCache[email].offerQuest('Q2');

		messageBus.publish(new RequirementProgress('treePet$type', email));

		SkillManager.learn(SKILL, email);

		//StatBuffer.incrementStat("treesPetted", 1);
		Stat stat;
		switch (type) {
			case "Bean Tree":
				stat = Stat.bean_trees_petted;
				break;
			case "Bubble Tree":
				stat = Stat.bubble_trees_petted;
				break;
			case "Egg Plant":
				stat = Stat.egg_plants_petted;
				break;
			case "Fruit Tree":
				stat = Stat.fruit_trees_petted;
				break;
			case "Gas Plant":
				stat = Stat.gas_plants_petted;
				break;
			case "Spice Plant":
				stat = Stat.spice_plants_petted;
				break;
			case "Wood Tree":
				stat = Stat.wood_trees_petted;
				break;
		}
		if (stat != null) {
			StatManager.add(email, stat);
		}

		return true;
	}
}