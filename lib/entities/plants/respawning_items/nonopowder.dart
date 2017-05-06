part of entity;

class NoNoPowderRespawningItem extends RespawningItem {
	NoNoPowderRespawningItem(String id, num x, num y, num z, num rotation, bool h_flip, String streetName)
	: super(id, x, y, z, rotation, h_flip, streetName) {
		type = 'No-No Powder';
		itemType = 'no_no_powder';
		respawnTime = new Duration(seconds: 30);

		states = {
			'1-2-3-4': new Spritesheet('1-2-3-4',
				'https://childrenofur.com/assets/entityImages/no_no_powder__x1_1_x1_2_x1_3_x1_4_png_1354832159.png',
				180, 18, 45, 18, 4, false)
		};

		setState('1-2-3-4');
		maxState = 3;
	}
}
