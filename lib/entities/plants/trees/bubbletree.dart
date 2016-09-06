part of entity;

class BubbleTree extends Tree {
	BubbleTree(String id, num x, num y, num z, num rotation, bool h_flip, String streetName) : super(id, x, y, z, rotation, h_flip, streetName) {
		type = "Bubble Tree";
		rewardItemType = "plain_bubble";

		responses =
		{
			"harvest": [
				"…know the power you hold in your hands…",
				"Bubbles. Precious bubbles. Just for you. Pop-pop!",
				"…which is why harvesting is crucial to… Oh! Shh.",
				"Wait, my tin hat didn't fall in with that haul, right?",
				"…Again? You're up to something, I sense it.",
			],
			"pet": [
				"Wait! Shh. Did you hear that? Never mind. Pretend you didn't.",
				"...a nice BLT: a batterfly, lettuce and tomato sandwich, and...",
				"... big difference between mostly dead and all dead. And...",
				"...shh! Can't talk now! Tin foil hat compromised! More later!…",
				"...went pop! Pop pop pop!  Until it was all dark, and then...",
			],
			"water": [
				"…what's that? Wet? Huh?",
				"Huh? Something for nothing, eh?",
				"I don't trust watering cans. But you're ok.",
				"…all in it together. SHHH! Someone's listening…",
				"…in the caves. But it only LOOKED like an accident…",
			]
		};

		states =
		{
			"maturity_1" : new Spritesheet("maturity_1", "http://childrenofur.com/assets/entityImages/trant_bubble__f_cap_10_f_num_10_h_10_m_1_seed_0_119919911_png_1354830122.png", 835, 554, 167, 277, 9, false),
			"maturity_2" : new Spritesheet("maturity_2", "http://childrenofur.com/assets/entityImages/trant_bubble__f_cap_10_f_num_10_h_10_m_2_seed_0_119919911_png_1354830123.png", 835, 554, 167, 277, 9, false),
			"maturity_3" : new Spritesheet("maturity_3", "http://childrenofur.com/assets/entityImages/trant_bubble__f_cap_10_f_num_10_h_10_m_3_seed_0_119919911_png_1354830125.png", 835, 554, 167, 277, 10, false),
			"maturity_4" : new Spritesheet("maturity_4", "http://childrenofur.com/assets/entityImages/trant_bubble__f_cap_10_f_num_10_h_10_m_4_seed_0_119919911_png_1354830127.png", 835, 2493, 167, 277, 44, false),
			"maturity_5" : new Spritesheet("maturity_5", "http://childrenofur.com/assets/entityImages/trant_bubble__f_cap_10_f_num_10_h_10_m_5_seed_0_119919911_png_1354830131.png", 835, 3601, 167, 277, 61, false),
			"maturity_6" : new Spritesheet("maturity_6", "http://childrenofur.com/assets/entityImages/trant_bubble__f_cap_10_f_num_10_h_10_m_6_seed_0_119919911_png_1354830279.png", 835, 3601, 167, 277, 62, false),
			"maturity_7" : new Spritesheet("maturity_7", "http://childrenofur.com/assets/entityImages/trant_bubble__f_cap_10_f_num_10_h_10_m_7_seed_0_119919911_png_1354830283.png", 4008, 831, 167, 277, 72, false),
			"maturity_8" : new Spritesheet("maturity_8", "http://childrenofur.com/assets/entityImages/trant_bubble__f_cap_10_f_num_10_h_10_m_8_seed_0_119919911_png_1354830289.png", 4008, 831, 167, 277, 72, false),
			"maturity_9" : new Spritesheet("maturity_9", "http://childrenofur.com/assets/entityImages/trant_bubble__f_cap_10_f_num_10_h_10_m_9_seed_0_119919911_png_1354830295.png", 4008, 831, 167, 277, 72, false),
			"maturity_10" : new Spritesheet("maturity_10", "http://childrenofur.com/assets/entityImages/trant_bubble__f_cap_10_f_num_10_h_10_m_10_seed_0_119919911_png_1354830301.png", 3173, 1108, 167, 277, 76, false)
		};
		maturity = new Random().nextInt(states.length) + 1;
		setState('maturity_$maturity');
		state = new Random().nextInt(currentState.numFrames);
		maxState = currentState.numFrames - 1;
	}

	Future<bool> harvest({WebSocket userSocket, String email}) async {
		bool success = await super.harvest(userSocket:userSocket,email:email);

		if(success) {
			StatManager.add(email, Stat.bubbles_harvested).then((int harvested) {
				if (harvested >= 5003) {
					Achievement.find("firstbest_bubble_farmer").awardTo(email);
				} else if (harvested >= 1009) {
					Achievement.find("secondbest_bubble_farmer").awardTo(email);
				} else if (harvested >= 503) {
					Achievement.find("better_bubble_farmer").awardTo(email);
				} else if (harvested >= 101) {
					Achievement.find("good_bubble_farmer").awardTo(email);
				}
			});
		}

		return success;
	}

	Future<bool> pet({WebSocket userSocket, String email}) async {
		bool success = await super.pet(userSocket: userSocket, email: email);

		if (success) {
			StatManager.add(email, Stat.bubble_trees_petted).then((int stat) {
				if (stat >= 127) {
					Achievement.find("chief_bubble_tree_cuddler").awardTo(email);
				} else if (stat >= 41) {
					Achievement.find("midlevel_bubble_tree_cuddler").awardTo(email);
				} else if (stat >= 11) {
					Achievement.find("rookie_bubble_tree_cuddler").awardTo(email);
				}
			});
		}

		return success;
	}

	Future<bool> water({WebSocket userSocket, String email}) async {
		bool success = await super.water(userSocket: userSocket, email: email);

		if (success) {
			StatManager.add(email, Stat.bubble_trees_watered).then((int stat) {
				if (stat >= 41) {
					Achievement.find("senor_sprinkles").awardTo(email);
				}
			});
		}

		return success;
	}
}
