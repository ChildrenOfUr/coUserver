part of entity;

/// Used to convert items to street entities.
/// For example, stills and gnomes.
class EntityItem extends NPC {
	/// Maps item type to entity type
	static final Map<String, String> ITEM_ENTITIES = {
		'still': 'Still'
	};

	static Future<bool> place(String email, String itemType, String tsid) async {
		// Find entity type for this item type
		String type = ITEM_ENTITIES[itemType];

		// Save owner
		int userId = await User.getIdFromEmail(email);
		String metadata = JSON.encode({'ownerId': userId});

		// Find street and position
		Identifier player = PlayerUpdateHandler.users[await User.getUsernameFromEmail(email)];
		String id = createId(player.currentX, player.currentY, type, tsid);

		// Save to database and load into game
		StreetEntity entity = new StreetEntity.create(
			id: id, type: type, tsid: tsid, x: player.currentX, y: player.currentY,
			metadata_json: metadata);
		return await StreetEntities.setEntity(entity);
	}

	static final Action ACTION_PICKUP = new Action.withName('pick up');

	String itemType;
	int ownerId = -1; // TODO: fix where this sometimes gets persisted as null

	EntityItem(String id, int x, int y, String streetName) : super(id, x, y, streetName) {
		speed = 0;
		facingRight = true;
	}

	@override
	void update() {
		// Fall to platforms
		super.update();
		moveXY();
	}

	@override
	Future<List<Action>> customizeActions(String email) async {
		if (ownerId == -1 || await User.getIdFromEmail(email) == ownerId) {
			return new List.from(actions)
				..add(ACTION_PICKUP);
		} else {
			return actions;
		}
	}

	@override
	Map<String,String> getPersistMetadata() => super.getPersistMetadata()
		..['ownerId'] = ownerId.toString();

	@override
	void restoreState(Map<String, String> metadata) {
		super.restoreState(metadata);
		ownerId = int.parse((metadata['ownerId'] ?? -1).toString());
	}

	Future<bool> pickUp({WebSocket userSocket, String email}) async {
		if (email != await User.getEmailFromId(ownerId)) {
			toast("That's not yours!", userSocket);
			return false;
		}

		try {
			if (await InventoryV2.addItemToUser(email, itemType, 1) == 1) {
				return await StreetEntities.deleteEntity(await StreetEntities.getEntity(id));
			} else {
				return false;
			}
		} catch (e) {
			Log.warning('Could not pick up <ownerId=$ownerId> entity for item $itemType', e);
			return false;
		}
	}
}