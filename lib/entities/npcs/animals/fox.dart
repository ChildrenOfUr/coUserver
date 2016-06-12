part of entity;

enum FoxDestinationType {
	HOME, BAIT
}

class Fox extends NPC {
	static final String
		BRUSH = 'fox_brush',
		FIBER = 'fiber';

	static final Duration SPAWN_TIME = new Duration(seconds: 3);

	static final int
		SPEED_STOP = 0,
		SPEED_SLOW = 40,
		SPEED_FAST = 80;

	Spritesheet lastState;

	bool despawning = false, waiting = false, brushing = false;

	Point<num> movingTo, home;
	FoxDestinationType destinationType;

	Fox(String id, num x, num y, String streetName) : super(id, x, y, streetName) {
		// Client rendering
		type = 'Fox';
		speed = 0; // px/sec

		home = new Point(x, y);

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
			brushing = true;

			if (!(await InventoryV2.decreaseDurability(email, BRUSH))) {
				// Could not use brush durability
				return false;
			}

			if ((await InventoryV2.addItemToUser(email, FIBER, 1)) != 1) {
				// Could not give user fiber
				return false;
			}

			toast('You got a $FIBER!', userSocket);

			brushing = false;

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

		if (brushing) {
			speed = SPEED_STOP;
			setState('brushed');
			return;
		}

		if (movingTo == null) {
			// Find & target bait
			FoxBait nearestBait = findNearestBait();
			if (nearestBait != null && nearestBait.attractedFox == null) {
				// Claim an unclaimed piece of bait
				nearestBait.attractedFox = this;

				// Appear soon
				waiting = true;
				new Future.delayed(SPAWN_TIME).then((_) {
					speed = SPEED_SLOW;
					show('walk');
					movingTo = new Point(nearestBait.x, nearestBait.y);
					destinationType = FoxDestinationType.BAIT;
					waiting = false;
				});
			} else if (!despawning) {
				// Disappear soon
				despawning = true;
				new Future.delayed(SPAWN_TIME).then((_) {
					hide();
					despawning = false;
				});
			}
		} else {
			facingRight = (movingTo.x > this.x);

			if ((this.x - movingTo.x).abs() < 20) {
				// At target
				movingTo = null;

				if (destinationType == FoxDestinationType.BAIT) {
					// Eat bait
					speed = SPEED_STOP;
					setState('eat');
					waiting = true;
					findNearestBait().eat().then((_) {
						// Return to start position
						speed = SPEED_FAST;
						setState('run');
						movingTo = home;
						destinationType = FoxDestinationType.HOME;
					});
				} else if (destinationType == FoxDestinationType.HOME) {
					// Start over
					hide();
					new Future.delayed(SPAWN_TIME).then((_) {
						waiting = false;
					});
				}
			} else {
				// Move toward target
				if (destinationType == FoxDestinationType.HOME) {
					speed = SPEED_FAST;
					setState('run');
				} else if (destinationType == FoxDestinationType.BAIT) {
					speed = SPEED_SLOW;
					setState('walk');
				}
			}

			moveXY();
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

	static final Duration
		EAT_TIME = new Duration(seconds: 3),
		MAX_TIME = new Duration(minutes: 5);

	// 1 fox per bait
	Fox attractedFox = null;

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

	@override
	void update() {
		super.update();

		// Fall to platforms
		moveXY();
	}

	Future eat() async {
		await new Future.delayed(EAT_TIME);
		setState('_hidden');
		removing = true;
		attractedFox = null;
	}

	String toString() => 'FoxBait at ($x, $y)';
}
