part of coUserver;

class Pot extends Shrine
{
	Pot(String id, int x, int y) : super(id,x,y)
	{
		states =
			{
				"close" : new Spritesheet("close","http://c2.glitch.bz/items/2012-12-06/npc_shrine_pot__x1_close_png_1354831243.png",906,752,151,188,23,false),
				"open" : new Spritesheet("open","http://c2.glitch.bz/items/2012-12-06/npc_shrine_pot__x1_open_png_1354831241.png",906,752,151,188,22,false),
				"still" : new Spritesheet("still","http://c2.glitch.bz/items/2012-12-06/npc_shrine_pot__x1_open_png_1354831241.png",906,752,151,188,1,false)
			};
	 	currentState = states['still'];

	 	description = 'This is a shrine to Pot. Big-hearted and generous, Pot is the giant who dispenses prosperity and good fortune. Which is all well and good if you can keep sloth and indolence at bay. Tricky.';
	}
}