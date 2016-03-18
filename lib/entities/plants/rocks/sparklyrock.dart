part of entity;

class SparklyRock extends Rock {
	SparklyRock(String id, int x, int y, String streetName) : super(id, x, y, streetName) {
		type = "Sparkly Rock";

		states =
		{
			"5-4-3-2-1" : new Spritesheet("5-4-3-2-1", "http://childrenofur.com/assets/entityImages/rock_sparkly_x1_5_x1_4_x1_3_x1_2_x1_1__1_png_1354831467.png", 655, 127, 131, 127, 5, false)
		};
		currentState = states['5-4-3-2-1'];
		state = new Random().nextInt(currentState.numFrames);

		responses['mine_$type'] = [
			"You rock my world!",
			"I've taken a shine to you.",
			"Here! What's mined is yours!",
			"Pick me! Pick me!",
			"I sparkle! You sparkle! Sparkles!",
			"Oooh, you're cute. You into carbon-dating?",
			"Oh yeah! Who's your magma?!?",
			"Yay! You picked me!",
			"Hey, cutestuff! You make me sliver.",
			"You crack me up, Glitchy!",
			"Yay! Everything should sparkle! Except maybe vampires.",
			"Together, we'll make the world sparkly, Glitchy"
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
			await InventoryV2.addItemToUser(email, items['chunk_sparkly'].getMap(), qty, id);
		}

		return success;
	}
}