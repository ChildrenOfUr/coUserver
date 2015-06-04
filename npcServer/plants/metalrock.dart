part of coUserver;

class MetalRock extends Rock
{
	MetalRock(String id, int x, int y) : super(id,x,y)
	{
		type = "Metal Rock";

		actions[0]['requires'] = [
					               {
								     "num":1,
								     "of":["Fancy Pick"]
								   }
								];

		states =
			{
				"5-4-3-2-1" : new Spritesheet("5-4-3-2-1","http://c2.glitch.bz/items/2012-12-06/rock_metal_x1_5_x1_4_x1_3_x1_2_x1_1__1_png_1354832615.png",685,100,137,100,5,false)
			};
		currentState = states['5-4-3-2-1'];
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

	void mine({WebSocket userSocket, String email})
	{
		super.mine(userSocket:userSocket);

		//give the player the 'fruits' of their labor
		addItemToUser(userSocket,email,items['Chunk of Metal Rock'].getMap(),1,id);
	}
}