part of coUserver;

class Lem extends Shrine
{
	Lem(String id, int x, int y) : super(id,x,y)
	{
		states =
			{
				"close" : new Spritesheet("close","http://c2.glitch.bz/items/2012-12-06/npc_shrine_lem__x1_close_png_1354831233.png",906,752,151,188,23,false),
				"open" : new Spritesheet("open","http://c2.glitch.bz/items/2012-12-06/npc_shrine_lem__x1_open_png_1354831232.png",906,752,151,188,22,false),
				"still" : new Spritesheet("still","http://c2.glitch.bz/items/2012-12-06/npc_shrine_lem__x1_open_png_1354831232.png",906,752,151,188,1,false)
			};
	 	currentState = states['still'];
	 	type = 'lem';

	 	description = 'This is a shrine to Lem, the giant of travel and navigation. If you\'ve ever found yourself somewhere you didn\'t plan to be, chances are it was a Lemish practical joke, for which he is utterly unrepentant.';
	}
}