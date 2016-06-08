part of entity;

class Fox extends NPC {
	static final String
		BRUSH = 'fox_brush',
		FIBER = 'fiber';

	Fox(String id, int x, int y, String streetName) : super(id, x, y, streetName) {
		// Client rendering
		type = 'Fox';
		speed = 0; // px/sec

		// Actions
		actionTime = 1;
		actions.add({
			'action': 'brush',
			'timeRequired': actionTime,
			'enabled': true,
			'actionWord': 'brushing',
			'requires':[
				{
					'num': 10,
					'of': ['energy']
				},
				{
					'num': 1,
					'of': [BRUSH]
				}
			]
		});

		// Spritesheets
		states = {
			'brushed': new Spritesheet('brushed',
				'http://c2.glitch.bz/items/2012-12-06/npc_fox_fox_orangeFox_x1_brushed_png_1354839597.png', 306, 139, 153, 139, 2, true),
			'eatEnd': new Spritesheet('eatEnd',
				'http://c2.glitch.bz/items/2012-12-06/npc_fox_fox_orangeFox_x1_eatEnd_png_1354839590.png', 765, 556, 153, 139, 20, false),
			'eatStart': new Spritesheet('eatStart',
				'http://c2.glitch.bz/items/2012-12-06/npc_fox_fox_orangeFox_x1_eatStart_png_1354839588.png', 765, 278, 153, 139, 10, false),
			'eat': new Spritesheet('eat',
				'http://c2.glitch.bz/items/2012-12-06/npc_fox_fox_orangeFox_x1_eat_png_1354839589.png', 765, 556, 153, 139, 20, true),
			'jump': new Spritesheet('jump',
				'http://c2.glitch.bz/items/2012-12-06/npc_fox_fox_orangeFox_x1_jump_png_1354839594.png', 918, 695, 153, 139, 28, false),
			'pause': new Spritesheet('pause',
				'http://c2.glitch.bz/items/2012-12-06/npc_fox_fox_orangeFox_x1_pause_png_1354839592.png', 918, 1390, 153, 139, 56, false),
			'run': new Spritesheet('run',
				'http://c2.glitch.bz/items/2012-12-06/npc_fox_fox_orangeFox_x1_run_png_1354839587.png', 918, 278, 153, 139, 12, true),
			'taunt': new Spritesheet('taunt',
				'http://c2.glitch.bz/items/2012-12-06/npc_fox_fox_orangeFox_x1_taunt_png_1354839596.png', 918, 973, 153, 139, 40, false),
			'walk': new Spritesheet('walk',
				'http://c2.glitch.bz/items/2012-12-06/npc_fox_fox_orangeFox_x1_walk_png_1354839598.png', 918, 556, 153, 139, 24, true)
		};
		setState('pause');
	}

	Future<bool> brush({WebSocket userSocket, String email}) async {
		if (rand.nextBool()) {
			if (!(await InventoryV2.decreaseDurability(email, BRUSH))) {
				// Could not use brush durability
				return false;
			}

			if ((await InventoryV2.addItemToUser(email, FIBER, 1)) != 1) {
				// Could not give user fiber
				return false;
			}

			toast('You got a $FIBER!', userSocket);

			return true;
		} else {
			toast('The fox got away!', userSocket);
			return false;
		}
	}

	@override
	void update() {
		super.update();

		// TODO: behavior. https://github.com/ChildrenOfUr/cou-issues/issues/971
	}
}

class SilverFox extends Fox {
	SilverFox(String id, int x, int y, String streetName) : super(id, x, y, streetName) {
		states = {
			'brushed': new Spritesheet('brushed',
				'http://c2.glitch.bz/items/2012-12-06/npc_fox_fox_silverFox_x1_brushed_png_1354839613.png', 306, 139, 153, 139, 2, true),
			'eatEnd': new Spritesheet('eatEnd',
				'http://c2.glitch.bz/items/2012-12-06/npc_fox_fox_silverFox_x1_eatEnd_png_1354839607.png', 765, 556, 153, 139, 20, false),
			'eatStart': new Spritesheet('eatStart',
				'http://c2.glitch.bz/items/2012-12-06/npc_fox_fox_silverFox_x1_eatStart_png_1354839605.png', 765, 278, 153, 139, 10, false),
			'eat': new Spritesheet('eat',
				'http://c2.glitch.bz/items/2012-12-06/npc_fox_fox_silverFox_x1_eat_png_1354839606.png', 765, 556, 153, 139, 20, true),
			'jump': new Spritesheet('jump',
				'http://c2.glitch.bz/items/2012-12-06/npc_fox_fox_silverFox_x1_jump_png_1354839611.png', 918, 695, 153, 139, 28, false),
			'pause': new Spritesheet('pause',
				'http://c2.glitch.bz/items/2012-12-06/npc_fox_fox_silverFox_x1_pause_png_1354839609.png', 918, 1390, 153, 139, 56, false),
			'run': new Spritesheet('run',
				'http://c2.glitch.bz/items/2012-12-06/npc_fox_fox_silverFox_x1_run_png_1354839602.png', 918, 278, 153, 139, 12, true),
			'taunt': new Spritesheet('taunt',
				'http://c2.glitch.bz/items/2012-12-06/npc_fox_fox_silverFox_x1_taunt_png_1354839613.png', 918, 973, 153, 139, 40, false),
			'walk': new Spritesheet('walk',
				'http://c2.glitch.bz/items/2012-12-06/npc_fox_fox_silverFox_x1_walk_png_1354839614.png', 918, 556, 153, 139, 24, true)
		};
		setState('pause');
	}
}
