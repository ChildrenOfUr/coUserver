part of coUserver;

class PaperTree extends Tree
{
	PaperTree(String id, int x, int y) : super(id,x,y)
	{
		type = "Paper Tree";
		
		states = 
			{
				"maturity_1" : new Spritesheet("maturity_1","http://c2.glitch.bz/items/2012-12-06/paper_tree_needs_pet_false_needs_water_false_paper_count_21_x22_1_png_1354832565.png",928,1296,232,216,22,false)
			};
		maturity = new Random().nextInt(states.length)+1;
     	currentState = states['maturity_$maturity'];
     	state = new Random().nextInt(currentState.numFrames);
     	maxState = currentState.numFrames-1;
	}
	
	void harvest({WebSocket userSocket})
	{
		super.harvest(userSocket:userSocket);
		
		//give the player the 'fruits' of their labor
		Map map = {};
		map['giveItem'] = "true";
		map['item'] = new Paper().getMap();
		map['num'] = 1;
		map['fromObject'] = id;
		userSocket.add(JSON.encode(map));
	}
}