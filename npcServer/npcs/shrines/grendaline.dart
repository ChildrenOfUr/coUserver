part of coUserver;

class Grendaline extends Shrine
{
	Grendaline(String id, int x, int y) : super(id,x,y)
	{
		states =
			{
				"close" : new Spritesheet("close","http://c2.glitch.bz/items/2012-12-06/npc_shrine_grendaline__x1_close_png_1354831223.png",906,752,151,188,23,false),
				"open" : new Spritesheet("open","http://c2.glitch.bz/items/2012-12-06/npc_shrine_grendaline__x1_open_png_1354831222.png",906,752,151,188,22,false),
				"still" : new Spritesheet("still","http://c2.glitch.bz/items/2012-12-06/npc_shrine_grendaline__x1_open_png_1354831222.png",906,752,151,188,1,false)
			};
	 	currentState = states['still'];
	 	type = 'Grendaline';

	 	description = 'This is a shrine to Grendaline. Quietly loyal and fierce, Grendaline is the giant who governs all things watery, from clouds and fogs to mountain streams and oceans. As a sideline, she is also influential in the sphere of big, fluffy towels.';
	}
}