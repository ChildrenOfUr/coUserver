part of entity;

class BeanTree extends Tree {
	BeanTree(String id, num x, num y, String streetName) : super(id, x, y, streetName) {
		type = "Bean Tree";
		rewardItemType = "bean";

		responses =
		{
			"harvest": [
				"Is that what you've bean looking for?",
				"Cool. Beans. Cool beans!",
				"Two bean, or not two bean?…",
				"You favored us. Now, we fava you. Ha ha. Like \"fava bean\".",
				"Wassssss-sap! Ha ha ha. Oh just take bean then.",
				"Have you seen Jack? I think I gave him the wrong seeds…"
			],
			"pet": [
				"The petting is unbeleafable. Ha ha. Tree made joke. Laugh.",
				"Tiny Glitch is very poplar with us. Ha ha.",
				"Your petting's never bean better. Hee!",
				"I wooden have thought you'd be so good. Now laugh.",
				"Tree arbors strong feelings to you. Chuckle now, please.",
				"Well it’s bean fun! See you later."
			],
			"water": [
				"Water nice thing to do. Ha! Ha ha?",
				"Trunk you very much. Ha ha. We made joke. Laugh.",
				"Thought you'd never pull the twigger. Joke.",
				"Cheers, bud.",
				"How kind you're bean. Ha ha. \"Bean\".",
			]
		};

		states =
		{
			"maturity_1" : new Spritesheet("maturity_1", "http://childrenofur.com/assets/entityImages/trant_bean__f_cap_10_f_num_10_h_10_m_1_seed_0_191991191_png_1354829640.png", 990, 540, 198, 270, 9, false),
			"maturity_2" : new Spritesheet("maturity_2", "http://childrenofur.com/assets/entityImages/trant_bean__f_cap_10_f_num_10_h_10_m_2_seed_0_191991191_png_1354829642.png", 990, 540, 198, 270, 9, false),
			"maturity_3" : new Spritesheet("maturity_3", "http://childrenofur.com/assets/entityImages/trant_bean__f_cap_10_f_num_10_h_10_m_3_seed_0_191991191_png_1354829643.png", 990, 540, 198, 270, 9, false),
			"maturity_4" : new Spritesheet("maturity_4", "http://childrenofur.com/assets/entityImages/trant_bean__f_cap_10_f_num_10_h_10_m_4_seed_0_191991191_png_1354829645.png", 990, 2430, 198, 270, 41, false),
			"maturity_5" : new Spritesheet("maturity_5", "http://childrenofur.com/assets/entityImages/trant_bean__f_cap_10_f_num_10_h_10_m_5_seed_0_191991191_png_1354829648.png", 990, 2970, 198, 270, 51, false),
			"maturity_6" : new Spritesheet("maturity_6", "http://childrenofur.com/assets/entityImages/trant_bean__f_cap_10_f_num_10_h_10_m_6_seed_0_191991191_png_1354829652.png", 990, 3240, 198, 270, 57, false),
			"maturity_7" : new Spritesheet("maturity_7", "http://childrenofur.com/assets/entityImages/trant_bean__f_cap_10_f_num_10_h_10_m_7_seed_0_191991191_png_1354829655.png", 990, 3240, 198, 270, 59, false),
			"maturity_8" : new Spritesheet("maturity_8", "http://childrenofur.com/assets/entityImages/trant_bean__f_cap_10_f_num_10_h_10_m_8_seed_0_191991191_png_1354829659.png", 990, 3510, 198, 270, 65, false),
			"maturity_9" : new Spritesheet("maturity_9", "http://childrenofur.com/assets/entityImages/trant_bean__f_cap_10_f_num_10_h_10_m_9_seed_0_191991191_png_1354829664.png", 990, 3780, 198, 270, 66, false),
			"maturity_10" : new Spritesheet("maturity_10", "http://childrenofur.com/assets/entityImages/trant_bean__f_cap_10_f_num_10_h_10_m_10_seed_0_191991191_png_1354829669.png", 990, 3780, 198, 270, 68, false)
		};
		maturity = new Random().nextInt(states.length) + 1;
		setState('maturity_$maturity');
		state = new Random().nextInt(currentState.numFrames);
		maxState = currentState.numFrames - 1;
	}

	Future<bool> harvest({WebSocket userSocket, String email}) async {
		bool success = await super.harvest(userSocket:userSocket,email:email);

		if(success) {
			StatManager.add(email, Stat.beans_harvested).then((int harvested) {
				if (harvested >= 5003) {
					Achievement.find("master_bean_counter").awardTo(email);
				} else if (harvested >= 1009) {
					Achievement.find("bean_counter_pro").awardTo(email);
				} else if (harvested >= 503) {
					Achievement.find("bean_counter").awardTo(email);
				} else if (harvested >= 101) {
					Achievement.find("participant_award_bean_division").awardTo(email);
				}
			});
		}

		return success;
	}

	Future<bool> pet({WebSocket userSocket, String email}) async {
		bool success = await super.pet(userSocket: userSocket, email: email);

		if (success) {
			StatManager.add(email, Stat.bean_trees_petted).then((int stat) {
				if (stat >= 127) {
					Achievement.find("professional_bean_tree_fondler").awardTo(email);
				} else if (stat >= 41) {
					Achievement.find("notquitepro_bean_tree_fondler").awardTo(email);
				} else if (stat >= 11) {
					Achievement.find("amateur_bean_tree_fondler").awardTo(email);
				}
			});
		}

		return success;
	}

	Future<bool> water({WebSocket userSocket, String email}) async {
		bool success = await super.water(userSocket: userSocket, email: email);

		if (success) {
			StatManager.add(email, Stat.bean_trees_watered).then((int stat) {
				if (stat >= 41) {
					Achievement.find("betterthanlousy_douser").awardTo(email);
				}
			});
		}

		return success;
	}
}
