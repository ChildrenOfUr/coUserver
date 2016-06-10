part of entity;

enum GardenStates {
	NEW,
	HOED,
	WATERED,
	PLANTED
}

class Garden extends NPC {
	static bool sentMap = false;
	static Map hoeAction = {"action":"hoe",
		"actionWord":"hoeing",
		"timeRequired":3000,
		"enabled":true,
		"requires":[
			{
				"num":1,
				"of":["hoe", "high_class_hoe"],
				"error": "You don't want to get your fingers dirty."
			},
			{
				"num":5,
				"of":['energy'],
				"error": "You need at least 5 energy to hoe."
			}
		]
	};

	static Map waterAction = {"action":"water",
		"timeRequired":3000,
		"enabled":true,
		"actionWord":"watering",
		"requires":[
			{
				"num":1,
				"of":["watering_can", "irrigator_9000"],
				"error": "Gardens don't like to be peed on. Go find some clean water, please."
			},
			{
				"num": 2,
				"of": ['energy'],
				"error": "You need at least 2 energy to water."
			}
		],
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
	};

	static Map viewAction = {"action":"view",
		"timeRequired":0,
		"enabled":true,
		"actionWord":"viewing",
	};

	GardenStates gardenState = GardenStates.NEW;
	String plantedWith = 'none';
	int plantedState = -1;

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

		if (metadata.containsKey('respawn')) {
			respawn = new DateTime.fromMillisecondsSinceEpoch(int.parse(metadata['respawn']));
		}
	}

	Map<String, String> getPersistMetadata() {
		return {
			'gardenState': gardenState.index.toString(),
			'currentState': currentState.stateName,
			'plantedWith': plantedWith,
			'plantedState': plantedState.toString(),
			'respawn': respawn.millisecondsSinceEpoch.toString()
		};
	}

	@override
	void update() {
		if (gardenState != GardenStates.PLANTED) {
			return;
		}

		DateTime now = new DateTime.now();
		if (respawn == null || respawn.isBefore(now)) {
			//upgrade the plant here and reset the respawn
			if (plantedState < 3) {
				plantedState++;

				if (plantedState == 0) {
					setState('planted_baby');
				} else {
					String stateKey = '${plantedWith}_${plantedState}';
					if (states.containsKey(stateKey)) {
						setState(stateKey);
					}
				}
				respawn = now.add(new Duration(minutes: 5));
			}
		}
	}

	Future<bool> hoe({WebSocket userSocket, String email}) async {
		if (gardenState != GardenStates.NEW) {
			return false;
		}

		gardenState = GardenStates.HOED;
		actions = [waterAction];
		setState('hoed');
		return true;
	}

	Future<bool> water({WebSocket userSocket, String email}) async {
		if (gardenState != GardenStates.HOED) {
			return false;
		}

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

		plantedWith = itemType.replaceAll('Seed_', '').toLowerCase();
		gardenState = GardenStates.PLANTED;
		actions = [viewAction];
		setState('planted_baby');

		return true;
	}

	Future<bool> view({WebSocket userSocket, String email}) async {
		say('I am currently growing a $plantedWith');
		return true;
	}
}