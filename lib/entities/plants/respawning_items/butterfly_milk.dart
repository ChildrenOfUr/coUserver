part of entity;

class ButterflyMilkRespawningItem extends RespawningItem {
	ButterflyMilkRespawningItem(String id, num x, num y, num z, num rotation, bool h_flip, String streetName)
	: super(id, x, y, z, rotation, h_flip, streetName) {
		type = 'Butterfly Milk';
		itemType = 'butterfly_milk';
		respawnTime = new Duration(minutes: 1);

		states = {
			'1-2-3-4': new Spritesheet('1-2-3-4',
				'https://childrenofur.com/assets/entityImages/milk_butterfly__x1_1_x1_2_x1_3_x1_4_png_1354829507.png',
				148, 44, 37, 44, 4, false)
		};

		setState('1-2-3-4');
		maxState = 3;
	}
}
