part of coUserver;

class Cosma extends Shrine
{
	Cosma(String id, int x, int y, String streetName) : super(id,x,y, streetName)
	{
		states =
			{
				"close" : new Spritesheet("close","http://childrenofur.com/assets/entityImages/npc_shrine_cosma__x1_close_png_1354831213.png",906,752,151,188,23,false),
				"open" : new Spritesheet("open","http://childrenofur.com/assets/entityImages/npc_shrine_cosma__x1_open_png_1354831212.png",906,752,151,188,22,false),
				"still" : new Spritesheet("still","http://childrenofur.com/assets/entityImages/npc_shrine_cosma__x1_open_png_1354831212.png",906,752,151,188,1,false)
			};
	 	currentState = states['still'];
	 	type = 'Cosma';

	 	description = 'This is a shrine to Cosma. As the giant who governs the sky, Cosma is also the giant of levity and meditation. She is, also, the only giant capable of herding butterflies.';
	}
}

class CosmaFirebog extends Shrine
{
	CosmaFirebog(String id, int x, int y, String streetName) : super(id,x,y, streetName)
	{
		states =
		{
			"close" : new Spritesheet("close","http://childrenofur.com/assets/entityImages/npc_shrine_firebog_cosma__x1_close_png_1354832774.png",984,848,164,212,23,false),
			"open" : new Spritesheet("open","http://childrenofur.com/assets/entityImages/npc_shrine_firebog_cosma__x1_open_png_1354832771.png",984,848,164,212,22,false),
			"still" : new Spritesheet("still","http://childrenofur.com/assets/entityImages/npc_shrine_firebog_cosma__x1_open_png_1354832771.png",984,848,164,212,1,false)
		};
		currentState = states['still'];
		type = 'Cosma';

		description = 'This is a shrine to Cosma. As the giant who governs the sky, Cosma is also the giant of levity and meditation. She is, also, the only giant capable of herding butterflies.';
	}
}

class CosmaIx extends Shrine
{
	CosmaIx(String id, int x, int y, String streetName) : super(id,x,y, streetName)
	{
		states =
		{
			"close" : new Spritesheet("close","http://childrenofur.com/assets/entityImages/npc_shrine_ix_cosma__x1_close_png_1354831269.png",840,864,168,216,20,false),
			"open" : new Spritesheet("open","http://childrenofur.com/assets/entityImages/npc_shrine_ix_cosma__x1_open_png_1354831267.png",840,1080,168,216,24,false),
			"still" : new Spritesheet("still","http://childrenofur.com/assets/entityImages/npc_shrine_ix_cosma__x1_open_png_1354831267.png",840,1080,168,216,1,false)
		};
		currentState = states['still'];
		type = 'Cosma';

		description = 'This is a shrine to Cosma. As the giant who governs the sky, Cosma is also the giant of levity and meditation. She is, also, the only giant capable of herding butterflies.';
	}
}

class CosmaUralia extends Shrine
{
	CosmaUralia(String id, int x, int y, String streetName) : super(id,x,y, streetName)
	{
		states =
		{
			"close" : new Spritesheet("close","http://childrenofur.com/assets/entityImages/npc_shrine_uralia_cosma__x1_close_png_1354831869.png",756,752,126,188,23,false),
			"open" : new Spritesheet("open","http://childrenofur.com/assets/entityImages/npc_shrine_uralia_cosma__x1_open_png_1354831867.png",756,752,126,188,22,false),
			"still" : new Spritesheet("still","http://childrenofur.com/assets/entityImages/npc_shrine_uralia_cosma__x1_open_png_1354831867.png",756,752,126,188,1,false)
		};
		currentState = states['still'];
		type = 'Cosma';

		description = 'This is a shrine to Cosma. As the giant who governs the sky, Cosma is also the giant of levity and meditation. She is, also, the only giant capable of herding butterflies.';
	}
}