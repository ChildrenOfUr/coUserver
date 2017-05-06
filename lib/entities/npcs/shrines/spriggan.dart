part of entity;

class Spriggan extends Shrine
{
	Spriggan(String id, num x, num y, num z, num rotation, bool h_flip, String streetName) : super(id, x, y, z, rotation, h_flip, streetName)
	{
		states =
		{
			"close" : new Spritesheet("close","https://childrenofur.com/assets/entityImages/npc_shrine_spriggan__x1_close_png_1354831248.png",906,752,151,188,23,false),
			"open" : new Spritesheet("open","https://childrenofur.com/assets/entityImages/npc_shrine_spriggan__x1_open_png_1354831246.png",906,752,151,188,22,false),
			"still" : new Spritesheet("still","https://childrenofur.com/assets/entityImages/npc_shrine_spriggan__x1_open_png_1354831246.png",906,752,151,188,1,false)
		};
		setState('still');
		type = 'Spriggan';

		description = 'This is a shrine to Spriggan. Sure, Spriggan is the most taciturn and humorless of all the giants. You would be, too, if you had sole dominion over the trees. Trees are serious business, you know.';
	}
}

class SprigganFirebog extends Shrine
{
	SprigganFirebog(String id, num x, num y, num z, num rotation, bool h_flip, String streetName) : super(id, x, y, z, rotation, h_flip, streetName)
	{
		states =
		{
			"close" : new Spritesheet("close","https://childrenofur.com/assets/entityImages/npc_shrine_firebog_spriggan__x1_close_png_1354832843.png",984, 848, 164, 212, 23, false),
			"open" : new Spritesheet("open","https://childrenofur.com/assets/entityImages/npc_shrine_firebog_spriggan__x1_open_png_1354832841.png",984, 848, 164, 212, 22, false),
			"still" : new Spritesheet("still","https://childrenofur.com/assets/entityImages/npc_shrine_firebog_spriggan__x1_open_png_1354832841.png",984, 848, 164, 212, 1, false)
		};
		setState('still');
		type = 'Spriggan';

		description = 'This is a shrine to Spriggan. Sure, Spriggan is the most taciturn and humorless of all the giants. You would be, too, if you had sole dominion over the trees. Trees are serious business, you know.';
	}
}

class SprigganIx extends Shrine
{
	SprigganIx(String id, num x, num y, num z, num rotation, bool h_flip, String streetName) : super(id, x, y, z, rotation, h_flip, streetName)
	{
		states =
		{
			"close" : new Spritesheet("close","https://childrenofur.com/assets/entityImages/npc_shrine_ix_spriggan__x1_close_png_1354831304.png",840,864,168,216,20, false),
			"open" : new Spritesheet("open","https://childrenofur.com/assets/entityImages/npc_shrine_ix_spriggan__x1_open_png_1354831303.png",840,864,168,216,24, false),
			"still" : new Spritesheet("still","https://childrenofur.com/assets/entityImages/npc_shrine_ix_spriggan__x1_open_png_1354831303.png",840,864,168,216,1, false)
		};
		setState('still');
		type = 'Spriggan';

		description = 'This is a shrine to Spriggan. Sure, Spriggan is the most taciturn and humorless of all the giants. You would be, too, if you had sole dominion over the trees. Trees are serious business, you know.';
	}
}

class SprigganUralia extends Shrine
{
	SprigganUralia(String id, num x, num y, num z, num rotation, bool h_flip, String streetName) : super(id, x, y, z, rotation, h_flip, streetName)
	{
		states =
		{
			"close" : new Spritesheet("close","https://childrenofur.com/assets/entityImages/npc_shrine_uralia_spriggan__x1_close_png_1354831918.png",756, 752, 126, 188, 23, false),
			"open" : new Spritesheet("open","https://childrenofur.com/assets/entityImages/npc_shrine_uralia_spriggan__x1_open_png_1354831915.png",756, 752, 126, 188, 22, false),
			"still" : new Spritesheet("still","https://childrenofur.com/assets/entityImages/npc_shrine_uralia_spriggan__x1_open_png_1354831915.png",756, 752, 126, 188, 1, false),
		};
		setState('still');
		type = 'Spriggan';

		description = 'This is a shrine to Spriggan. Sure, Spriggan is the most taciturn and humorless of all the giants. You would be, too, if you had sole dominion over the trees. Trees are serious business, you know.';
	}
}