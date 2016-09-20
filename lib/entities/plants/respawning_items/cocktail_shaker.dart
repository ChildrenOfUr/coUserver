part of entity;

class CocktailShakerRespawningItem extends RespawningItem {
	CocktailShakerRespawningItem(String id, num x, num y, num z, num rotation, bool h_flip, String streetName)
	: super(id, x, y, z, rotation, h_flip, streetName) {
		type = 'Cocktail Shaker';
		itemType = 'cocktail_shaker';
		respawnTime = new Duration(minutes: 45);

		states = {
			'1': new Spritesheet('1',
				'http://childrenofur.com/assets/entityImages/cocktail_shaker__x1_1_png_1354830096.png',
				36, 40, 36, 40, 1, false)
		};

		setState('1');
		maxState = 1;
	}
}
