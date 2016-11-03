part of entity;

class AwesomeStewRespawningItem extends RespawningItem {
	AwesomeStewRespawningItem(String id, num x, num y, num z, num rotation, bool h_flip, String streetName)
	: super(id, x, y, z, rotation, h_flip, streetName) {
		type = 'Awesome Stew';
		itemType = 'awesome_stew';
		respawnTime = new Duration(hours: 2);

		states = {
			'1-2-3-4': new Spritesheet('1-2-3-4',
				'http://childrenofur.com/assets/entityImages/awesome_stew__x1_1_x1_2_x1_3_x1_4_png_1354829703.png',
				144, 40, 36, 40, 4, false)
		};

		setState('1-2-3-4');
		maxState = 3;
	}
}
