part of coUserver;

class DulliteRock extends Rock
{
	DulliteRock(String id, int x, int y) : super(id,x,y)
	{
		type = "Dullite Rock";

		states =
			{
				"5-4-3-2-1" : new Spritesheet("5-4-3-2-1","http://c2.glitch.bz/items/2012-12-06/rock_dullite_x1_5_x1_4_x1_3_x1_2_x1_1__1_png_1354831459.png",655,114,131,114,5,false)
			};
		currentState = states['5-4-3-2-1'];
     	state = new Random().nextInt(currentState.numFrames);
     	maxState = 0;
	}

	void mine({WebSocket userSocket, String username})
	{
		super.mine(userSocket:userSocket);

		//give the player the 'fruits' of their labor
		addItemToUser(userSocket,username,new ChunkofDullite().getMap(),1,id);
	}
}