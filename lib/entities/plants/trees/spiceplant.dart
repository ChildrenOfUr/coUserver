part of entity;

class SpicePlant extends Tree {
	SpicePlant(String id, num x, num y, String streetName) : super(id, x, y, streetName) {
		type = "Spice Plant";
		rewardItemType = "allspice";

		responses =
		{
			"harvest": [
				"Ahhh, spicy, spicy, spicy…",
				"My my, you can't get enough of ol' Spicy, can you?",
				"You can harvest me whenever you like, poppet.",
				"Here, my pretty. Spice up your life.",
				"As they say, spice is the spice of… no, that's not right.",
			],
			"pet": [
				"Eh? What? How nice…",
				"My, my: such soft hands.",
				"Oh my! This is unexpectedly satisfying…",
				"Well I never...",
				"Nice job, kid, but could be spicier. Know whaddai mean?",
			],
			"water": [
				"Oh! No, carry on, I like it.",
				"Goodness, sneak up on an old tree, why don't you?",
				"Water? Well, I suppose I might partake…",
				"Well well! That's a pleasant surprise.",
				"Ahhhh, you flatter me with this sprinkling.",
			]
		};

		states =
		{
			"maturity_1" : new Spritesheet("maturity_1", "http://childrenofur.com/assets/entityImages/trant_spice__f_cap_10_f_num_10_h_10_m_1_seed_0_191119119_png_1354830923.png", 954, 1000, 318, 250, 10, false),
			"maturity_2" : new Spritesheet("maturity_2", "http://childrenofur.com/assets/entityImages/trant_spice__f_cap_10_f_num_10_h_10_m_2_seed_0_191119119_png_1354830925.png", 954, 1000, 318, 250, 10, false),
			"maturity_3" : new Spritesheet("maturity_3", "http://childrenofur.com/assets/entityImages/trant_spice__f_cap_10_f_num_10_h_10_m_3_seed_0_191119119_png_1354830927.png", 954, 1000, 318, 250, 10, false),
			"maturity_4" : new Spritesheet("maturity_4", "http://childrenofur.com/assets/entityImages/trant_spice__f_cap_10_f_num_10_h_10_m_4_seed_0_191119119_png_1354830932.png", 954, 3000, 318, 250, 35, false),
			"maturity_5" : new Spritesheet("maturity_5", "http://childrenofur.com/assets/entityImages/trant_spice__f_cap_10_f_num_10_h_10_m_5_seed_0_191119119_png_1354830937.png", 954, 3750, 318, 250, 45, false),
			"maturity_6" : new Spritesheet("maturity_6", "http://childrenofur.com/assets/entityImages/trant_spice__f_cap_10_f_num_10_h_10_m_6_seed_0_191119119_png_1354830942.png", 3498, 1250, 318, 250, 54, false),
			"maturity_7" : new Spritesheet("maturity_7", "http://childrenofur.com/assets/entityImages/trant_spice__f_cap_10_f_num_10_h_10_m_7_seed_0_191119119_png_1354830948.png", 3816, 1250, 318, 250, 57, false),
			"maturity_8" : new Spritesheet("maturity_8", "http://childrenofur.com/assets/entityImages/trant_spice__f_cap_10_f_num_10_h_10_m_8_seed_0_191119119_png_1354830955.png", 3498, 1500, 318, 250, 66, false),
			"maturity_9" : new Spritesheet("maturity_9", "http://childrenofur.com/assets/entityImages/trant_spice__f_cap_10_f_num_10_h_10_m_9_seed_0_191119119_png_1354830962.png", 3498, 1500, 318, 250, 66, false),
			"maturity_10" : new Spritesheet("maturity_10", "http://childrenofur.com/assets/entityImages/trant_spice__f_cap_10_f_num_10_h_10_m_10_seed_0_191119119_png_1354830969.png", 3498, 1500, 318, 250, 66, false)
		};
		maturity = new Random().nextInt(states.length) + 1;
		setState('maturity_$maturity');
		state = new Random().nextInt(currentState.numFrames);
		maxState = currentState.numFrames - 1;
	}

	Future<bool> harvest({WebSocket userSocket, String email}) async {
		bool success = await super.harvest(userSocket:userSocket,email:email);

		if(success) {
			StatManager.add(email, Stat.spice_harvested).then((int harvested) {
				if (harvested >= 5003) {
					Achievement.find("master_overlord_of_the_spice_dominion").awardTo(email);
				} else if (harvested >= 1009) {
					Achievement.find("advanced_spice_collector").awardTo(email);
				} else if (harvested >= 503) {
					Achievement.find("intermediate_spice_collector").awardTo(email);
				} else if (harvested >= 101) {
					Achievement.find("novice_spice_collector").awardTo(email);
				}
			});
		}

		return success;
	}

	Future<bool> pet({WebSocket userSocket, String email}) async {
		bool success = await super.pet(userSocket: userSocket, email: email);

		if (success) {
			StatManager.add(email, Stat.spice_plants_petted).then((int stat) {
				if (stat >= 127) {
					Achievement.find("heavy_petter").awardTo(email);
				} else if (stat >= 41) {
					Achievement.find("confident_petter").awardTo(email);
				} else if (stat >= 11) {
					Achievement.find("tentative_petter").awardTo(email);
				}
			});
		}

		return success;
	}

	Future<bool> water({WebSocket userSocket, String email}) async {
		bool success = await super.water(userSocket: userSocket, email: email);

		if (success) {
			StatManager.add(email, Stat.spice_plants_watered).then((int stat) {
				if (stat >= 41) {
					Achievement.find("big_splasher").awardTo(email);
				} else if (stat >= 11) {
					Achievement.find("beginner_drizzler").awardTo(email);
				}
			});
		}

		return success;
	}
}
