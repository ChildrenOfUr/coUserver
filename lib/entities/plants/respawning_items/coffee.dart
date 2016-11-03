part of entity;

class CoffeeRespawningItem extends RespawningItem {
	CoffeeRespawningItem(String id, num x, num y, num z, num rotation, bool h_flip, String streetName)
	: super(id, x, y, z, rotation, h_flip, streetName) {
		type = 'Coffee';
		itemType = 'coffee';
		respawnTime = new Duration(seconds: 30);

		states = {
			'1-2-3-4': new Spritesheet('1-2-3-4',
				'http://childrenofur.com/assets/entityImages/coffee__x1_1_x1_2_x1_3_x1_4_png_1354829780.png',
				192, 33, 48, 33, 4, false)
		};

		setState('1-2-3-4');
		maxState = 3;
	}
}
