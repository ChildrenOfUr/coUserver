part of coUserver;

class Spriggan extends Shrine
{
	Spriggan(String id, int x, int y) : super(id,x,y)
	{
		states =
			{
				"close" : new Spritesheet("close","http://c2.glitch.bz/items/2012-12-06/npc_shrine_spriggan__x1_close_png_1354831248.png",906,752,151,188,23,false),
				"open" : new Spritesheet("open","http://c2.glitch.bz/items/2012-12-06/npc_shrine_spriggan__x1_open_png_1354831246.png",906,752,151,188,22,false),
				"still" : new Spritesheet("still","http://c2.glitch.bz/items/2012-12-06/npc_shrine_spriggan__x1_open_png_1354831246.png",906,752,151,188,1,false)
			};
	 	currentState = states['still'];
	 	type = 'Spriggan';

	 	description = 'This is a shrine to Spriggan. Sure, Spriggan is the most taciturn and humorless of all the giants. You would be, too, if you had sole dominion over the trees. Trees are serious business, you know.';
	}
}