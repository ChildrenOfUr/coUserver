part of entity;

class FruitTree extends Tree {
	FruitTree(String id, num x, num y, String streetName) : super(id, x, y, streetName) {
		type = "Fruit Tree";
		rewardItemType = "cherry";

		responses =
		{
			"harvest": [
				"Fruity!",
				"Ta-daaaaaaa…",
				"Yaaaaaay!",
				"Frooooot!",
				"C'est la!",
				"Oof. Take this. Heavy."
			],
			"pet": [
				"Huh?",
				"Oh.",
				"Whu?",
				"Ah.",
				"Pff.",
				"Together we make a great pear"
			],
			"water": [
				"Hm?",
				"Ahh.",
				"Glug.",
				"Mm?",
				"Shhhlrp.",
			]
		};

		states =
		{
			"maturity_1" : new Spritesheet("maturity_1", "http://childrenofur.com/assets/entityImages/trant_fruit__f_cap_10_f_num_10_h_10_m_1_seed_0_111119119_png_1354830639.png", 813, 996, 271, 249, 10, false),
			"maturity_2" : new Spritesheet("maturity_2", "http://childrenofur.com/assets/entityImages/trant_fruit__f_cap_10_f_num_10_h_10_m_2_seed_0_111119119_png_1354830641.png", 813, 996, 271, 249, 10, false),
			"maturity_3" : new Spritesheet("maturity_3", "http://childrenofur.com/assets/entityImages/trant_fruit__f_cap_10_f_num_10_h_10_m_3_seed_0_111119119_png_1354830644.png", 813, 996, 217, 249, 10, false),
			"maturity_4" : new Spritesheet("maturity_4", "http://childrenofur.com/assets/entityImages/trant_fruit__f_cap_10_f_num_10_h_10_m_4_seed_0_111119119_png_1354830647.png", 813, 1992, 271, 249, 22, false),
			"maturity_5" : new Spritesheet("maturity_5", "http://childrenofur.com/assets/entityImages/trant_fruit__f_cap_10_f_num_10_h_10_m_5_seed_0_111119119_png_1354830651.png", 813, 2739, 271, 249, 33, false),
			"maturity_6" : new Spritesheet("maturity_6", "http://childrenofur.com/assets/entityImages/trant_fruit__f_cap_10_f_num_10_h_10_m_6_seed_0_111119119_png_1354830658.png", 813, 3735, 271, 249, 43, false),
			"maturity_7" : new Spritesheet("maturity_7", "http://childrenofur.com/assets/entityImages/trant_fruit__f_cap_10_f_num_10_h_10_m_7_seed_0_111119119_png_1354830664.png", 3523, 996, 271, 249, 50, false),
			"maturity_8" : new Spritesheet("maturity_8", "http://childrenofur.com/assets/entityImages/trant_fruit__f_cap_10_f_num_10_h_10_m_8_seed_0_111119119_png_1354830670.png", 3794, 996, 271, 249, 53, false),
			"maturity_9" : new Spritesheet("maturity_9", "http://childrenofur.com/assets/entityImages/trant_fruit__f_cap_10_f_num_10_h_10_m_9_seed_0_111119119_png_1354830677.png", 4065, 996, 271, 249, 57, false),
			"maturity_10" : new Spritesheet("maturity_10", "http://childrenofur.com/assets/entityImages/trant_fruit__f_cap_10_f_num_10_h_10_m_10_seed_0_111119119_png_1354830686.png", 4065, 996, 271, 249, 60, false)
		};
		maturity = new Random().nextInt(states.length) + 1;
		setState('maturity_$maturity');
		state = new Random().nextInt(currentState.numFrames);
		maxState = currentState.numFrames - 1;
	}

	Future<bool> harvest({WebSocket userSocket, String email}) async {
		bool success = await super.harvest(userSocket:userSocket,email:email);

		if(success) {
			StatManager.add(email, Stat.cherries_harvested).then((int harvested) {
				if (harvested >= 5003) {
					Achievement.find("president_and_ceo_of_fruit_tree_harvesting_inc").awardTo(email);
				} else if (harvested >= 1009) {
					Achievement.find("overpaid_executive_fruit_tree_harvester").awardTo(email);
				} else if (harvested >= 503) {
					Achievement.find("midmanagement_fruit_tree_harvester").awardTo(email);
				} else if (harvested >= 101) {
					Achievement.find("entrylevel_fruit_tree_harvester").awardTo(email);
				}
			});
		}

		return success;
	}
}
