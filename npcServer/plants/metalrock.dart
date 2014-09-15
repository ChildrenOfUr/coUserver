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
	}

	void mine({WebSocket userSocket, String username})
	{
		super.mine(userSocket:userSocket);

		//give the player the 'fruits' of their labor
		addItemToUser(userSocket,username,new ChunkofMetalRock().getMap(),1,id);
	}
}