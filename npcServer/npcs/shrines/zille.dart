part of coUserver;

class Zille extends Shrine
{
	Zille(String id, int x, int y) : super(id,x,y)
	{
		states =
			{
				"close" : new Spritesheet("close","http://c2.glitch.bz/items/2012-12-06/npc_shrine_zille__x1_close_png_1354831253.png",906,752,151,188,23,false),
				"open" : new Spritesheet("open","http://c2.glitch.bz/items/2012-12-06/npc_shrine_zille__x1_open_png_1354831251.png",906,752,151,188,22,false),
				"still" : new Spritesheet("still","http://c2.glitch.bz/items/2012-12-06/npc_shrine_zille__x1_open_png_1354831251.png",906,752,151,188,1,false)
			};
	 	currentState = states['still'];
	 	type = 'zille';

	 	description = 'This is a shrine to Zille, the giant whose domain is the mountains. Hills, too. Also hillocks, pingos, drumlins and buttes. It\'s safe to consider that any bump in the ground is Zille\'s turf. She takes no responsibility, however, for volcanoes.';
	}
}