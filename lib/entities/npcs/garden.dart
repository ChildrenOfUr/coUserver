part of entity;

enum GardenStates {
	NEW,
	HOED,
	WATERED,
	PLANTED
}

class Garden extends NPC {
	static final String SKILL = 'croppery';
	static bool sentMap = false;

	static final List<String> CROPS = ['broccoli', 'cabbage', 'carrot', 'corn', 'cucumber', 'onion', 'parsnip', 'potato', 'pumpkin', 'rice', 'spinach', 'tomato', 'zucchini'];

	static final ItemRequirements
		ITEM_REQ_HOE = new ItemRequirements()
			..any = ['hoe', 'high_class_hoe']
			..error = "You don't want to get your fingers dirty.",
		ITEM_REQ_WATER = new ItemRequirements()
			..any = ['watering_can', 'irrigator_9000']
			..error = "Gardens don't like to be peed on. Go find some clean water, please.",
		ITEM_REQ_PLANT = new ItemRequirements()
			..any = [
				'broccoli_seed',
				'cabbage_seed',
				'carrot_seed',
				'corn_seed',
				'cucumber_seed',
				'onion_seed',
				'parsnip_seed',
				'potato_seed',
				'pumpkin_seed',
				'rice_seed',
				'spinach_seed',
				'tomato_seed',
				'zucchini_seed'
			]
			..error = 'You need some crops to plant';

	static final EnergyRequirements
		ENERGY_REQ_HOE = new EnergyRequirements(energyAmount: -5),
		ENERGY_REQ_WATER = new EnergyRequirements(energyAmount: -2),
		ENERGY_REQ_HARVEST = new EnergyRequirements(energyAmount: -3);

	static final Map<String, Spritesheet> STATES = {
		'new': new Spritesheet('new',
			'http://childrenofur.com/assets/entityImages/garden_plot_new.png',
			100, 90, 100, 90, 1, false),
		'hoed': new Spritesheet('hoed',
			'http://childrenofur.com/assets/entityImages/garden_plot_hoed.png',
			100, 90, 100, 90, 1, false),
		'watered': new Spritesheet('watered',
			'http://childrenofur.com/assets/entityImages/garden_plot_watered.png',
			100, 90, 100, 90, 1, false),
		'planted_baby': new Spritesheet('planted_baby',
			'http://childrenofur.com/assets/entityImages/garden_plot_planted_baby.png',
			100, 90, 100, 90, 1, false),
	};

	GardenStates gardenState = GardenStates.NEW;
	String plantedWith = 'none';
	int plantedState = -1;
	DateTime plantedAt, stage1Time, stage2Time, stage3Time;
	Action hoeAction, waterAction, plantAction, viewAction, harvestAction;
	bool restored = false;

	Garden(String id, num x, num y, String streetName) : super(id, x, y, streetName) {
		type = 'Crop Garden';

		hoeAction = new Action.withName('hoe')
			..actionWord = 'hoeing'
			..timeRequired = 2000
			..energyRequirements = ENERGY_REQ_HOE
			..itemRequirements = ITEM_REQ_HOE
			..associatedSkill = SKILL;

		waterAction = new Action.withName('water')
			..actionWord = 'watering'
			..timeRequired = 2000
			..energyRequirements = ENERGY_REQ_WATER
			..itemRequirements = ITEM_REQ_WATER
			..associatedSkill = SKILL;

		plantAction = new Action.withName('plant')
			..itemRequirements = ITEM_REQ_PLANT
			..associatedSkill = SKILL;

		viewAction = new Action.withName('view');

		harvestAction = new Action.withName('harvest')
			..actionWord = 'harvesting'
			..timeRequired = 5000
			..energyRequirements = ENERGY_REQ_HARVEST
			..associatedSkill = SKILL;

		states = STATES;
		_createCropStates();
		setState('new');

		actions = [hoeAction];
	}

	///This will add all of the crop states to the [states] array so that it doesn't
	///take up so much room and is easier to edit. Just add to the [crops] list to edit it
	void _createCropStates() {

		for (String crop in CROPS) {
			for (int i=1; i<4; i++) {
				String cropState = '${crop}_${i}';
				states[cropState] = new Spritesheet(cropState, 'http://childrenofur.com/assets/entityImages/$cropState.png', 100, 90, 100, 90, 1, false);
			}
		}
	}

	void restoreState(Map<String, String> metadata) {
		super.restoreState(metadata);

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

		restored = true;
	}

	void _createStageTimes() {
		stage1Time = plantedAt.add(new Duration(minutes: 5));
		stage2Time = stage1Time.add(new Duration(minutes: 5));
		stage3Time = stage2Time.add(new Duration(minutes: 5));
	}

	Map<String, String> getPersistMetadata() {
		Map<String, String> map = super.getPersistMetadata()
			..['gardenState'] = gardenState.index.toString()
			..['currentState'] = currentState.stateName
			..['plantedWith'] = plantedWith
			..['plantedState'] = plantedState.toString();

		if (plantedAt != null) {
			map['plantedAt'] = plantedAt.millisecondsSinceEpoch.toString();
		}

		return map;
	}

	@override
	void update() {
		if (!restored) {
			return;
		}

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
		int energy = 0;

		if (action == 'hoe') {
			energy = ENERGY_REQ_HOE.energyAmount;
		} else if (action == 'water') {
			energy = ENERGY_REQ_WATER.energyAmount;
		} else if (action == 'harvest') {
			energy = ENERGY_REQ_HARVEST.energyAmount;
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

		int level = await SkillManager.getLevel(SKILL, email);
		bool success = await _setLevelBasedMetabolics(level, 'hoe', email);
		if(!success) {
			return false;
		}

		StatManager.add(email, Stat.crops_hoed);
		SkillManager.learn(SKILL, email);

		say(); // display gains

		gardenState = GardenStates.HOED;
		actions = [waterAction];
		setState('hoed');
		return true;
	}

	Future<bool> water({WebSocket userSocket, String email}) async {
		if (gardenState != GardenStates.HOED) {
			return false;
		}

		int level = await SkillManager.getLevel(SKILL, email);
		bool success = await _setLevelBasedMetabolics(level, 'water', email);
		if(!success) {
			return false;
		}

		StatManager.add(email, Stat.crops_watered);
		SkillManager.learn(SKILL, email);

		say(); // display gains

		gardenState = GardenStates.WATERED;
		actions = [plantAction];
		setState('watered');
		return true;
	}

	Future<bool> plant({WebSocket userSocket, String email}) async {
		if (gardenState != GardenStates.WATERED) {
			return false;
		}

		userSocket.add(JSON.encode({
			'action': 'plantSeed',
			'id': id,
			'openWindow': 'itemChooser',
			'filter': 'category=Croppery & Gardening Supplies|||itemType=.*_seed',
			'windowTitle': 'Plant What?'
		}));

		return true;
	}

	Future<bool> plantSeed({WebSocket userSocket, String itemType, int count, String email, int slot, int subSlot}) async {
		if (gardenState != GardenStates.WATERED) {
			return false;
		}

		bool success = (await InventoryV2.takeItemFromUser(email, slot, subSlot, 1)) != null;
		if(!success) {
			return false;
		}

		StatManager.add(email, Stat.crops_planted);
		SkillManager.learn(SKILL, email);

		plantedWith = itemType.replaceAll('Seed_', '').replaceAll('_seed', '').toLowerCase();
		gardenState = GardenStates.PLANTED;
		plantedAt = new DateTime.now();
		_createStageTimes();
		actions = [viewAction];
		setState('planted_baby');

		Clock futureUrTime = new Clock.stoppedAtDate(stage3Time);
		say("Come back at ${futureUrTime.time} and I'll be ready");

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

		int level = await SkillManager.getLevel(SKILL, email);
		bool success = await _setLevelBasedMetabolics(level, 'harvest', email);
		if(!success) {
			return false;
		}

		StatManager.add(email, Stat.crops_harvested);
		SkillManager.learn(SKILL, email);

		//give the player the 'fruits' of their labor
		int count = 1;
		if (level >= 1) {
			count = 2;
		}
		if (level >= 2) {
			//lucky #13 gets you a prize
			if (rand.nextInt(30~/(level-1)) == 13) {
				Item musicblock = items[Crab.randomMusicblock()];
				await InventoryV2.addItemToUser(email, musicblock.getMap(), 1, id);
				toast(
					'You got a ${musicblock.name}!', userSocket,
					onClick: 'iteminfo|${musicblock.name}'
					);
			}
		}
		if (level == 3) {
			//lucky #7 gets you a super harvest
			if (rand.nextInt(10) == 7) {
				count *= 2;
			}
		}
		await InventoryV2.addItemToUser(email, items[plantedWith].getMap(), count, id);
		say();

		plantedWith = '';
		gardenState = GardenStates.NEW;
		plantedState = 0;
		plantedAt = null;
		actions = [hoeAction];
		setState('new');

		return true;
	}
}

class HerbGarden extends Garden {
	HerbGarden(String id, num x, num y, String streetName) : super(id, x, y, streetName);
}
