part of coUserver;

class Alph extends Shrine
{
	Alph(String id, int x, int y) : super(id,x,y)
	{
		states =
			{
				"close" : new Spritesheet("close","http://c2.glitch.bz/items/2012-12-06/npc_shrine_alph__x1_close_png_1354831208.png",906,752,151,188,23,false),
				"open" : new Spritesheet("open","http://c2.glitch.bz/items/2012-12-06/npc_shrine_alph__x1_open_png_1354831207.png",906,752,151,188,22,false),
				"still" : new Spritesheet("still","http://c2.glitch.bz/items/2012-12-06/npc_shrine_alph__x1_open_png_1354831207.png",906,752,151,188,1,false)
			};
	 	currentState = states['still'];
	 	type = 'Alph';

	 	description = 'This is a shrine to Alph, the giant of creation. If you\'ve ever wondered "Why do Piggies make meat?" or "Which came first: the chicken or the egg plant?" chances are Alph has the answer.';
	}
}