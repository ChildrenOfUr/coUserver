part of entity;

class EggPlant extends Tree {
	EggPlant(String id, num x, num y, String streetName) : super(id, x, y, streetName) {
		type = "Egg Plant";
		rewardItemType = "egg";

		responses =
		{
			"harvest": [
				"This. For you.",
				"We grew this. You take.",
				"This harvest good. Have it.",
				"Ooooof. Take harvest. Heavy.",
				"We made this. You can have.",
			],
			"pet": [
				"Petting approved.",
				"Think petting good. Builds brain.",
				"Much gooder. Egg Plant grows in body and brain.",
				"Egg plant grows stronger. Cleverer. And eggier.",
				"Yes. Petting makes brain and eggs biggerer.",
			],
			"water": [
				"Ahhhhh. Better.",
				"Water good. We feel gratitude.",
				"Glug. Thanks.",
				"Yes. Liquid helps make harvests. Good.",
				"Good watering. But we still like petting too, comprende?",
			]
		};

		states =
		{
			"maturity_1" : new Spritesheet("maturity_1", "http://childrenofur.com/assets/entityImages/trant_egg__f_cap_10_f_num_10_h_10_m_1_seed_0_11191191_png_1354829612.png", 888, 278, 296, 278, 3, false),
			"maturity_2" : new Spritesheet("maturity_2", "http://childrenofur.com/assets/entityImages/trant_egg__f_cap_10_f_num_10_h_10_m_2_seed_0_11191191_png_1354829613.png", 888, 278, 296, 278, 3, false),
			"maturity_3" : new Spritesheet("maturity_3", "http://childrenofur.com/assets/entityImages/trant_egg__f_cap_10_f_num_10_h_10_m_3_seed_0_11191191_png_1354829614.png", 592, 556, 296, 278, 4, false),
			"maturity_4" : new Spritesheet("maturity_4", "http://childrenofur.com/assets/entityImages/trant_egg__f_cap_10_f_num_10_h_10_m_4_seed_0_11191191_png_1354829616.png", 888, 1390, 296, 278, 14, false),
			"maturity_5" : new Spritesheet("maturity_5", "http://childrenofur.com/assets/entityImages/trant_egg__f_cap_10_f_num_10_h_10_m_5_seed_0_11191191_png_1354829618.png", 888, 1946, 296, 278, 19, false),
			"maturity_6" : new Spritesheet("maturity_6", "http://childrenofur.com/assets/entityImages/trant_egg__f_cap_10_f_num_10_h_10_m_6_seed_0_11191191_png_1354829621.png", 888, 2502, 296, 278, 26, false),
			"maturity_7" : new Spritesheet("maturity_7", "http://childrenofur.com/assets/entityImages/trant_egg__f_cap_10_f_num_10_h_10_m_7_seed_0_11191191_png_1354829624.png", 888, 3336, 296, 278, 34, false),
			"maturity_8" : new Spritesheet("maturity_8", "http://childrenofur.com/assets/entityImages/trant_egg__f_cap_10_f_num_10_h_10_m_8_seed_0_11191191_png_1354829628.png", 888, 3336, 296, 278, 34, false),
			"maturity_9" : new Spritesheet("maturity_9", "http://childrenofur.com/assets/entityImages/trant_egg__f_cap_10_f_num_10_h_10_m_9_seed_0_11191191_png_1354829632.png", 3256, 1112, 296, 278, 44, false),
			"maturity_10" : new Spritesheet("maturity_10", "http://childrenofur.com/assets/entityImages/trant_egg__f_cap_10_f_num_10_h_10_m_10_seed_0_11191191_png_1354829638.png", 3256, 1390, 296, 278, 55, false)
		};
		maturity = new Random().nextInt(states.length) + 1;
		setState('maturity_$maturity');
		state = new Random().nextInt(currentState.numFrames);
		maxState = currentState.numFrames - 1;
	}

	Future<bool> harvest({WebSocket userSocket, String email}) async {
		bool success = await super.harvest(userSocket:userSocket,email:email);

		if(success) {
			StatManager.add(email, Stat.eggs_harveted).then((int harvested) {
				if (harvested >= 5003) {
					Achievement.find("egg_freak").awardTo(email);
				} else if (harvested >= 1009) {
					Achievement.find("egg_aficianado").awardTo(email);
				} else if (harvested >= 503) {
					Achievement.find("egg_poacher").awardTo(email);
				} else if (harvested >= 101) {
					Achievement.find("egg_enthusiast").awardTo(email);
				}
			});
		}

		return success;
	}

	Future<bool> pet({WebSocket userSocket, String email}) async {
		bool success = await super.pet(userSocket: userSocket, email: email);

		if (success) {
			StatManager.add(email, Stat.egg_plants_petted).then((int stat) {
				if (stat >= 127) {
					Achievement.find("super_supreme_egg_plant_coddler").awardTo(email);
				} else if (stat >= 41) {
					Achievement.find("supreme_egg_plant_coddler").awardTo(email);
				} else if (stat >= 11) {
					Achievement.find("egg_plant_coddler").awardTo(email);
				}
			});
		}

		return success;
	}

	Future<bool> water({WebSocket userSocket, String email}) async {
		bool success = await super.water(userSocket: userSocket, email: email);

		if (success) {
			StatManager.add(email, Stat.egg_plants_watered).then((int stat) {
				if (stat >= 41) {
					Achievement.find("about_average_irrigationist").awardTo(email);
				}
			});
		}

		return success;
	}
}
