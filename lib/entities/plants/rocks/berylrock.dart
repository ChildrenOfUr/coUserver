part of entity;

class BerylRock extends Rock {
	BerylRock(String id, num x, num y, num z, String streetName) : super(id, x, y, z, streetName) {
		type = "Beryl Rock";

		states =
		{
			"5-4-3-2-1" : new Spritesheet("5-4-3-2-1", "http://childrenofur.com/assets/entityImages/rock_beryl_x1_5_x1_4_x1_3_x1_2_x1_1__1_png_1354831451.png", 670, 120, 134, 120, 5, false)
		};
		setState('5-4-3-2-1');
		state = new Random().nextInt(currentState.numFrames);
		responses['mine_$type'] = [
			"Hey! To the left a little next time.",
			"Ughh, you're so frikkin' picky.",
			"I wasn't cut out for this.",
			"Not in the face! Oh. Wait. No face.",
			"If you need any tips on technique, just axe.",
			"Pick on someone else, will you?",
			"You're on rocky ground, Glitch.",
			"I feel like you're taking me for granite.",
			"Well, at least that's a weight off me mined.",
			"You sure have one big axe to grind."
		];
	}

	Future<bool> mine({WebSocket userSocket, String email}) async {
		bool success = await super.mine(userSocket:userSocket, email:email);

		if(success) {
			int miningLevel = await SkillManager.getLevel(Rock.SKILL, email);
			int qty = 1;
			if (miningLevel == 4) {
				qty = (rand.nextInt(3) == 3 ? 3 : 2);
			} else if (miningLevel >= 1) {
				qty = 2;
			}
			//give the player the 'fruits' of their labor
			await InventoryV2.addItemToUser(email, items['chunk_beryl'].getMap(), qty, id);
		}

		return success;
	}
}