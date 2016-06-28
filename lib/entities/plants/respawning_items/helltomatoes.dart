part of entity;

class HellTomato extends RespawningItem {
	HellTomato(String id, num x, num y, String streetName) : super(id, x, y, streetName) {
		type = 'Tomato';
		itemType = 'tomato';

		states = {
			'tomato': new Spritesheet('1-2-3-4', 'http://childrenofur.com/assets/entityImages/tomato__x1_1_x1_2_x1_3_x1_4_png_1354830045.png', 176, 31, 44, 31, 4, true)
		};

		setState('tomato');
		maxState = 3;
	}
}
