part of entity;

class HellTomato extends RespawningItem {
	HellTomato(String id, num x, num y, num z, num rotation, bool h_flip, String streetName) : super(id, x, y, z, rotation, h_flip, streetName) {
		type = 'Tomato';
		itemType = 'tomato';

		states = {
			'1-2-3-4': new Spritesheet('1-2-3-4',
				'http://childrenofur.com/assets/entityImages/tomato__x1_1_x1_2_x1_3_x1_4_png_1354830045.png',
				176, 31, 44, 31, 4, true)
		};

		setState('1-2-3-4');
		maxState = 3;
	}
}
