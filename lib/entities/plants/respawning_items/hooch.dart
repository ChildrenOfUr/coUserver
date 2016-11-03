part of entity;

class HoochRespawningItem extends RespawningItem {
	HoochRespawningItem(String id, num x, num y, num z, num rotation, bool h_flip, String streetName)
	: super(id, x, y, z, rotation, h_flip, streetName) {
		type = 'Hooch';
		itemType = 'hooch';
		respawnTime = new Duration(minutes: 7);

		states = {
			'1-2-3-4': new Spritesheet('1-2-3-4',
				'http://childrenofur.com/assets/entityImages/hooch__x1_1_x1_2_x1_3_x1_4_png_1354829882.png',
				188, 52, 47, 52, 4, false)
		};

		setState('1-2-3-4');
		maxState = 3;
	}
}
