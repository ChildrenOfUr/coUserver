part of entity;

class GardeningGoodsVendor extends Vendor {
	static final List<Map<String, dynamic>> SELL_ITEMS = [
		items['hoe'].getMap(),
		items['watering_can'].getMap(),
		items['broccoli_seed'].getMap(),
		items['cabbage_seed'].getMap(),
		items['carrot_seed'].getMap(),
		items['corn_seed'].getMap(),
		items['cucumber_seed'].getMap(),
		items['onion_seed'].getMap(),
		items['parsnip_seed'].getMap(),
		items['potato_seed'].getMap(),
		items['pumpkin_seed'].getMap(),
		items['rice_seed'].getMap(),
		items['spinach_seed'].getMap(),
		items['tomato_seed'].getMap(),
		items['zucchini_seed'].getMap()
	];

	static final Map<String, Spritesheet> SPRITESHEETS = {
		'attract': new Spritesheet('attract',
			'http://childrenofur.com/assets/entityImages/npc_gardening_vendor__x1_attract_png_1354831005.png', 890, 1188, 178, 198, 30, true),
		'idle_stand': new Spritesheet('idle_stand',
			'http://childrenofur.com/assets/entityImages/npc_gardening_vendor__x1_idle_stand_png_1354831015.png', 3916, 2376, 178, 198, 260, true),
		'talk': new Spritesheet('talk',
			'http://childrenofur.com/assets/entityImages/npc_gardening_vendor__x1_talk_png_1354831002.png', 890, 1188, 178, 198, 26, false),
		'walk_end': new Spritesheet('walk_end',
			'http://childrenofur.com/assets/entityImages/npc_gardening_vendor__x1_walk_end_png_1354831000.png', 890, 594, 178, 198, 13, false),
		'walk': new Spritesheet('walk',
			'http://childrenofur.com/assets/entityImages/npc_gardening_vendor__x1_walk_png_1354830998.png', 890, 594, 178, 198, 15, true),
		'turn_left': SPRITESHEETS['walk'],
		'turn_right': SPRITESHEETS['walk']
	};

	int openCount = 0;

	GardeningGoodsVendor(String id, String streetName, String tsid, num x, num y)
	: super(id, streetName, tsid, x, y) {
		type = 'Gardening Goods Vendor';
		speed = 0;

		states = SPRITESHEETS;
		setState('idle_stand');

		itemsPredefined = true;
		itemsForSale = SELL_ITEMS;
	}

	void update() {
		super.update();

		// update x and y
		if (currentState.stateName == 'walk') {
			moveXY(wallAction: (Wall wall) {
				facingRight = !facingRight;
			});
		}

		if (respawn != null && respawn.compareTo(new DateTime.now()) <= 0) {
			// if we just turned, we should say we're facing the other way, then we should start moving (that's why we turned around after all)
			if (currentState.stateName == 'turn_left') {
				// if we turned left, we are no longer facing right
				facingRight = false;
				// start walking left
				setState('walk');
			} else if (currentState.stateName == 'turn_right') {
				// if we turned right, we are now facing right
				facingRight = true;
				// start walking right
				setState('walk');
			} else {
				if (rand.nextInt(2) == 1) {
					setState('walk', repeat: 5);
				} else {
					if (rand.nextInt(4) > 2) {
						// 50% chance of trying to attract buyers
						setState('attract');
					} else if (rand.nextInt(2) == 1){
						// wait
						setState('idle_stand');
					}
				}
			}
		}
	}

	void buy({WebSocket userSocket, String email}) {
		setState('idle_stand');
		// don't go to another state until closed
		respawn = new DateTime.now().add(new Duration(days:50));
		openCount++;

		super.buy(userSocket:userSocket, email:email);
	}

	void sell({WebSocket userSocket, String email}) {
		setState('talk');
		// don't go to another state until closed
		respawn = new DateTime.now().add(new Duration(days:50));
		openCount++;

		super.sell(userSocket:userSocket, email:email);
	}

	void close({WebSocket userSocket, String email}) {
		openCount -= 1;
		// if no one else has them open
		if (openCount <= 0) {
			openCount = 0;
			setState('idle_stand');
		}
	}
}
