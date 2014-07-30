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
     	maxState = 0;
	}
	
	void mine({WebSocket userSocket})
	{
		super.mine(userSocket:userSocket);
		        		
		//give the player the 'fruits' of their labor
		Map map = {};
		map['giveItem'] = "true";
		map['item'] = new ChunkofBeryl().getMap();
		map['num'] = 1;
		map['fromObject'] = id;
		userSocket.add(JSON.encode(map));
		
		//1 in 10 chance to get a ruby as well
		if(new Random().nextInt(10) == 5)
		{
			map = {};
			map['giveItem'] = "true";
			map['item'] = new ModestlySizedRuby().getMap();
			map['num'] = 1;
			map['fromObject'] = id;
			userSocket.add(JSON.encode(map));
		}
	}
}