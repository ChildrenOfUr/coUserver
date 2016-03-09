part of coUserver;

class Tii extends Shrine
{
	Tii(String id, int x, int y, String streetName) : super(id,x,y, streetName)
	{
		states =
			{
				"close" : new Spritesheet("close","http://childrenofur.com/assets/entityImages/npc_shrine_ti__x1_close_png_1354831258.png",906,752,151,188,23,false),
				"open" : new Spritesheet("open","http://childrenofur.com/assets/entityImages/npc_shrine_ti__x1_open_png_1354831256.png",906,752,151,188,22,false),
				"still" : new Spritesheet("still","http://childrenofur.com/assets/entityImages/npc_shrine_ti__x1_open_png_1354831256.png",906,752,151,188,1,false)
			};
	 	currentState = states['still'];
	 	type = 'Tii';

	 	description = 'This is a shrine to Tii, the overseer of elements, and the giant who manipulates all matters alchemical. Unlike the other giants, Tii is neither male nor female. Or both male and female. It\'s either really simple or really confusing, depending how you look at it. Some reckon this is why Tii seems cold and distant. They are incorrect. Tii is merely calculating and combining. It\'s distracting.';
	}
}

class TiiFirebog extends Shrine
{
	TiiFirebog(String id, int x, int y, String streetName) : super(id,x,y, streetName)
	{
		states =
		{
			"close" : new Spritesheet("close","http://childrenofur.com/assets/entityImages/npc_shrine_firebog_tii__x1_close_png_1354832850.png",984, 848, 164, 212, 23, false),
			"open" : new Spritesheet("open","http://childrenofur.com/assets/entityImages/npc_shrine_firebog_tii__x1_open_png_1354832848.png",984, 848, 164, 212, 22, false),
			"still" : new Spritesheet("still","http://childrenofur.com/assets/entityImages/npc_shrine_firebog_tii__x1_open_png_1354832848.png",984, 848, 164, 212, 1, false)
		};
		currentState = states['still'];
		type = 'Tii';

		description = 'This is a shrine to Tii, the overseer of elements, and the giant who manipulates all matters alchemical. Unlike the other giants, Tii is neither male nor female. Or both male and female. It\'s either really simple or really confusing, depending how you look at it. Some reckon this is why Tii seems cold and distant. They are incorrect. Tii is merely calculating and combining. It\'s distracting.';
	}
}

class TiiIx extends Shrine
{
	TiiIx(String id, int x, int y, String streetName) : super(id,x,y, streetName)
	{
		states =
		{
			"close" : new Spritesheet("close","http://childrenofur.com/assets/entityImages/npc_shrine_ix_ti__x1_close_png_1354831314.png",840,864,168,216,20, false),
			"open" : new Spritesheet("open","http://childrenofur.com/assets/entityImages/npc_shrine_ix_ti__x1_open_png_1354831313.png",840,864,168,216,24, false),
			"still" : new Spritesheet("still","http://childrenofur.com/assets/entityImages/npc_shrine_ix_ti__x1_open_png_1354831313.png",840,864,168,216,20, false),
		};
		currentState = states['still'];
		type = 'Tii';

		description = 'This is a shrine to Tii, the overseer of elements, and the giant who manipulates all matters alchemical. Unlike the other giants, Tii is neither male nor female. Or both male and female. It\'s either really simple or really confusing, depending how you look at it. Some reckon this is why Tii seems cold and distant. They are incorrect. Tii is merely calculating and combining. It\'s distracting.';
	}
}

class TiiUralia extends Shrine
{
	TiiUralia(String id, int x, int y, String streetName) : super(id,x,y, streetName)
	{
		states =
		{
			"close" : new Spritesheet("close","http://childrenofur.com/assets/entityImages/npc_shrine_uralia_ti__x1_close_png_1354831924.png",756, 752, 126, 188, 23, false),
			"open" : new Spritesheet("open","http://childrenofur.com/assets/entityImages/npc_shrine_uralia_ti__x1_open_png_1354831922.png",756, 752, 126, 188, 22, false),
			"still" : new Spritesheet("still","http://childrenofur.com/assets/entityImages/npc_shrine_uralia_ti__x1_open_png_1354831922.png",756, 752, 126, 188, 1, false),
		};
		currentState = states['still'];
		type = 'Tii';

		description = 'This is a shrine to Tii, the overseer of elements, and the giant who manipulates all matters alchemical. Unlike the other giants, Tii is neither male nor female. Or both male and female. It\'s either really simple or really confusing, depending how you look at it. Some reckon this is why Tii seems cold and distant. They are incorrect. Tii is merely calculating and combining. It\'s distracting.';
	}
}