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

	/// For all types of gardens
	static final Map<String, List<String>> RESPONSES_GENERAL = {
		"broken_hoe": [
			"That's one broken down hoe.",
			"Woah! You've cracked your hoe.",
			"Hoe no.",
		],
		"broken_watering_can": [
			"I think you've cracked your can.",
			"Hey, your spout is futzed.",
			"Watering can? Watering can't, more like.",
		],
	};

	/// For only crop gardens
	static final Map<String, List<String>> RESPONSES_CROP = {
		"clear": [
			"Yeeaaah...",
			"Always feels better when a friend does it.",
			"Good scritchings.",
			"Mmmm. Scratchy.",
			"All clean!",
			"Better.",
			"Nice. And clean.",
			"Feels nicererer.",
		],
		"clear_drop_large": [
			"It's dangerous to go alone! Take this.",
			"Hey, look what I found in my soil.",
			"Hoe-ly gift unearthing, Glitchling!",
			"Because you unurthed it.",
		],
		"clear_drop_small": [
			"Hoe hoe hoe! You hoed up a thing!",
			"You look like you could use this. What is it?",
			"Ta dah! It is a THING! For YOU!",
			"Little thing for you. For thanks.",
		],
		"fertilize": [
			"Nutrientized!",
			"Woo! Batstuff!",
			"Smelly.",
			"NNNNNGGGG! I am growing Very Hard!",
			"Look at me! I'm GROWING!",
			"Wheeeeee!",
		],
		"harvest": [
			"Here! Fruits... no, um, cropses of your labour.",
			"Those'll make your hair curly.",
			"I made these! Just for you.",
			"I made you eaty stuff.",
			"Look! Foodstuffs!",
			"Happy Cropday!",
			"Look, seeds turned all into these!",
			"These will put hair on your chest. Maybe. Maybe just upper arms.",
			"Oh croppy day!",
			"Noms.",
		],
		"harvest_2x": [
			"A little extra…",
			"You got lucky!",
			"Oooh, big cropsies!",
			"Dedicated crop-planters deserve happy croppy rewards.",
		],
		"harvest_3x": [
			"I didn't think I had it in me!",
			"Bumper cropsies!",
			"Maxi-sized croppables!",
			"Croppabanzai!",
		],
		"harvest_4x": [
			"You gonna eat all those?",
			"Super-ooper-doooper cropsies!",
			"Supersized croppsicle joy!",
			"Croppabonanza!",
		],
		"harvest_drop": [
			"You'll never get me lucky charms.",
			"Mmmm, tasty rainbows!",
			"Pyew!  Rainbow!  Pyew pyew!",
		],
		"harvest_na_failed": [
			"No. I like these. You can't have them.",
			"Say please.",
			"You mis-picked. You picked nothin'. Try harder, picky-picker.",
		],
		"plant": [
			"Consider me seeded.",
			"Good planting!",
			"That tickles!",
			"I am super-seedy!",
			"Yay!",
			"Nom nom nom nom nom.",
			"Mmm. Seedy.",
			"Ohhhhh. I will GROW this!",
			"Hee! Tickly in my seed-tumkin!",
			"Ah. Planting the seeds of tomorrow, today.",
		],
		"plant_drop_large": [
			"I don't have room for this too. You take this.",
			"Hey, look what I found in my soil! Crazy!",
			"Seeds need room to grow. This too big. You take.",
			"You have this.",
		],
		"plant_drop_small": [
			"I don't want this anymore. You have!",
			"You look like Glitchling that could make use of this.",
			"I found a thing!",
			"Oooh, goodies. For you!",
		],
		"water": [
			"Wet!",
			"I'm Wet!",
			"You wet me.",
			"Oh I'm all wet.",
			"Splosh.",
			"Wetted.",
			"Oh!",
			"I am wet!",
			"Ooh! Wet!",
			"Jeepers, that's moist.",
		],
		"water_drop_large": [
			"Oooh, have that special card, do you? Here, have this too.",
			"Pizzazzy watering! I give you treat.",
			"This washed to surface. Want it?",
			"Water dislodged thing. Don't want it.",
		],
		"water_drop_small": [
			"Good things come to those who water.",
			"For your trouble, little cloud.",
			"Look! I found you this!",
			"Found thing for you! It is a bit damp.",
		],
		"water_na_failed": [
			"Oh. Water everywhere. Everywhere but on me. Try again.",
			"You missed.",
			"Aim better! I am not wet!",
		],
	};

	static String _randomResponse(String action, Map<String, List<String>> pool) =>
		pool[action][rand.nextInt(pool[action].length)];

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

	Garden(String id, num x, num y, num z, num rotation, bool h_flip, String streetName) : super(id, x, y, z, rotation, h_flip, streetName) {
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
	void update({bool simulateTick: false}) {
		super.update();

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

		say(_randomResponse('clear', RESPONSES_CROP)); // display gains

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

		say(_randomResponse('water', RESPONSES_CROP)); // display gains

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
		say(_randomResponse('plant', RESPONSES_CROP) + " Come back at ${futureUrTime.time} and I'll be ready.");

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

		String responseType = 'harvest';

		StatManager.add(email, Stat.crops_harvested);
		SkillManager.learn(SKILL, email);

		//give the player the 'fruits' of their labor
		int count = 1;
		if (level >= 1) {
			count = 2;
			responseType = 'harvest_2x';
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
				responseType = 'harvest_drop';
			}
		}
		if (level == 3) {
			//lucky #7 gets you a super harvest
			if (rand.nextInt(10) == 7) {
				count *= 2;

				if (responseType == 'harvest_2x') {
					responseType = 'harvest_4x';
				} else {
					responseType = 'harvest_3x';
				}
			}
		}
		await InventoryV2.addItemToUser(email, items[plantedWith].getMap(), count, id);
		say(_randomResponse(responseType, RESPONSES_CROP));

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
	/// For only herb gardens
	static final Map<String, List<String>> RESPONSES_HERB = {
		"clear": [
			"Smooth.",
			"Fresh.",
			"I feel like a new plot!",
			"Plant me up!",
			"I'm ready.",
			"Left a bit? Ahhh.",
			"Nice work, hoe-meister.",
			"Ahhh, all hoed up.",
		],
		"clear_drop": [
			"Take this for your trouble. And get shucking.",
			"You de-soiled this with your red hot hoeing!",
			"*COUGH*. Woah! You dislodged this!",
			"What the…?!? Oh, just take it.",
		],
		"fertilize": [
			"Mmm, smells like nutrients.",
			"Heady. Strong. POWER FILLED.",
			"Stand back, I'm growing.",
			"AlakaZAM.",
			"I feel… mighty.",
			"Guano? Oooh, I'm getting angry. You'll like me when I'm angry.",
		],
		"harvest": [
			"Herbs!",
			"Erbs!",
			"Bitter to the tongue, sweet to the mind.",
			"Be wise.",
			"Be happy.",
			"Just say yes.",
			"Here's your herbs.",
			"'Ere's your 'erbs.",
			"That *ahem* stuff you wanted.",
			"It's herb o'clock. Woo.",
		],
		"harvest_2x": [
			"Herbal bonus.",
			"More! More herbs!",
			"POW! Herb it up!",
			"Herb THIS.",
		],
		"harvest_3x": [
			"DAYAM!",
			"Are you ready? It's the Motherlode of herbs. The motherbalode!",
			"Herbs! All the herbs!",
			"High time for heavy herbal bonus? HELL YEAH.",
		],
		"harvest_na_failed": [
			"Nooooo. My precious! Cannot take my precious herbs. Mineses.",
			"Hoe no. Hoe no no no.",
			"The roots run deep on this one.",
		],
		"plant": [
			"Wahey!",
			"Wow. Planty.",
			"Hot seed action.",
			"Ahhh.",
			"*Gulp*",
			"Yowzers.",
			"Seedy.",
			"I like it seedy.",
			"Munch munch munch.",
			"That's one big seed.",
		],
		"plant_drop": [
			"Hey, look what I found in my soil.",
			"Yowza! How'd THAT get there?",
			"Take this. Might want to wipe it off first.",
			"Shhh. Take this. Say nothing.",
		],
		"water": [
			"Mmm... electrolytes.",
			"Niiiiiiice.",
			"Ahh.",
			"Cool.",
			"Good. Mmmm.",
			"Spoosh.",
			"Ahhhhhh.",
			"I like it wet.",
			"Blublublub.",
			"Right on.",
		],
		"water_drop": [
			"This bubbled up. Have it.",
			"*Burrrrrrp*",
			"*Cough* Oh! Will you look at that?",
			"I don't want to get this wet. Take it.",
		],
		"water_na_failed": [
			"Dry as a bone.",
			"Dry, friend. Try again.",
			"Somehow, you missed. I'm as mystified as you.",
		],
	};

	HerbGarden(String id, num x, num y, num z, num rotation, bool h_flip, String streetName) : super(id, x, y, z, rotation, h_flip, streetName);
}
