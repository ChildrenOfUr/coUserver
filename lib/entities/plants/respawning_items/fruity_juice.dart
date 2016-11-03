part of entity;

class FruityJuiceRespawningItem extends RespawningItem {
	FruityJuiceRespawningItem(String id, num x, num y, num z, num rotation, bool h_flip, String streetName)
	: super(id, x, y, z, rotation, h_flip, streetName) {
		type = 'Fruity Juice';
		itemType = 'fruity_juice';
		respawnTime = new Duration(minutes: 3);

		states = {
			'1-2-3-4': new Spritesheet('1-2-3-4',
				'http://childrenofur.com/assets/entityImages/fruity_juice__x1_1_x1_2_x1_3_x1_4_png_1354829845.png',
				168, 39, 42, 39, 4, false)
		};

		setState('1-2-3-4');
		maxState = 3;
	}
}
