part of entity;

class HotNFizzySauceRespawningItem extends RespawningItem {
	HotNFizzySauceRespawningItem(String id, num x, num y, num z, num rotation, bool h_flip, String streetName)
		: super(id, x, y, z, rotation, h_flip, streetName) {
		type = "Hot 'n' Fizzy Sauce";
		itemType = 'hot_n_fizzy_sauce';
		respawnTime = new Duration(minutes: 6);

		states = {
			'1-2-3-4': new Spritesheet('1-2-3-4',
				'https://childrenofur.com/assets/entityImages/hot_n_fizzy_sauce__x1_1_x1_2_x1_3_x1_4_png_1354829885.png',
				108, 44, 27, 44, 4, false)
		};

		setState('1-2-3-4');
		maxState = 3;
	}
}
