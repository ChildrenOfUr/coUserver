part of coUserver;

class Humbaba extends Shrine
{
	Humbaba(String id, int x, int y) : super(id,x,y)
	{
		states =
			{
				"close" : new Spritesheet("close","http://c2.glitch.bz/items/2012-12-06/npc_shrine_humbaba__x1_close_png_1354831228.png",906,752,151,188,23,false),
				"open" : new Spritesheet("open","http://c2.glitch.bz/items/2012-12-06/npc_shrine_humbaba__x1_open_png_1354831227.png",906,752,151,188,22,false),
				"still" : new Spritesheet("still","http://c2.glitch.bz/items/2012-12-06/npc_shrine_humbaba__x1_open_png_1354831227.png",906,752,151,188,1,false)
			};
	 	currentState = states['still'];

	 	description = 'This is a shrine to Humbaba, the giant who rules both two-legged and four-legged beasts. Actually, she rules all the beasts with even-numbered quantities of legs. The odd-numbered ones are on their own.';
	}
}