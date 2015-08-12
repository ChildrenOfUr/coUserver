part of coUserver;

class Lem extends Shrine
{
	Lem(String id, int x, int y) : super(id,x,y)
	{
		states =
			{
				"close" : new Spritesheet("close","http://childrenofur.com/assets/entityImages/npc_shrine_lem__x1_close_png_1354831233.png",906,752,151,188,23,false),
				"open" : new Spritesheet("open","http://childrenofur.com/assets/entityImages/npc_shrine_lem__x1_open_png_1354831232.png",906,752,151,188,22,false),
				"still" : new Spritesheet("still","http://childrenofur.com/assets/entityImages/npc_shrine_lem__x1_open_png_1354831232.png",906,752,151,188,1,false)
			};
	 	currentState = states['still'];
	 	type = 'Lem';

	 	description = 'This is a shrine to Lem, the giant of travel and navigation. If you\'ve ever found yourself somewhere you didn\'t plan to be, chances are it was a Lemish practical joke, for which he is utterly unrepentant.';
	}
}

class LemFirebog extends Shrine
{
	LemFirebog(String id, int x, int y) : super(id,x,y)
	{
		states =
		{
			"close" : new Spritesheet("close","http://childrenofur.com/assets/entityImages/npc_shrine_firebog_lem__x1_close_png_1354832823.png",984,848,164,212,23,false),
			"open" : new Spritesheet("open","http://childrenofur.com/assets/entityImages/npc_shrine_firebog_lem__x1_open_png_1354832820.png",984,848,164,212,22,false),
			"still" : new Spritesheet("still","http://childrenofur.com/assets/entityImages/npc_shrine_firebog_lem__x1_open_png_1354832820.png",984,848,164,212,1,false)
		};
		currentState = states['still'];
		type = 'Lem';

		description = 'This is a shrine to Lem, the giant of travel and navigation. If you\'ve ever found yourself somewhere you didn\'t plan to be, chances are it was a Lemish practical joke, for which he is utterly unrepentant.';
	}
}

class LemIx extends Shrine
{
	LemIx(String id, int x, int y) : super(id,x,y)
	{
		states =
		{
			"close" : new Spritesheet("close","http://childrenofur.com/assets/entityImages/npc_shrine_ix_lem__x1_close_png_1354831289.png",840,864,168,216,20,false),
			"open" : new Spritesheet("open","http://childrenofur.com/assets/entityImages/npc_shrine_ix_lem__x1_open_png_1354831287.png",840,1080,168,216,24,false),
			"still" : new Spritesheet("still","http://childrenofur.com/assets/entityImages/npc_shrine_ix_lem__x1_open_png_1354831287.png",840,1080,168,216,1,false)
		};
		currentState = states['still'];
		type = 'Lem';

		description = 'This is a shrine to Lem, the giant of travel and navigation. If you\'ve ever found yourself somewhere you didn\'t plan to be, chances are it was a Lemish practical joke, for which he is utterly unrepentant.';
	}
}

class LemUralia extends Shrine
{
	LemUralia(String id, int x, int y) : super(id,x,y)
	{
		states =
		{
			"close" : new Spritesheet("close","http://childrenofur.com/assets/entityImages/npc_shrine_uralia_lem__x1_close_png_1354831897.png",756,752,126,188,23,false),
			"open" : new Spritesheet("open","http://childrenofur.com/assets/entityImages/npc_shrine_uralia_lem__x1_open_png_1354831895.png",756,752,126,188,22,false),
			"still" : new Spritesheet("still","http://childrenofur.com/assets/entityImages/npc_shrine_uralia_lem__x1_open_png_1354831895.png",756,752,126,188,1,false)
		};
		currentState = states['still'];
		type = 'Lem';

		description = 'This is a shrine to Lem, the giant of travel and navigation. If you\'ve ever found yourself somewhere you didn\'t plan to be, chances are it was a Lemish practical joke, for which he is utterly unrepentant.';
	}
}