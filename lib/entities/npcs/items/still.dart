part of entity;

class Still extends EntityItem {
	static final Map<String, Spritesheet> SPRITESHEETS = {
		'active': new Spritesheet('active',
			'http://childrenofur.com/assets/entityImages/still__x1_active_png_1354836755.png',
			960, 1630, 96, 163, 99, true),
		'collect': new Spritesheet('collect',
			'http://childrenofur.com/assets/entityImages/still__x1_collect_png_1354836759.png',
			960, 1956, 96, 163, 119, false),
		'ready': new Spritesheet('ready',
			'http://childrenofur.com/assets/entityImages/still__x1_ready_png_1354836756.png',
			864, 815, 96, 163, 41, true),
		'empty': new Spritesheet('empty',
			'http://childrenofur.com/assets/entityImages/still__x1_empty_png_1354836751.png',
			96, 163, 96, 163, 1, true)
	};

	Still(String id, int x, int y, String streetName) : super(id, x, y, streetName) {
		type = 'Still';
		itemType = 'still';
		states = SPRITESHEETS;
		setState('empty');
	}
}