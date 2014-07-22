part of coUserver;

class MetalRock extends Rock
{
	MetalRock(String id, int x, int y) : super(id,x,y)
	{
		type = "Metal Rock";
        		
		states = 
			{
				"5-4-3-2-1" : new Spritesheet("5-4-3-2-1","http://c2.glitch.bz/items/2012-12-06/rock_metal_x1_5_x1_4_x1_3_x1_2_x1_1__1_png_1354832615.png",685,100,137,100,5,false)
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
		map['url'] = 'http://c2.glitch.bz/items/2012-12-06/metal_rock__x1_1_x1_2_x1_3_x1_4_png_1354832618.png';
		map['num'] = 1;
		map['name'] = 'chunk_of_dullite';
		map['fromObject'] = id;
		userSocket.add(JSON.encode(map));
	}
}