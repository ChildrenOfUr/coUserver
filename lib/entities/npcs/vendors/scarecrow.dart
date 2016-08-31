part of entity;

class GardeningGoodsVendor extends Vendor implements EventHandler<PlayerPosition> {
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
		'turn_left': new Spritesheet('walk',
			'http://childrenofur.com/assets/entityImages/npc_gardening_vendor__x1_walk_png_1354830998.png', 890, 594, 178, 198, 15, true),
		'turn_right': new Spritesheet('walk',
			'http://childrenofur.com/assets/entityImages/npc_gardening_vendor__x1_walk_png_1354830998.png', 890, 594, 178, 198, 15, true),
	};

	int openCount = 0;

	GardeningGoodsVendor(String id, String streetName, String tsid, num x, num y, num z)
	: super(id, streetName, tsid, x, y, z) {
		type = 'Gardening Goods Vendor';
		speed = 0;

		states = SPRITESHEETS;
		setState('idle_stand');

		itemsPredefined = true;
		itemsForSale = SELL_ITEMS;

		messageBus.subscribe(PlayerPosition, this, whereFunc: (PlayerPosition position) {
			return position.streetName == streetName;
		});
	}


	@override
	Map<String, dynamic> headers;

	@override
	void handleEvent(PlayerPosition event) {
		if(event.email == specialScarecrowEmail && _approx(x,event.x) && _approx(y,event.y)) {
			setState('walk', repeat: 10, thenState: currentState.stateName);
		}
	}

	bool _approx(num compare, num to) {
		return (compare - to).abs() < 150;
	}

	void update() {
		super.update();

		// update x and y
		if (currentState.stateName == 'walk') {
			moveXY(
				wallAction: (Wall wall) {
					// Don't turn around
					return;
				},
				ledgeAction: () {
					// Float, don't fall
					return;
				}
			);
		}

		if (respawn != null && new DateTime.now().isAfter(respawn)) {
			if (rand.nextInt(4) > 2) {
				// 50% chance of trying to attract buyers for 5 seconds
				setState('attract', repeatFor: new Duration(seconds: 5));
			} else {
				// Wait for 20 seconds
				setState('idle_stand', repeatFor: new Duration(seconds: 20));
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
