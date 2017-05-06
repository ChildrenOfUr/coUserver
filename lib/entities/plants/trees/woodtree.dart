part of entity;

class WoodTree extends Tree {
	WoodTree(String id, num x, num y, num z, num rotation, bool h_flip, String streetName) : super(id, x, y, z, rotation, h_flip, streetName) {
		type = "Wood Tree";
		rewardItemType = "plank";

		responses =
		{
			"harvest": [
				"Never mind the quality, feel the width.",
				"HOO-HA!!!",
				"I've got a huge … wood. I have wood. Here, take some.",
				"Wood you like some planks?",
				"Mighty chopper you have there.",
				"Knot now. Axe me later."
			],
			"pet": [
				"Plank you very much!",
				"Mmm, you feel wood.",
				"Don't rub too rough, I'll splinter all over you.",
				"Go with the grain.",
				"Yes. Wood-rubbing. I approve.",
				"Wanna go out? I’m feeling board."
			],
			"water": [
				"Yep. Nothing like wet kindling.",
				"Oh thanks. Now I've got rising damp.",
				"You've totally moistened my roots.",
				"Even a dribble from the right hose provides succor to a thirsty trunk.",
				"Watch it, you've gushed all over my barky bits.",
			]
		};

		ItemRequirements itemReq = new ItemRequirements()
			..any = ['hatchet', 'class_axe']
			..error = 'You need something sharp to cut the wood with';
		actions.singleWhere((Action a) => a.actionName == 'harvest')
			..actionName = 'chop'
			..actionWord = 'chopping'
			..itemRequirements = itemReq;

		states =
		{
			"maturity_1" : new Spritesheet("maturity_1", "https://childrenofur.com/assets/entityImages/wood_tree_maturity_6_variant_2_x6_1_png_1354833445.png", 528, 138, 88, 138, 6, false),
			"maturity_2" : new Spritesheet("maturity_1", "https://childrenofur.com/assets/entityImages/wood_tree_maturity_6_variant_2_x6_1_png_1354833445.png", 564, 135, 94, 135, 6, false),
			"maturity_3" : new Spritesheet("maturity_1", "https://childrenofur.com/assets/entityImages/wood_tree_maturity_6_variant_2_x6_1_png_1354833445.png", 522, 121, 87, 121, 6, false),
			"maturity_4" : new Spritesheet("maturity_1", "https://childrenofur.com/assets/entityImages/wood_tree_maturity_6_variant_2_x6_1_png_1354833445.png", 558, 138, 93, 138, 6, false)
		};
		maturity = new Random().nextInt(states.length) + 1;
		setState('maturity_$maturity');
		state = new Random().nextInt(currentState.numFrames);
		maxState = currentState.numFrames - 1;
	}

	Future<bool> chop({WebSocket userSocket, String email}) async {
		//make sure the player has a hatchet that chop some wood
		Action digAction = actions.singleWhere((Action a) => a.actionName == 'chop');
		List<String> types = digAction.itemRequirements.any;
		bool success = await InventoryV2.decreaseDurability(email, types);
		if(!success) {
			return false;
		}

		success = await super.harvest(userSocket:userSocket,email:email);

		if(success) {
			StatManager.add(email, Stat.planks_harvested).then((int harvested) {
				if (harvested >= 151) {
					Achievement.find("loggerator").awardTo(email);
				} else if (harvested >= 79) {
					Achievement.find("timber_jack").awardTo(email);
				} else if (harvested >= 17) {
					Achievement.find("wood_wacker").awardTo(email);
				}
			});
		}

		return success;
	}

	Future<bool> pet({WebSocket userSocket, String email}) async {
		bool success = await super.pet(userSocket: userSocket, email: email);

		if (success) {
			StatManager.add(email, Stat.wood_trees_petted);
		}

		return success;
	}

	Future<bool> water({WebSocket userSocket, String email}) async {
		bool success = await super.water(userSocket: userSocket, email: email);

		if (success) {
			StatManager.add(email, Stat.wood_trees_watered);
		}

		return success;
	}
}
