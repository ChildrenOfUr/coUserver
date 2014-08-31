part of coUserver;

class Friendly extends Shrine
{
	Friendly(String id, int x, int y) : super(id,x,y)
	{
		states =
			{
				"close" : new Spritesheet("close","http://c2.glitch.bz/items/2012-12-06/npc_shrine_friendly__x1_close_png_1354831218.png",906,752,151,188,23,false),
				"open" : new Spritesheet("open","http://c2.glitch.bz/items/2012-12-06/npc_shrine_friendly__x1_open_png_1354831217.png",906,752,151,188,22,false),
				"still" : new Spritesheet("still","http://c2.glitch.bz/items/2012-12-06/npc_shrine_friendly__x1_open_png_1354831217.png",906,752,151,188,1,false)
			};
	 	currentState = states['still'];
	 	type = 'friendly';

	 	description = 'This is a shrine to Friendly, the giant who oversees all things celestial, nocturnal, lunar, stygian and murky. Despite this, he is, as his name implies, considered by many to be the nicest of the giants and the one most likely to loan you twenty currants till payday.';
	}
}