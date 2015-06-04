part of coUserver;

class BerylRock extends Rock
{
	BerylRock(String id, int x, int y) : super(id,x,y)
	{
		type = "Beryl Rock";

		states =
			{
				"5-4-3-2-1" : new Spritesheet("5-4-3-2-1","http://c2.glitch.bz/items/2012-12-06/rock_beryl_x1_5_x1_4_x1_3_x1_2_x1_1__1_png_1354831451.png",670,120,134,120,5,false)
			};
		currentState = states['5-4-3-2-1'];
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

	void mine({WebSocket userSocket, String email})
	{
		super.mine(userSocket:userSocket);

		//give the player the 'fruits' of their labor
		addItemToUser(userSocket,email,items['Chunk of Beryl'].getMap(),1,id);

		//1 in 10 chance to get a ruby as well
		if(new Random().nextInt(10) == 5)
			addItemToUser(userSocket,email,items['Modestly Sized Ruby'].getMap(),1,id);
	}
}