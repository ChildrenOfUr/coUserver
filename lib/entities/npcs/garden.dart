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
				"of": ['broccoli_seed','cabbage_seed','carrot_seed','corn_seed',
				       'cucumber_seed','onion_seed','parsnip_seed','potato_seed',
				       'pumpkin_seed','rice_seed','spinach_seed','tomato_seed','zucchini_seed'],
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

	@override
	void update() {

	}

	Future<bool> hoe({WebSocket userSocket, String email}) async {
		gardenState = GardenStates.HOED;
		actions = [waterAction];
		setState('hoed');
		return true;
	}

	Future<bool> water({WebSocket userSocket, String email}) async {
		gardenState = GardenStates.WATERED;
		actions = [plantAction];
		setState('watered');
		return true;
	}

	Future<bool> plant({WebSocket userSocket, String email}) async {
		gardenState = GardenStates.PLANTED;
		actions = [];
		setState('planted_baby');
		return true;
	}
}