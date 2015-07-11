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
	 	type = 'Humbaba';

	 	description = 'This is a shrine to Humbaba, the giant who rules both two-legged and four-legged beasts. Actually, she rules all the beasts with even-numbered quantities of legs. The odd-numbered ones are on their own.';
	}
}

class HumbabaFirebog extends Shrine
{
	HumbabaFirebog(String id, int x, int y) : super(id,x,y)
	{
		states =
		{
			"close" : new Spritesheet("close","http://c2.glitch.bz/items/2012-12-06/npc_shrine_firebog_humbaba__x1_close_png_1354832816.png",984,848,164,212,23,false),
			"open" : new Spritesheet("open","http://c2.glitch.bz/items/2012-12-06/npc_shrine_firebog_humbaba__x1_open_png_1354832813.png",984,848,164,212,22,false),
			"still" : new Spritesheet("still","http://c2.glitch.bz/items/2012-12-06/npc_shrine_firebog_humbaba__x1_open_png_1354832813.png",984,848,164,212,1,false)
		};
		currentState = states['still'];
		type = 'Humbaba';

		description = 'This is a shrine to Humbaba, the giant who rules both two-legged and four-legged beasts. Actually, she rules all the beasts with even-numbered quantities of legs. The odd-numbered ones are on their own.';
	}
}

class HumbabaIx extends Shrine
{
	HumbabaIx(String id, int x, int y) : super(id,x,y)
	{
		states =
		{
			"close" : new Spritesheet("close","http://c2.glitch.bz/items/2012-12-06/npc_shrine_ix_humbaba__x1_close_png_1354831284.png",840,864,168,216,20,false),
			"open" : new Spritesheet("open","http://c2.glitch.bz/items/2012-12-06/npc_shrine_ix_humbaba__x1_open_png_1354831282.png",840,1080,168,216,24,false),
			"still" : new Spritesheet("still","http://c2.glitch.bz/items/2012-12-06/npc_shrine_ix_humbaba__x1_open_png_1354831282.png",840,1080,168,216,1,false)
		};
		currentState = states['still'];
		type = 'Humbaba';

		description = 'This is a shrine to Humbaba, the giant who rules both two-legged and four-legged beasts. Actually, she rules all the beasts with even-numbered quantities of legs. The odd-numbered ones are on their own.';
	}
}

class HumbabaUralia extends Shrine
{
	HumbabaUralia(String id, int x, int y) : super(id,x,y)
	{
		states =
		{
			"close" : new Spritesheet("close","http://c2.glitch.bz/items/2012-12-06/npc_shrine_uralia_humbaba__x1_close_png_1354831890.png",756,752,126,188,23,false),
			"open" : new Spritesheet("open","http://c2.glitch.bz/items/2012-12-06/npc_shrine_uralia_humbaba__x1_open_png_1354831888.png",756,752,126,188,22,false),
			"still" : new Spritesheet("still","http://c2.glitch.bz/items/2012-12-06/npc_shrine_uralia_humbaba__x1_open_png_1354831888.png",756,752,126,188,1,false)
		};
		currentState = states['still'];
		type = 'Humbaba';

		description = 'This is a shrine to Humbaba, the giant who rules both two-legged and four-legged beasts. Actually, she rules all the beasts with even-numbered quantities of legs. The odd-numbered ones are on their own.';
	}
}