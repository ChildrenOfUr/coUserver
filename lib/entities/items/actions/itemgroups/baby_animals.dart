part of item;

abstract class BabyAnimals {
	static final Map<String, String> ANIMAL_TYPES = {
		"caterpillar": "Butterfly",
		"chick": "Chicken",
		"piglet": "Piggy"
	};

	/// Keep track of who is feeding/spawning which entities between feed1() and feed2()
	static Map<String, Map<String, dynamic>> userActionCache = new Map();

	static Future<bool> spawn(String type, String tsid, int pX, int pY, String email) async {
		// Check for overcrowding
		if (await StreetEntityBalancer.streetIsFull(type, tsid)) {
			return false;
		}

		// Instantiate a new entity
		String username;
		try {
			String _username = await User.getUsernameFromEmail(email);
			assert(_username != null);
			username = _username;
		} catch (_) {
			username = null;
		}

		StreetEntity newEntity = new StreetEntity.create(
			id: createId(pX, pY, type, tsid),
			type: type,
			tsid: tsidL(tsid),
			x: pX,
			y: pY,
			username: username
		);

		if (!(await StreetEntities.setEntity(newEntity))) {
			// Spawn failed
			return false;
		}

		// Spawn succeeded
		return true;
	}

	Future<bool> feed({Map map, WebSocket userSocket, String email, String streetName, String username}) async {
		InventoryV2 inv = await getInventory(email);
		Item itemInSlot = await inv.getItemInSlot(map['slot'], map['subSlot'], email);

		String tsid = MapData.streets[streetName]["tsid"];
		String entityType = ANIMAL_TYPES[itemInSlot.itemType];
		if (tsid == null || (await StreetEntityBalancer.streetIsFull(entityType, tsid))) {
			toast("Isn't this street a little crowded?", userSocket);
			return false;
		}

		userSocket.add(JSON.encode({
			'id': 'global_action_monster',
			'openWindow': 'itemChooser',
			'action': 'feed2',
			'windowTitle': 'Feed ${itemInSlot.name} what?',
			'filter': 'category=Croppery & Gardening Supplies|||itemType=^(?!.+(?:_seed|_bean)).+\$'
		}));

		userActionCache[email] = {
			'type': itemInSlot.itemType,
			'slot': map['slot'],
			'subSlot': map['subSlot']
		};

		return true;
	}

	static Future<bool> feed2(
		{WebSocket userSocket, String email, String itemType, int count, int slot, int subSlot})
	async {
		Map<String, dynamic> _uncache() => userActionCache.remove(email);

		Map<String, dynamic> feedCache = userActionCache[email];

		if (feedCache == null) {
			// Something went wrong on the client
			_uncache();
			return false;
		}

		if ((await InventoryV2.takeAnyItemsFromUser(email, itemType, count)) == null) {
			// Could not take item
			_uncache();
			return false;
		}

		String animalItemType = feedCache['type'];
		String entityType = ANIMAL_TYPES[animalItemType];

		/* Min chance of spawn is 1 in 10 for 1 item,
			and max is 1 in 2 for 10 items */
		if (rand.nextInt((11 - count).clamp(2, 10)) == 0) {
			// Spawn entity
			try {
				Identifier player = PlayerUpdateHandler.users[await User.getUsernameFromEmail(email)];

				if ((await InventoryV2.takeItemFromUser(email, feedCache['slot'], feedCache['subSlot'], 1)) == null) {
					// Could not take baby animal
					_uncache();
					return false;
				}

				if (!(await spawn(entityType, player.tsid, player.currentX, player.currentY, email))) {
					// Spawn failed
					_uncache();
					return false;
				}

				toast('A $entityType appeared!', userSocket);
				_uncache();
				return true;
			} catch (e, st) {
				Log.error('Error spawning entity', e, st);
				_uncache();
				return false;
			}
		} else {
			toast('The ${items[animalItemType].name} thanks you for'
				' that ${items[itemType].name}', userSocket);
			_uncache();
			return false;
		}
	}
}
