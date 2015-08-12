part of coUserver;

class DulliteRock extends Rock {
	DulliteRock(String id, int x, int y) : super(id, x, y) {
		type = "Dullite Rock";

		states =
		{
			"5-4-3-2-1" : new Spritesheet("5-4-3-2-1", "http://childrenofur.com/assets/entityImages/rock_dullite_x1_5_x1_4_x1_3_x1_2_x1_1__1_png_1354831459.png", 655, 114, 131, 114, 5, false)
		};
		currentState = states['5-4-3-2-1'];
		state = new Random().nextInt(currentState.numFrames);
		responses['mine_$type'] = [
			"Ooof. I feel lighter already.",
			"Mmm, thanks, I've been itching there all day.",
			"Ow. Ow-hangover. Ow-my-head. Ow.",
			"Not bad. Work on your backswing.",
			"You're really picking this up.",
			"Nothing wrong with a sedimentary lifestyle, chum.",
			"I should have been a wrestler. I'm rock-hard! Hee!",
			"Ah. You've taken a lode of my mind.",
			"You sure have an apatite for this.",
			"Woah. I'm tuff. But you're tuffer."
		];
	}

	Future<bool> mine({WebSocket userSocket, String email}) async {
		bool success = await super.mine(userSocket:userSocket, email:email);

		if(success) {
			//give the player the 'fruits' of their labor
			addItemToUser(userSocket, email, items['chunk_dullite'].getMap(), 1, id);
		}

		return success;
	}
}