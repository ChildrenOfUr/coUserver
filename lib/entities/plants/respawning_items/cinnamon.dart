part of entity;

class CinnamonRespawningItem extends RespawningItem {
	CinnamonRespawningItem(String id, num x, num y, num z, num rotation, bool h_flip, String streetName)
	: super(id, x, y, z, rotation, h_flip, streetName) {
		type = 'Cinnamon';
		itemType = 'cinnamon';
		respawnTime = new Duration(minutes: 2);

		states = {
			'1-2-3-4': new Spritesheet('1-2-3-4',
				'http://childrenofur.com/assets/entityImages/cinnamon__x1_1_x1_2_x1_3_x1_4_png_1354829766.png',
				208, 17, 52, 17, 4, false)
		};

		setState('1-2-3-4');
		maxState = 3;
	}
}
