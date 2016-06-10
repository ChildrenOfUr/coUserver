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
		"timeRequired":3000,
		"enabled":true,
		"actionWord":"planting",
		"requires":[
			{
				"num": 1,
				"of": ['Seed_Broccoli','Seed_Cabbage','Seed_Carrot','Seed_Corn',
				       'Seed_Cucumber','Seed_Onion','Seed_Parsnip','Seed_Potato',
				       'Seed_Pumpkin','Seed_Rice','Seed_Spinach','Seed_Tomato','Seed_Zucchini'],
				"error": "You need some crop seeds to plant."
			},
			{
				"num": 3,
				"of": ['energy'],
				"error": "You need at least 3 energy to plant."
			}
		],
	};

	GardenStates gardenState = GardenStates.NEW;

	Garden(String id, int x, int y, String streetName) : super(id, x, y, streetName) {
		type = "Crop Garden";
		states =
		{
			'new' : new Spritesheet('new', "http://childrenofur.com/assets/entityImages/garden_plot_new.png", 100, 53, 100, 53, 1, false),
			'hoed' : new Spritesheet('hoed', "http://childrenofur.com/assets/entityImages/garden_plot_hoed.png", 100, 53, 100, 53, 1, false),
			'watered' : new Spritesheet('watered', "http://childrenofur.com/assets/entityImages/garden_plot_watered.png", 100, 53, 100, 53, 1, false),
			'planted_baby' : new Spritesheet('planted_baby', "http://childrenofur.com/assets/entityImages/garden_plot_planted_baby.png", 100, 53, 100, 53, 1, false)
		};
		setState('new');
		actions = [hoeAction];
	}

	void restoreState(Map<String, String> metadata) {
		if (metadata.containsKey('currentState')) {
			setState(metadata['currentState']);
		}
	}

	Map<String, String> getPersistMetadata() {
		return {'currentState': currentState.stateName};
	}

	@override
	void update() {

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

		gardenState = GardenStates.PLANTED;
		actions = [];
		setState('planted_baby');
		return true;
	}
}