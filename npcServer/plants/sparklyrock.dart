part of coUserver;

class SparklyRock extends Rock
{
	SparklyRock(String id, int x, int y) : super(id,x,y)
	{
		type = "Sparkly Rock";

		states =
			{
				"5-4-3-2-1" : new Spritesheet("5-4-3-2-1","http://c2.glitch.bz/items/2012-12-06/rock_sparkly_x1_5_x1_4_x1_3_x1_2_x1_1__1_png_1354831467.png",655,127,131,127,5,false)
			};
		currentState = states['5-4-3-2-1'];
     	state = new Random().nextInt(currentState.numFrames);
	}

	void mine({WebSocket userSocket, String email})
	{
		super.mine(userSocket:userSocket);

		//give the player the 'fruits' of their labor
		addItemToUser(userSocket,email,new ChunkofSparkly().getMap(),1,id);

		//1 in 10 chance to get a ruby as well
		if(new Random().nextInt(10) == 5)
			addItemToUser(userSocket,email,new ModestlySizedRuby().getMap(),1,id);
	}
}