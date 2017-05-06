part of entity;

class Pot extends Shrine
{
	Pot(String id, num x, num y, num z, num rotation, bool h_flip, String streetName) : super(id, x, y, z, rotation, h_flip, streetName)
	{
		states =
			{
				"close" : new Spritesheet("close","https://childrenofur.com/assets/entityImages/npc_shrine_pot__x1_close_png_1354831243.png",906,752,151,188,23,false),
				"open" : new Spritesheet("open","https://childrenofur.com/assets/entityImages/npc_shrine_pot__x1_open_png_1354831241.png",906,752,151,188,22,false),
				"still" : new Spritesheet("still","https://childrenofur.com/assets/entityImages/npc_shrine_pot__x1_open_png_1354831241.png",906,752,151,188,1,false)
			};
	 	setState('still');
	 	type = 'Pot';

	 	description = 'This is a shrine to Pot. Big-hearted and generous, Pot is the giant who dispenses prosperity and good fortune. Which is all well and good if you can keep sloth and indolence at bay. Tricky.';
	}
}

class PotFirebog extends Shrine
{
	PotFirebog(String id, num x, num y, num z, num rotation, bool h_flip, String streetName) : super(id, x, y, z, rotation, h_flip, streetName)
	{
		states =
		{
			"close" : new Spritesheet("close","https://childrenofur.com/assets/entityImages/npc_shrine_firebog_pot__x1_close_png_1354832830.png",984, 848, 164, 212, 23, false),
			"open" : new Spritesheet("open","https://childrenofur.com/assets/entityImages/npc_shrine_firebog_pot__x1_open_png_1354832828.png",984, 848, 164, 212, 22, false),
			"still" : new Spritesheet("still","https://childrenofur.com/assets/entityImages/npc_shrine_firebog_pot__x1_open_png_1354832828.png", 984, 848, 164, 212, 1, false)
		};
		setState('still');
		type = 'Pot';

		description = 'This is a shrine to Pot. Big-hearted and generous, Pot is the giant who dispenses prosperity and good fortune. Which is all well and good if you can keep sloth and indolence at bay. Tricky.';
	}
}

class PotIx extends Shrine
{
	PotIx(String id, num x, num y, num z, num rotation, bool h_flip, String streetName) : super(id, x, y, z, rotation, h_flip, streetName)
	{
		states =
		{
			"close" : new Spritesheet("close","https://childrenofur.com/assets/entityImages/npc_shrine_ix_pot__x1_close_png_1354831299.png",840,864,168,216,20, false),
			"open" : new Spritesheet("open","https://childrenofur.com/assets/entityImages/npc_shrine_ix_pot__x1_open_png_1354831298.png",840,1080,168,216,24, false),
			"still" : new Spritesheet("still","https://childrenofur.com/assets/entityImages/npc_shrine_ix_pot__x1_open_png_1354831298.png",840,1080,168,216, 1, false)
		};
		setState('still');
		type = 'Pot';

		description = 'This is a shrine to Pot. Big-hearted and generous, Pot is the giant who dispenses prosperity and good fortune. Which is all well and good if you can keep sloth and indolence at bay. Tricky.';
	}
}

class PotUralia extends Shrine
{
	PotUralia(String id, num x, num y, num z, num rotation, bool h_flip, String streetName) : super(id, x, y, z, rotation, h_flip, streetName)
	{
		states =
		{
			"close" : new Spritesheet("close","https://childrenofur.com/assets/entityImages/npc_shrine_uralia_pot__x1_close_png_1354831911.png",756, 752, 126, 188, 23, false),
			"open" : new Spritesheet("open","https://childrenofur.com/assets/entityImages/npc_shrine_uralia_pot__x1_open_png_1354831908.png",756, 752, 126, 188, 22, false),
			"still" : new Spritesheet("still","https://childrenofur.com/assets/entityImages/npc_shrine_uralia_pot__x1_open_png_1354831908.png", 756, 752, 126, 188, 1, false)
		};
		setState('still');
		type = 'Pot';

		description = 'This is a shrine to Pot. Big-hearted and generous, Pot is the giant who dispenses prosperity and good fortune. Which is all well and good if you can keep sloth and indolence at bay. Tricky.';
	}
}