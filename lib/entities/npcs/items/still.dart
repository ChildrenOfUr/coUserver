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

	static final String HOOCH = 'hooch';

	static final String GRAIN = 'grain';

	static final Action ACTION_ADD = new Action.withName('add grain')
		..itemRequirements = new ItemRequirements.set(all: {GRAIN: 1})
		..timeRequired = 2
		..multiEnabled = true
		..actionWord = 'hopping';

	static final Action ACTION_COLLECT = new Action.withName('collect')
		..timeRequired = 5
		..actionWord = 'collecting';

	int pending = 0;
	int processed = 0;

	bool collecting = false;

	Timer brewTimer;

	Still(String id, int x, int y, int z, String streetName) : super(id, x, y, z, streetName) {
		type = 'Still';
		itemType = 'still';
		states = SPRITESHEETS;
		setState('empty');

		actions
			..add(ACTION_ADD)
			..add(ACTION_COLLECT);

		brewTimer = new Timer.periodic(new Duration(minutes: 1), (_) {
			if (pending <= 0) {
				pending = 0;
				brewTimer.cancel();
				return;
			}

			pending--;
			processed++;
		});
	}

	@override
	void update() {
		super.update();

		if (collecting) {
			setState('collect');
		} else if (pending > 0) {
			setState('active');
		} else if (processed > 0) {
			setState('ready');
		} else {
			setState('empty');
		}
	}

	@override
	Map<String,String> getPersistMetadata() {
		brewTimer.cancel();

		return super.getPersistMetadata()
			..['pending'] = pending.toString()
			..['processed'] = processed.toString();
	}

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

	Future<bool> addGrain({WebSocket userSocket, String email, int count: 1}) async {
		try {
			int taken = await InventoryV2.takeAnyItemsFromUser(email, GRAIN, count);
			pending += taken;
			return true;
		} catch (e) {
			Log.warning('Could not add <count=$count> grain from <email=$email> to <entity=$id>', e);
			return false;
		}
	}

	Future<bool> collect({WebSocket userSocket, String email}) async {
		if (processed == 0) {
			toast("There's nothing to collect!", userSocket);
			return false;
		} else {
			collecting = true;

			while (processed > 0) {
				int collected = await InventoryV2.addItemToUser(email, HOOCH, 1, id);

				if (collected == 0) {
					break;
				} else {
					processed--;
					await new Future.delayed(new Duration(seconds: 1));
				}
			}

			return true;
		}
	}
}