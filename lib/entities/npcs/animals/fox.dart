part of entity;

class Fox extends NPC {
	static final String
		BRUSH = 'fox_brush',
		FIBER = 'fiber';

	static final Duration
		EAT_TIME = new Duration(seconds: 5),
		SPAWN_TIME = new Duration(seconds: 3);

	static final int
		SPEED_STOP = 0,
		SPEED_SLOW = 20,
		SPEED_FAST = 40;

	Spritesheet lastState;

	bool despawning = false, waiting = false;
	Point<num> movingTo;

	Fox(String id, num x, num y, String streetName) : super(id, x, y, streetName) {
		// Client rendering
		type = 'Fox';
		speed = 0; // px/sec

		// Actions
		actionTime = 1;
		ItemRequirements itemReq = new ItemRequirements()
			..any = [BRUSH];
		actions.add(
			new Action.withName('brush')
				..timeRequired = actionTime
				..actionWord = 'brushing'
				..energyRequirements = new EnergyRequirements(energyAmount: 3)
				..itemRequirements = itemReq
		);

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
				'http://c2.glitch.bz/items/2012-12-06/npc_fox_fox_orangeFox_x1_walk_png_1354839598.png', 918, 556, 153, 139, 24, true),
			'_hidden': NPC.TRANSPARENT_SPRITE
		};
		hide();
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

	FoxBait findNearestBait() {
		List<FoxBait> onStreet = FoxBait.placedBait[streetName] ?? [];

		FoxBait nearestBait;
		num nearestDist;
		onStreet.forEach((FoxBait bait) {
			num distX = (this.x - bait.x).abs();
			num distY = (this.y - bait.y).abs();
			num dist = sqrt(pow(distX, 2) + pow(distY, 2));

			if (nearestDist == null || dist < nearestDist) {
				nearestDist = dist;
				nearestBait = bait;
			}
		});

		return nearestBait;
	}

	void hide() {
		lastState = currentState;
		setActionEnabled('brush', false);
		setState('_hidden');
	}

	void show([String overrideState]) {
		String state = overrideState ?? lastState?.stateName;
		if (state != null) {
			setState(state);
		}
		setActionEnabled('brush', true);
		lastState = null;
	}

	@override
	void update() {
		super.update();

		if (waiting) {
			return;
		}

		if (movingTo == null) {
			// Find & target bait
			FoxBait nearestBait = findNearestBait();
			if (nearestBait != null) {
				// Appear soon
				waiting = true;
				new Future.delayed(SPAWN_TIME).then((_) {
					show('walk');
					movingTo = new Point(nearestBait.x, nearestBait.y);
					waiting = false;
				});
			} else {
				// Disappear soon
				if (!despawning) {
					despawning = true;
					new Future.delayed(SPAWN_TIME).then((_) {
						hide();
						despawning = false;
					});
				}
			}
		} else {
			facingRight = (movingTo.x > this.x);

			if ((this.x - movingTo.x).abs() < 20) {
				// At target
				movingTo = null;

				setState('eat');
				waiting = true;
				new Future.delayed(EAT_TIME).then((_) {
					waiting = false;
					hide();
				});

				findNearestBait().eat();
			} else {
				// Move toward target
				if (rand.nextInt(10) < 8) {
					// Chance of stopping
					speed = SPEED_STOP;
					setState('pause');
				} else if (speed == SPEED_STOP) {
					// Stopped, start again
					speed = SPEED_SLOW;
					setState('walk');
				}
			}
		}
	}
}

class SilverFox extends Fox {
	SilverFox(String id, num x, num y, String streetName) : super(id, x, y, streetName) {
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
				'http://c2.glitch.bz/items/2012-12-06/npc_fox_fox_silverFox_x1_walk_png_1354839614.png', 918, 556, 153, 139, 24, true),
			'_hidden': NPC.TRANSPARENT_SPRITE
		};
		hide();
	}
}

class FoxBait extends NPC {
	/// Maps street names to fox bait objects for locating by foxes
	static Map<String, List<FoxBait>> placedBait = {};

	static final Duration MAX_TIME = new Duration(minutes: 5);

	FoxBait(String id, num x, num y, String streetName) : super(id, x, y, streetName) {
		type = 'Fox Bait';
		speed = 0;

		// Mark bait as placed on this street
		if (placedBait[streetName] == null) {
			placedBait[streetName] = [];
		}
		placedBait[streetName].add(this);

		states = {
			'stink1': new Spritesheet('stink1',
				'http://childrenofur.com/assets/entityImages/fox_bait__x1_stink1_png_1354839629.png', 861, 288, 41, 144, 42, true),
			'stink2': new Spritesheet('stink1',
				'http://childrenofur.com/assets/entityImages/fox_bait__x1_stink2_png_1354839630.png', 902, 288, 41, 144, 43, true),
			'stink3': new Spritesheet('stink1',
				'http://childrenofur.com/assets/entityImages/fox_bait__x1_stink3_png_1354839632.png', 861, 288, 41, 144, 42, true),
			'_hidden': NPC.TRANSPARENT_SPRITE
		};
		setState('stink${rand.nextInt(3) + 1}');

		// Add to street
		StreetUpdateHandler.streets[streetName]?.npcs[this.id] = this;

		// Go away after a while if not eaten by a fox
		new Future.delayed(MAX_TIME).then((_) => eat());
	}

	void eat() {
		setState('_hidden');
		StreetUpdateHandler.streets[streetName]?.npcs?.remove(this.id);
	}

	String toString() => 'FoxBait at ($x, $y)';
}
