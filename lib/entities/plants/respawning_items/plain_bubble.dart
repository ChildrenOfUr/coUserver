part of entity;

class PlainBubbleRespawningItem extends RespawningItem {
	PlainBubbleRespawningItem(String id, num x, num y, num z, num rotation, bool h_flip, String streetName)
	: super(id, x, y, z, rotation, h_flip, streetName) {
		type = 'Plain Bubble';
		itemType = 'plain_bubble';
		respawnTime = new Duration(seconds: 30);

		states = {
			'1-2-3-4': new Spritesheet('1-2-3-4',
				'http://childrenofur.com/assets/entityImages/plain_bubble__x1_1_x1_2_x1_3_x1_4_png_1354829962.png',
				132, 23, 33, 23, 4, false)
		};

		setState('1-2-3-4');
		maxState = 3;
	}
}
