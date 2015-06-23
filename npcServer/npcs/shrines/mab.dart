part of coUserver;

class Mab extends Shrine
{
	Mab(String id, int x, int y) : super(id,x,y)
	{
		states =
			{
				"close" : new Spritesheet("close","http://c2.glitch.bz/items/2012-12-06/npc_shrine_mab__x1_close_png_1354831238.png",906,752,151,188,23,false),
				"open" : new Spritesheet("open","http://c2.glitch.bz/items/2012-12-06/npc_shrine_mab__x1_open_png_1354831237.png",906,752,151,188,22,false),
				"still" : new Spritesheet("still","http://c2.glitch.bz/items/2012-12-06/npc_shrine_mab__x1_open_png_1354831237.png",906,752,151,188,1,false)
			};
	 	currentState = states['still'];
	 	type = 'Mab';

	 	description = 'This is a shrine to Mab, the giant who holds sway over the harvest. She honors industriousness, and rightfully so. Sometimes, however, industriousness can turn to greed. This is a problem.';
	}
}