part of entity;

class PurpleFlowerRespawningItem extends RespawningItem {
	PurpleFlowerRespawningItem(String id, num x, num y, num z, num rotation, bool h_flip, String streetName)
	: super(id, x, y, z, rotation, h_flip, streetName) {
		type = 'Purple Flower';
		itemType = 'purple_flower';
		respawnTime = new Duration(minutes: 3);

		states = {
			'1-2-3-4': new Spritesheet('1-2-3-4',
				'http://childrenofur.com/assets/entityImages/purple_flower__x1_1_x1_2_x1_3_x1_4_png_1354833813.png',
				272, 45, 68, 45, 4, false)
		};

		setState('1-2-3-4');
		maxState = 3;
	}
}
