part of entity;

class WoodTree extends Tree {
	WoodTree(String id, int x, int y, String streetName) : super(id, x, y, streetName) {
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

		actions[0]
			..["action"] = "chop"
			..["actionWord"] = "chopping"
			..['requires'] = [
				{
				"num":1,
				"of":["hatchet", "class_axe"],
				"error": "You need something sharp to cut the wood with."
			}
		];

		states =
		{
			"maturity_1" : new Spritesheet("maturity_1", "http://childrenofur.com/assets/entityImages/wood_tree_maturity_6_variant_2_x6_1_png_1354833445.png", 528, 138, 88, 138, 6, false),
			"maturity_2" : new Spritesheet("maturity_1", "http://childrenofur.com/assets/entityImages/wood_tree_maturity_6_variant_2_x6_1_png_1354833445.png", 564, 135, 94, 135, 6, false),
			"maturity_3" : new Spritesheet("maturity_1", "http://childrenofur.com/assets/entityImages/wood_tree_maturity_6_variant_2_x6_1_png_1354833445.png", 522, 121, 87, 121, 6, false),
			"maturity_4" : new Spritesheet("maturity_1", "http://childrenofur.com/assets/entityImages/wood_tree_maturity_6_variant_2_x6_1_png_1354833445.png", 558, 138, 93, 138, 6, false)
		};
		maturity = new Random().nextInt(states.length) + 1;
		setState('maturity_$maturity');
		state = new Random().nextInt(currentState.numFrames);
		maxState = currentState.numFrames - 1;
	}

	Future<bool> chop({WebSocket userSocket, String email}) async {
		//make sure the player has a hatchet that chop some wood
		Map mineAction = actions.firstWhere((Map action) => action['action'] == 'chop');
		List<String> types = mineAction['requires'][0]['of'];
		bool success = await InventoryV2.decreaseDurability(email, types);
		if(!success) {
			return false;
		}

		success = await super.harvest(userSocket:userSocket,email:email);

		if(success) {
			StatCollection.find(email).then((StatCollection stats) {
				stats.planks_harvested++;
				if (stats.planks_harvested >= 17) {
					Achievement.find("wood_wacker").awardTo(email);
				} else if (stats.planks_harvested >= 79) {
					Achievement.find("timber_jack").awardTo(email);
				} else if (stats.planks_harvested >= 151) {
					Achievement.find("loggerator").awardTo(email);
				}
			});
		}

		return success;
	}
}
