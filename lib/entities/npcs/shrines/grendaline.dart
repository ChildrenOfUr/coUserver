part of entity;

class Grendaline extends Shrine
{
	Grendaline(String id, num x, num y, num z, num rotation, bool h_flip, String streetName) : super(id, x, y, z, rotation, h_flip, streetName)
	{
		states =
			{
				"close" : new Spritesheet("close","https://childrenofur.com/assets/entityImages/npc_shrine_grendaline__x1_close_png_1354831223.png",906,752,151,188,23,false),
				"open" : new Spritesheet("open","https://childrenofur.com/assets/entityImages/npc_shrine_grendaline__x1_open_png_1354831222.png",906,752,151,188,22,false),
				"still" : new Spritesheet("still","https://childrenofur.com/assets/entityImages/npc_shrine_grendaline__x1_open_png_1354831222.png",906,752,151,188,1,false)
			};
	 	setState('still');
	 	type = 'Grendaline';

	 	description = 'This is a shrine to Grendaline. Quietly loyal and fierce, Grendaline is the giant who governs all things watery, from clouds and fogs to mountain streams and oceans. As a sideline, she is also influential in the sphere of big, fluffy towels.';
	}
}

class GrendalineFirebog extends Shrine
{
	GrendalineFirebog(String id, num x, num y, num z, num rotation, bool h_flip, String streetName) : super(id, x, y, z, rotation, h_flip, streetName)
	{
		states =
		{
			"close" : new Spritesheet("close","https://childrenofur.com/assets/entityImages/npc_shrine_firebog_grendaline__x1_close_png_1354832808.png",984,848,164,212,23,false),
			"open" : new Spritesheet("open","https://childrenofur.com/assets/entityImages/npc_shrine_firebog_grendaline__x1_open_png_1354832806.png",984,848,164,212,22,false),
			"still" : new Spritesheet("still","https://childrenofur.com/assets/entityImages/npc_shrine_firebog_grendaline__x1_open_png_1354832806.png",984,848,164,212,1,false)
		};
		setState('still');
		type = 'Grendaline';

		description = 'This is a shrine to Grendaline. Quietly loyal and fierce, Grendaline is the giant who governs all things watery, from clouds and fogs to mountain streams and oceans. As a sideline, she is also influential in the sphere of big, fluffy towels.';
	}
}

class GrendalineIx extends Shrine
{
	GrendalineIx(String id, num x, num y, num z, num rotation, bool h_flip, String streetName) : super(id, x, y, z, rotation, h_flip, streetName)
	{
		states =
		{
			"close" : new Spritesheet("close","https://childrenofur.com/assets/entityImages/npc_shrine_ix_grendaline__x1_close_png_1354831278.png",840,864,168,216,20,false),
			"open" : new Spritesheet("open","https://childrenofur.com/assets/entityImages/npc_shrine_ix_grendaline__x1_open_png_1354831277.png",840,1080,168,216,24,false),
			"still" : new Spritesheet("still","https://childrenofur.com/assets/entityImages/npc_shrine_ix_grendaline__x1_open_png_1354831277.png",840,1080,168,216,1,false)
		};
		setState('still');
		type = 'Grendaline';

		description = 'This is a shrine to Grendaline. Quietly loyal and fierce, Grendaline is the giant who governs all things watery, from clouds and fogs to mountain streams and oceans. As a sideline, she is also influential in the sphere of big, fluffy towels.';
	}
}

class GrendalineUralia extends Shrine
{
	GrendalineUralia(String id, num x, num y, num z, num rotation, bool h_flip, String streetName) : super(id, x, y, z, rotation, h_flip, streetName)
	{
		states =
		{
			"close" : new Spritesheet("close","https://childrenofur.com/assets/entityImages/npc_shrine_uralia_grendaline__x1_close_png_1354831883.png",756,752,126,188,23,false),
			"open" : new Spritesheet("open","https://childrenofur.com/assets/entityImages/npc_shrine_uralia_grendaline__x1_open_png_1354831881.png",756,752,126,188,22,false),
			"still" : new Spritesheet("still","https://childrenofur.com/assets/entityImages/npc_shrine_uralia_grendaline__x1_open_png_1354831881.png",756,752,126,188,1,false)
		};
		setState('still');
		type = 'Grendaline';

		description = 'This is a shrine to Grendaline. Quietly loyal and fierce, Grendaline is the giant who governs all things watery, from clouds and fogs to mountain streams and oceans. As a sideline, she is also influential in the sphere of big, fluffy towels.';
	}
}