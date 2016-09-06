part of entity;

class Zille extends Shrine
{
	Zille(String id, num x, num y, num z, num rotation, bool h_flip, String streetName) : super(id, x, y, z, rotation, h_flip, streetName)
	{
		states =
			{
				"close" : new Spritesheet("close","http://childrenofur.com/assets/entityImages/npc_shrine_zille__x1_close_png_1354831253.png",906,752,151,188,23,false),
				"open" : new Spritesheet("open","http://childrenofur.com/assets/entityImages/npc_shrine_zille__x1_open_png_1354831251.png",906,752,151,188,22,false),
				"still" : new Spritesheet("still","http://childrenofur.com/assets/entityImages/npc_shrine_zille__x1_open_png_1354831251.png",906,752,151,188,1,false)
			};
	 	setState('still');
	 	type = 'Zille';

	 	description = 'This is a shrine to Zille, the giant whose domain is the mountains. Hills, too. Also hillocks, pingos, drumlins and buttes. It\'s safe to consider that any bump in the ground is Zille\'s turf. She takes no responsibility, however, for volcanoes.';
	}
}

class ZilleFirebog extends Shrine
{
	ZilleFirebog(String id, num x, num y, num z, num rotation, bool h_flip, String streetName) : super(id, x, y, z, rotation, h_flip, streetName)
	{
		states =
		{
			"close" : new Spritesheet("close","http://childrenofur.com/assets/entityImages/npc_shrine_firebog_zille__x1_close_png_1354832857.png",984, 848, 164, 212, 23, false),
			"open" : new Spritesheet("open","http://childrenofur.com/assets/entityImages/npc_shrine_firebog_zille__x1_open_png_1354832855.png",984, 848, 164, 212, 22, false),
			"still" : new Spritesheet("still","http://childrenofur.com/assets/entityImages/npc_shrine_firebog_zille__x1_open_png_1354832855.png",984, 848, 164, 212, 1, false)
		};
		setState('still');
		type = 'Zille';

		description = 'This is a shrine to Zille, the giant whose domain is the mountains. Hills, too. Also hillocks, pingos, drumlins and buttes. It\'s safe to consider that any bump in the ground is Zille\'s turf. She takes no responsibility, however, for volcanoes.';
	}
}

class ZilleIx extends Shrine
{
	ZilleIx(String id, num x, num y, num z, num rotation, bool h_flip, String streetName) : super(id, x, y, z, rotation, h_flip, streetName)
	{
		states =
		{
			"close" : new Spritesheet("close","http://childrenofur.com/assets/entityImages/npc_shrine_ix_zille__x1_close_png_1354831310.png",840,864,168,216,20, false),
			"open" : new Spritesheet("open","http://childrenofur.com/assets/entityImages/npc_shrine_ix_zille__x1_open_png_1354831308.png",840,864,168,216,24, false),
			"still" : new Spritesheet("still","http://childrenofur.com/assets/entityImages/npc_shrine_ix_zille__x1_open_png_1354831308.png",840,864,168,216,1, false),
		};
		setState('still');
		type = 'Zille';

		description = 'This is a shrine to Zille, the giant whose domain is the mountains. Hills, too. Also hillocks, pingos, drumlins and buttes. It\'s safe to consider that any bump in the ground is Zille\'s turf. She takes no responsibility, however, for volcanoes.';
	}
}

class ZilleUralia extends Shrine
{
	ZilleUralia(String id, num x, num y, num z, num rotation, bool h_flip, String streetName) : super(id, x, y, z, rotation, h_flip, streetName)
	{
		states =
		{
			"close" : new Spritesheet("close","http://childrenofur.com/assets/entityImages/npc_shrine_uralia_zille__x1_close_png_1354831931.png",756, 752, 126, 188, 23, false),
			"open" : new Spritesheet("open","http://childrenofur.com/assets/entityImages/npc_shrine_uralia_zille__x1_open_png_1354831929.png",756, 752, 126, 188, 22, false),
			"still" : new Spritesheet("still","http://childrenofur.com/assets/entityImages/npc_shrine_uralia_zille__x1_open_png_1354831929.png",756, 752, 126, 188, 1, false),
		};
		setState('still');
		type = 'Zille';

		description = 'This is a shrine to Zille, the giant whose domain is the mountains. Hills, too. Also hillocks, pingos, drumlins and buttes. It\'s safe to consider that any bump in the ground is Zille\'s turf. She takes no responsibility, however, for volcanoes.';
	}
}