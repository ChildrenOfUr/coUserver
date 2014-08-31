part of coUserver;

class Cosma extends Shrine
{
	Cosma(String id, int x, int y) : super(id,x,y)
	{
		states =
			{
				"close" : new Spritesheet("close","http://c2.glitch.bz/items/2012-12-06/npc_shrine_cosma__x1_close_png_1354831213.png",906,752,151,188,23,false),
				"open" : new Spritesheet("open","http://c2.glitch.bz/items/2012-12-06/npc_shrine_cosma__x1_open_png_1354831212.png",906,752,151,188,22,false),
				"still" : new Spritesheet("still","http://c2.glitch.bz/items/2012-12-06/npc_shrine_cosma__x1_open_png_1354831212.png",906,752,151,188,1,false)
			};
	 	currentState = states['still'];
	 	type = 'cosma';

	 	description = 'This is a shrine to Cosma. As the giant who governs the sky, Cosma is also the giant of levity and meditation. She is, also, the only giant capable of herding butterflies.';
	}
}