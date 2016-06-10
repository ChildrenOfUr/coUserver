part of entity;

enum GardenStates {
	NEW,
	HOED,
	WATERED,
	PLANTED
}

class Garden extends NPC {
	static final String SKILL = "croppery";
	static bool sentMap = false;
	static final int actionEnergy = 0;
	static final int hoeEnergy = -5;
	static final int waterEnergy = -5;
	static final int harvestEnergy = -5;

	static Map hoeAction = {"action":"hoe",
		"actionWord":"hoeing",
		"timeRequired":2000,
		"enabled":true,
		"requires":[
			{
				"num":1,
				"of":["hoe", "high_class_hoe"],
				"error": "You don't want to get your fingers dirty."
			},
			{
				"num":hoeEnergy,
				"of":['energy'],
				"error": "You need at least 5 energy to hoe."
			}
		],
		"associatedSkill": SKILL
	};

	static Map waterAction = {"action":"water",
		"timeRequired":2000,
		"enabled":true,
		"actionWord":"watering",
		"requires":[
			{
				"num":1,
				"of":["watering_can", "irrigator_9000"],
				"error": "Gardens don't like to be peed on. Go find some clean water, please."
			},
			{
				"num": waterEnergy,
				"of": ['energy'],
				"error": "You need at least 2 energy to water."
			}
		],
		"associatedSkill": SKILL
	};

	static Map plantAction = {"action":"plant",
		"timeRequired":0,
		"enabled":true,
		"actionWord":"planting",
		"requires":[
			{
				"num": 1,
				"of": ['Seed_Broccoli','Seed_Cabbage','Seed_Carrot','Seed_Corn',
				       'Seed_Cucumber','Seed_Onion','Seed_Parsnip','Seed_Potato',
				       'Seed_Pumpkin','Seed_Rice','Seed_Spinach','Seed_Tomato','Seed_Zucchini'],
				"error": "You need some crop seeds to plant."
			}
		],
		"associatedSkill": SKILL
	};

	static Map harvestAction = {"action":"harvest",
		"timeRequired":5000,
		"enabled":true,
		"actionWord":"harvesting",
		"requires":[
			{
				"num": harvestEnergy,
				"of": ['energy'],
				"error": "You need at least 3 energy to harvest."
			}
		],
		"associatedSkill": SKILL
	};

	static Map viewAction = {"action":"view",
		"timeRequired":0,
		"enabled":true,
		"actionWord":"viewing",
	};

	GardenStates gardenState = GardenStates.NEW;
	String plantedWith = 'none';
	int plantedState = -1;
	DateTime plantedAt, stage1Time, stage2Time, stage3Time;

	Garden(String id, int x, int y, String streetName) : super(id, x, y, streetName) {
		type = "Crop Garden";
		states =
		{
			'new' : new Spritesheet('new', "http://childrenofur.com/assets/entityImages/garden_plot_new.png", 100, 90, 100, 90, 1, false),
			'hoed' : new Spritesheet('hoed', "http://childrenofur.com/assets/entityImages/garden_plot_hoed.png", 100, 90, 100, 90, 1, false),
			'watered' : new Spritesheet('watered', "http://childrenofur.com/assets/entityImages/garden_plot_watered.png", 100, 90, 100, 90, 1, false),
			'planted_baby' : new Spritesheet('planted_baby', "http://childrenofur.com/assets/entityImages/garden_plot_planted_baby.png", 100, 90, 100, 90, 1, false),
			'cabbage_1' : new Spritesheet('cabbage_1', "http://childrenofur.com/assets/entityImages/cabbage_1.png", 100, 90, 100, 90, 1, false),
			'cabbage_2' : new Spritesheet('cabbage_2', "http://childrenofur.com/assets/entityImages/cabbage_2.png", 100, 90, 100, 90, 1, false),
			'cabbage_3' : new Spritesheet('cabbage_3', "http://childrenofur.com/assets/entityImages/cabbage_3.png", 100, 90, 100, 90, 1, false)
		};
		setState('new');
		actions = [hoeAction];
	}

	void restoreState(Map<String, String> metadata) {
		if (metadata.containsKey('gardenState')) {
			gardenState = GardenStates.values[int.parse(metadata['gardenState'])];
			if (gardenState == GardenStates.NEW) {
				actions = [hoeAction];
			} else if (gardenState == GardenStates.HOED) {
				actions = [waterAction];
			} else if (gardenState == GardenStates.WATERED) {
				actions = [plantAction];
			} else {
				actions = [viewAction];
			}
		}

		if (metadata.containsKey('currentState')) {
			setState(metadata['currentState']);
		}

		if (metadata.containsKey('plantedWith')) {
			plantedWith = metadata['plantedWith'];
		}

		if (metadata.containsKey('plantedState')) {
			plantedState = int.parse(metadata['plantedState']);
		}

		if (metadata.containsKey('plantedAt')) {
			plantedAt = new DateTime.fromMillisecondsSinceEpoch(int.parse(metadata['plantedAt']));
			_createStageTimes();
		}
	}

	void _createStageTimes() {
		stage1Time = plantedAt.add(new Duration(minutes: 5));
		stage2Time = stage1Time.add(new Duration(minutes: 5));
		stage3Time = stage2Time.add(new Duration(minutes: 5));
	}

	Map<String, String> getPersistMetadata() {
		Map<String, String> map = {
			'gardenState': gardenState.index.toString(),
			'currentState': currentState.stateName,
			'plantedWith': plantedWith,
			'plantedState': plantedState.toString(),
		};

		if (plantedAt != null) {
			map['plantedAt'] = plantedAt.millisecondsSinceEpoch.toString();
		}

		return map;
	}

	@override
	void update() {
		if (gardenState != GardenStates.PLANTED) {
			return;
		}

		DateTime now = new DateTime.now();
		if (stage3Time.isBefore(now)) {
			//the plant is now fully grown and ready for harvest
			actions = [harvestAction];
			plantedState = 3;
		} else if (stage2Time.isBefore(now)) {
			plantedState = 2;
		} else if (stage1Time.isBefore(now)) {
			plantedState = 1;
		} else {
			plantedState = 0;
		}

		//upgrade the plant here
		if (plantedState >= 0) {
			if (plantedState == 0) {
				setState('planted_baby');
			} else {
				String stateKey = '${plantedWith}_${plantedState}';
				if (states.containsKey(stateKey)) {
					setState(stateKey);
				}
			}
		}
	}

	Future<bool> _setLevelBasedMetabolics(int level, String action, String email) async {
		int mood = 2;
		int imgMin = 5;
		int energy = actionEnergy;

		if (action == 'hoe') {
			energy = hoeEnergy;
		} else if (action == 'water') {
			energy = waterEnergy;
		} else if (action == 'harvest') {
			energy = harvestEnergy;
		}

		if (level > 0) {
			mood *= level+1;
			imgMin *= level+1;
			energy ~/= level;
		}

		return trySetMetabolics(email, energy: energy, mood: mood, imgMin: imgMin, imgRange: 4);
	}

	Future<bool> hoe({WebSocket userSocket, String email}) async {
		if (gardenState != GardenStates.NEW) {
			return false;
		}

		int level = await SkillManager.getLevel('croppery',email);
		bool success = await _setLevelBasedMetabolics(level, 'hoe', email);
		if(!success) {
			return false;
		}

		StatManager.add(email, Stat.crops_hoed);
		SkillManager.learn(SKILL, email);

		gardenState = GardenStates.HOED;
		actions = [waterAction];
		setState('hoed');
		return true;
	}

	Future<bool> water({WebSocket userSocket, String email}) async {
		if (gardenState != GardenStates.HOED) {
			return false;
		}

		int level = await SkillManager.getLevel('croppery',email);
		bool success = await _setLevelBasedMetabolics(level, 'water', email);
		if(!success) {
			return false;
		}

		StatManager.add(email, Stat.crops_watered);
		SkillManager.learn(SKILL, email);

		gardenState = GardenStates.WATERED;
		actions = [plantAction];
		setState('watered');
		return true;
	}

	Future<bool> plant({WebSocket userSocket, String email}) async {
		if (gardenState != GardenStates.WATERED) {
			return false;
		}

		Map map = {};
		map["action"] = "plantSeed";
		map['id'] = id;
		map['openWindow'] = 'itemChooser';
		map['filter'] = 'category=Seeds';
		map['windowTitle'] = 'Plant What?';
		userSocket.add(JSON.encode(map));

		return true;
	}

	Future<bool> plantSeed({WebSocket userSocket, String itemType, int count, String email, int slot, int subSlot}) async {
		if (gardenState != GardenStates.WATERED) {
			return false;
		}

		bool success = (await InventoryV2.takeItemFromUser(email, slot, subSlot, count)) != null;
		if(!success) {
			return false;
		}

		StatManager.add(email, Stat.crops_planted);
		SkillManager.learn(SKILL, email);

		plantedWith = itemType.replaceAll('Seed_', '').toLowerCase();
		gardenState = GardenStates.PLANTED;
		plantedAt = new DateTime.now();
		_createStageTimes();
		actions = [viewAction];
		setState('planted_baby');

		return true;
	}

	Future<bool> view({WebSocket userSocket, String email}) async {
		//calling this so to reset the gains so the last action's gains
		//aren't shown in a pure speech bubble
		await trySetMetabolics(email);

		Clock futureUrTime = new Clock.stoppedAtDate(stage3Time);
		say('I am currently growing ${pluralize(plantedWith)}.'
			' I should be ready for harvest at ${futureUrTime.time}');
		return true;
	}

	Future<bool> harvest({WebSocket userSocket, String email}) async {
		if (gardenState != GardenStates.PLANTED) {
			return false;
		}

		int level = await SkillManager.getLevel('croppery',email);
		bool success = await _setLevelBasedMetabolics(level, 'harvest', email);
		if(!success) {
			return false;
		}

		StatManager.add(email, Stat.crops_harvested);
		SkillManager.learn(SKILL, email);

		//give the player the 'fruits' of their labor
		String itemType = 'Seed_${plantedWith[0].toUpperCase()}${plantedWith.substring(1)}';
		int count = 1;
		if (level == 1) {
			count = 2;
		}
		if (level >= 2) {
			//lucky #13 gets you a prize
			if (rand.nextInt(30~/(level-1)) == 13) {
				Item musicblock = items[Crab.randomMusicblock()];
				await InventoryV2.addItemToUser(email, musicblock.getMap(), 1, id);
				toast(
					"You got a ${musicblock.name}!", userSocket,
					onClick: "iteminfo|${musicblock.name}"
					);
			}
		}
		if (level == 3) {
			//lucky #7 gets you a super harvest
			if (rand.nextInt(10) == 7) {
				count *= 2;
			}
		}
		await InventoryV2.addItemToUser(email, items[itemType].getMap(), count, id);

		plantedWith = '';
		gardenState = GardenStates.NEW;
		plantedState = 0;
		plantedAt = null;
		actions = [hoeAction];
		setState('new');

		return true;
	}
}
