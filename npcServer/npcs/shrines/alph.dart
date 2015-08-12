part of coUserver;

class Alph extends Shrine
{
	Alph(String id, int x, int y) : super(id,x,y)
	{
		states =
			{
				"close" : new Spritesheet("close","http://childrenofur.com/assets/entityImages/npc_shrine_alph__x1_close_png_1354831208.png",906,752,151,188,23,false),
				"open" : new Spritesheet("open","http://childrenofur.com/assets/entityImages/npc_shrine_alph__x1_open_png_1354831207.png",906,752,151,188,22,false),
				"still" : new Spritesheet("still","http://childrenofur.com/assets/entityImages/npc_shrine_alph__x1_open_png_1354831207.png",906,752,151,188,1,false)
			};
	 	currentState = states['still'];
	 	type = 'Alph';

	 	description = 'This is a shrine to Alph, the giant of creation. If you\'ve ever wondered "Why do Piggies make meat?" or "Which came first: the chicken or the egg plant?" chances are Alph has the answer.';
	}
}

class AlphFirebog extends Shrine {
	AlphFirebog(String id, int x, int y) : super(id,x,y) {
		states = {
			"close" : new Spritesheet("close","http://childrenofur.com/assets/entityImages/npc_shrine_firebog_alph__x1_close_png_1354832766.png",984, 848, 164, 212, 23, false),
			"open" : new Spritesheet("open","http://childrenofur.com/assets/entityImages/npc_shrine_firebog_alph__x1_open_png_1354832764.png",984, 848, 164, 212, 22, false),
			"still" : new Spritesheet("still","http://childrenofur.com/assets/entityImages/npc_shrine_firebog_alph__x1_open_png_1354832764.png", 984, 848, 164, 212, 1, false)
		};
		currentState = states['still'];
		type = 'Alph';

		description = 'This is a shrine to Alph, the giant of creation. If you\'ve ever wondered "Why do Piggies make meat?" or "Which came first: the chicken or the egg plant?" chances are Alph has the answer.';
	}
}

class AlphIx extends Shrine {
	AlphIx(String id, int x, int y) : super(id,x,y) {
		states = {
			"close" : new Spritesheet("close","http://childrenofur.com/assets/entityImages/npc_shrine_ix_alph__x1_close_png_1354831264.png",840,864,168,216,20, false),
			"open" : new Spritesheet("open","http://childrenofur.com/assets/entityImages/npc_shrine_ix_alph__x1_open_png_1354831261.png",840,1080,168,216,24, false),
			"still" : new Spritesheet("still","http://childrenofur.com/assets/entityImages/npc_shrine_ix_alph__x1_open_png_1354831261.png", 840,1080,168,216, 1, false)
		};
		currentState = states['still'];
		type = 'Alph';

		description = 'This is a shrine to Alph, the giant of creation. If you\'ve ever wondered "Why do Piggies make meat?" or "Which came first: the chicken or the egg plant?" chances are Alph has the answer.';
	}
}

class AlphUralia extends Shrine {
	AlphUralia(String id, int x, int y) : super(id,x,y) {
		states = {
			"close" : new Spritesheet("close","http://childrenofur.com/assets/entityImages/npc_shrine_uralia_alph__x1_close_png_1354831862.png",756, 752, 126, 188, 23, false),
			"open" : new Spritesheet("open","http://childrenofur.com/assets/entityImages/npc_shrine_uralia_alph__x1_open_png_1354831859.png",756, 752, 128, 188, 22, false),
			"still" : new Spritesheet("still","http://childrenofur.com/assets/entityImages/npc_shrine_uralia_alph__x1_open_png_1354831859.png", 756, 752, 128, 188, 1, false)
		};
		currentState = states['still'];
		type = 'Alph';

		description = 'This is a shrine to Alph, the giant of creation. If you\'ve ever wondered "Why do Piggies make meat?" or "Which came first: the chicken or the egg plant?" chances are Alph has the answer.';
	}
}