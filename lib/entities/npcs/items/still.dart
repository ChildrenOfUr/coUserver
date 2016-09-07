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

	static final int BREW_SECONDS = 3;

	static final int INPUT_PER_HOOCH = 4;

	static final String HOOCH = 'hooch';

	static final String
		CORN = 'corn',
		GRAIN = 'grain',
		POTATO = 'potato';

	static final Action ACTION_ADD = new Action()
		..timeRequired = 500
		..multiEnabled = true
		..actionWord = 'hopping'
		..error = "You don't have any";

	static final Action ACTION_ADD_CORN = new Action.clone(ACTION_ADD)
		..actionName = 'add corn'
		..itemRequirements = new ItemRequirements.set(all: {CORN: 1});

	static final Action ACTION_ADD_GRAIN = new Action.clone(ACTION_ADD)
		..actionName = 'add grain'
		..itemRequirements = new ItemRequirements.set(all: {GRAIN: 1});

	static final Action ACTION_ADD_POTATO = new Action.clone(ACTION_ADD)
		..actionName = 'add potato'
		..itemRequirements = new ItemRequirements.set(all: {POTATO: 1});

	static final Action ACTION_COLLECT = new Action.withName('collect')
		..actionWord = 'collecting';

	int pending = 0;
	int processed = 0;

	bool collecting = false;

	Still(String id, num x, num y, num z, num rotation, bool h_flip, String streetName) : super(id, x, y, z, rotation, h_flip, streetName) {
		type = 'Still';
		itemType = 'still';
		states = SPRITESHEETS;
		setState('empty');

		actions
			..add(ACTION_ADD_CORN)
			..add(ACTION_ADD_GRAIN)
			..add(ACTION_ADD_POTATO)
			..add(ACTION_COLLECT);
	}

	@override
	void update({bool simulateTick: false}) {
		super.update();

		// Update appearance
		if (!collecting) {
			if (pending >= INPUT_PER_HOOCH) {
				setState('active');
			} else if (processed > 0) {
				setState('ready');
			} else {
				setState('empty');
			}
		}

		if (simulateTick && new DateTime.now().second % BREW_SECONDS == 0) {
			// Make hooch from grain every few ticks
			if (pending <= 0) {
				pending = 0;
			} else if (pending >= INPUT_PER_HOOCH) {
				// INPUT_PER_HOOCH input -> 1 output
				pending -= INPUT_PER_HOOCH;
				processed++;
			}
		}
	}

	@override
	Map<String, String> getPersistMetadata() => super.getPersistMetadata()
		..['pending'] = pending.toString()
		..['processed'] = processed.toString();

	@override
	void restoreState(Map<String, String> metadata) {
		super.restoreState(metadata);
		pending = int.parse((metadata['pending'] ?? 0).toString());
		processed = int.parse((metadata['processed'] ?? 0).toString());
	}

	@override
	Future<bool> pickUp({WebSocket userSocket, String email}) async {
		if (pending > 0) {
			toast('Wait for me to finish!', userSocket);
			return false;
		} else {
			return await super.pickUp(userSocket: userSocket, email: email);
		}
	}

	Future<bool> addHops(String itemType, String email, [int count = 1]) async {
		try {
			int taken = await InventoryV2.takeAnyItemsFromUser(email, itemType, count);
			pending += taken;
			return true;
		} catch (e) {
			Log.warning('Could not add <count=$count> <itemType=$itemType> from <email=$email> to still <entity=$id>', e);
			return false;
		}
	}

	Future<bool> addCorn({WebSocket userSocket, String email, int count: 1}) async => addHops(CORN, email, count);
	Future<bool> addGrain({WebSocket userSocket, String email, int count: 1}) async => addHops(GRAIN, email, count);
	Future<bool> addPotato({WebSocket userSocket, String email, int count: 1}) async => addHops(POTATO, email, count);

	Future<bool> collect({WebSocket userSocket, String email}) async {
		if (processed == 0) {
			toast("There's nothing to collect!", userSocket);
			return false;
		} else {
			setState('collect');
			collecting = true;

			await Future.doWhile(() async {
				await Future.wait([
					// Play the animation
					new Future.delayed(new Duration(seconds: 1)),

					// Give hooch to player
					InventoryV2.addItemToUser(email, HOOCH, 1, id)
				]);

				// Keep going as long as there is more to collect
				processed--;
				return (processed > 0);
			});

			// Done
			collecting = false;
			return true;
		}
	}
}
