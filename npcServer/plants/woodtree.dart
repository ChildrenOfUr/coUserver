part of coUserver;

class WoodTree extends Tree
{
	WoodTree(String id, int x, int y) : super(id,x,y)
	{
		type = "Wood Tree";

		states =
			{
				"maturity_1" : new Spritesheet("maturity_1","http://c2.glitch.bz/items/2012-12-06/wood_tree_maturity_6_variant_2_x6_1_png_1354833445.png",528,138,88,138,6,false),
				"maturity_2" : new Spritesheet("maturity_1","http://c2.glitch.bz/items/2012-12-06/wood_tree_maturity_6_variant_2_x6_1_png_1354833445.png",564,135,94,135,6,false),
				"maturity_3" : new Spritesheet("maturity_1","http://c2.glitch.bz/items/2012-12-06/wood_tree_maturity_6_variant_2_x6_1_png_1354833445.png",522,121,87,121,6,false),
				"maturity_4" : new Spritesheet("maturity_1","http://c2.glitch.bz/items/2012-12-06/wood_tree_maturity_6_variant_2_x6_1_png_1354833445.png",558,138,93,138,6,false)
			};
		maturity = new Random().nextInt(states.length)+1;
     	currentState = states['maturity_$maturity'];
     	state = new Random().nextInt(currentState.numFrames);
     	maxState = currentState.numFrames-1;
	}

	void harvest({WebSocket userSocket, String username})
	{
		super.harvest(userSocket:userSocket);

		//give the player the 'fruits' of their labor
		addItemToUser(userSocket,username,new Plank().getMap(),1,id);
	}
}