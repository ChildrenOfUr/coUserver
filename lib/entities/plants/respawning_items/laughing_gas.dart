part of entity;

class LaughingGasRespawningItem extends RespawningItem {
	LaughingGasRespawningItem(String id, num x, num y, num z, num rotation, bool h_flip, String streetName)
	: super(id, x, y, z, rotation, h_flip, streetName) {
		type = 'Laughing Gas';
		itemType = 'gas_laughing';
		respawnTime = new Duration(minutes: 3);

		states = {
			'1-2-3-4': new Spritesheet('1-2-3-4',
				'https://childrenofur.com/assets/entityImages/laughing_gas__x1_1_x1_2_x1_3_x1_4_png_1354830724.png',
				208, 43, 52, 43, 4, false)
		};

		setState('1-2-3-4');
		maxState = 3;
	}
}
