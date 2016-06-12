part of entity;

class GasPlant extends Tree {
	GasPlant(String id, num x, num y, String streetName) : super(id, x, y, streetName) {
		type = "Gas Plant";
		rewardItemType = "general_vapour";

		responses =
		{
			"harvest": [
				"You want gas? Dude, sure.",
				"Always happy to share, friend.",
				"Yeah, harvest away. Gas is a social thing, friend.",
				"Gas? For you? Yeah, man.",
				"You sure that's enough? Come back for a re-up anytime.",
			],
			"pet": [
				"Awwww yeah.",
				"Hey, do you remember that time when... oh, no, wait, that was Eggy",
				"Petting gives me a sweet, sweet buzz, friend",
				"Good times, man, good times.",
				"Such good energy, man",
			],
			"water": [
				"Woah. That's wet.",
				"Cool, man. Cool.",
				"Sweet can-tipping, friend.",
				"Ahhhh, that's the stuff, kid.",
				"Woah, man! Water! Like, TOTALLY unexpected.",
			]
		};

		states =
		{
			"maturity_1" : new Spritesheet("maturity_1", "http://childrenofur.com/assets/entityImages/trant_gas__f_cap_10_f_num_10_h_10_m_1_seed_0_19191191_png_1354830873.png", 828, 1032, 276, 258, 10, false),
			"maturity_2" : new Spritesheet("maturity_2", "http://childrenofur.com/assets/entityImages/trant_gas__f_cap_10_f_num_10_h_10_m_2_seed_0_19191191_png_1354830875.png", 828, 1032, 276, 258, 10, false),
			"maturity_3" : new Spritesheet("maturity_3", "http://childrenofur.com/assets/entityImages/trant_gas__f_cap_10_f_num_10_h_10_m_3_seed_0_19191191_png_1354830877.png", 828, 1032, 276, 258, 10, false),
			"maturity_4" : new Spritesheet("maturity_4", "http://childrenofur.com/assets/entityImages/trant_gas__f_cap_10_f_num_10_h_10_m_4_seed_0_19191191_png_1354830880.png", 828, 1806, 276, 258, 19, false),
			"maturity_5" : new Spritesheet("maturity_5", "http://childrenofur.com/assets/entityImages/trant_gas__f_cap_10_f_num_10_h_10_m_5_seed_0_19191191_png_1354830883.png", 828, 2064, 276, 258, 24, false),
			"maturity_6" : new Spritesheet("maturity_6", "http://childrenofur.com/assets/entityImages/trant_gas__f_cap_10_f_num_10_h_10_m_6_seed_0_19191191_png_1354830888.png", 828, 2838, 276, 258, 31, false),
			"maturity_7" : new Spritesheet("maturity_7", "http://childrenofur.com/assets/entityImages/trant_gas__f_cap_10_f_num_10_h_10_m_7_seed_0_19191191_png_1354830895.png", 828, 3870, 276, 258, 45, false),
			"maturity_8" : new Spritesheet("maturity_8", "http://childrenofur.com/assets/entityImages/trant_gas__f_cap_10_f_num_10_h_10_m_8_seed_0_19191191_png_1354830902.png", 3312, 1032, 276, 258, 47, false),
			"maturity_9" : new Spritesheet("maturity_9", "http://childrenofur.com/assets/entityImages/trant_gas__f_cap_10_f_num_10_h_10_m_9_seed_0_19191191_png_1354830910.png", 3312, 1032, 276, 258, 47, false),
			"maturity_10" : new Spritesheet("maturity_10", "http://childrenofur.com/assets/entityImages/trant_gas__f_cap_10_f_num_10_h_10_m_10_seed_0_19191191_png_1354830919.png", 3864, 1032, 276, 258, 53, false)
		};
		maturity = new Random().nextInt(states.length) + 1;
		setState('maturity_$maturity');
		state = new Random().nextInt(currentState.numFrames);
		maxState = currentState.numFrames - 1;
	}

	Future<bool> harvest({WebSocket userSocket, String email}) async {
		bool success = await super.harvest(userSocket:userSocket,email:email);

		if(success) {
			StatManager.add(email, Stat.gas_harvested).then((int harvested) {
				if (harvested >= 5003) {
					Achievement.find("obsessive_gas_fancier").awardTo(email);
				} else if (harvested >= 1009) {
					Achievement.find("dedicated_gas_fancier").awardTo(email);
				} else if (harvested >= 503) {
					Achievement.find("hobbyist_gas_fancier").awardTo(email);
				} else if (harvested >= 101) {
					Achievement.find("occasional_gas_fancier").awardTo(email);
				}
			});
		}

		return success;
	}
}