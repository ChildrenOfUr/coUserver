part of entity;

class MetalRock extends Rock {
	MetalRock(String id, int x, int y, String streetName) : super(id, x, y, streetName) {
		type = "Metal Rock";

		actions[0]['requires'] = [
			{
				"num":1,
				"of":["fancy_pick"],
				"error": "You need a special pick to mine harder rocks."
			},
			{
				"num":10,
				"of":['energy'],
				"error": "You need at least 10 energy to mine."
			}
		];

		states =
		{
			"5-4-3-2-1" : new Spritesheet("5-4-3-2-1", "http://childrenofur.com/assets/entityImages/rock_metal_x1_5_x1_4_x1_3_x1_2_x1_1__1_png_1354832615.png", 685, 100, 137, 100, 5, false)
		};
		setState('5-4-3-2-1');
		state = new Random().nextInt(currentState.numFrames);
		responses['mine_$type'] = [
			"Slave to the GRIND, kid! ROCK ON!",
			"I’d feel worse if I wasn’t under such heavy sedation.",
			"Sweet! Air pickaxe solo! C'MON!",
			"Yeah. Appetite for destruction, man. I feel ya.",
			"LET THERE BE ROCK!",
			"Those who seek true metal, we salute you!",
			"YEAH, man! You SHOOK me!",
			"All hail the mighty metal power of the axe!",
			"Metal, man! METAL!",
			"Wield that axe like a metal-lover, man!"
		];
	}

	Future<bool> mine({WebSocket userSocket, String email}) async {
		bool success = await super.mine(userSocket:userSocket, email:email);

		if(success) {
			int miningLevel = await SkillManager.getLevel(Rock.SKILL, email);
			int qty = 1;
			if (miningLevel == 4) {
				qty = (rand.nextInt(3) == 3 ? 4 : 3);
			} else if (miningLevel >= 1) {
				qty = 2;
			}
			//give the player the 'fruits' of their labor
			await InventoryV2.addItemToUser(email, items['chunk_metal'].getMap(), qty, id);
		}

		return success;
	}
}