part of entity;

/// Used to convert items to street entities.
/// For example, stills and gnomes.
class EntityItem extends NPC {
	/// Maps item type to entity type
	static final Map<String, String> ITEM_ENTITIES = {
		'cubimal_batterfly': 'RacingCubimal_batterfly',
		'cubimal_bureaucrat': 'RacingCubimal_bureaucrat',
		'cubimal_butler': 'RacingCubimal_butler',
		'cubimal_butterfly': 'RacingCubimal_butterfly',
		'cubimal_cactus': 'RacingCubimal_cactus',
		'cubimal_chick': 'RacingCubimal_chick',
		'cubimal_crab': 'RacingCubimal_crab',
		'cubimal_craftybot': 'RacingCubimal_craftybot',
		'cubimal_deimaginator': 'RacingCubimal_deimaginator',
		'cubimal_dustbunny': 'RacingCubimal_dustbunny',
		'cubimal_emobear': 'RacingCubimal_emobear',
		'cubimal_factorydefect_chick': 'RacingCubimal_factorydefect_chick',
		'cubimal_firebogstreetspirit': 'RacingCubimal_firebogstreetspirit',
		'cubimal_firefly': 'RacingCubimal_firefly',
		'cubimal_fox': 'RacingCubimal_fox',
		'cubimal_foxranger': 'RacingCubimal_foxranger',
		'cubimal_frog': 'RacingCubimal_frog',
		'cubimal_gardeningtoolsvendor': 'RacingCubimal_gardeningtoolsvendor',
		'cubimal_gnome': 'RacingCubimal_gnome',
		'cubimal_greeterbot': 'RacingCubimal_greeterbot',
		'cubimal_groddlestreetspirit': 'RacingCubimal_groddlestreetspirit',
		'cubimal_gwendolyn': 'RacingCubimal_gwendolyn',
		'cubimal_helga': 'RacingCubimal_helga',
		'cubimal_hellbartender': 'RacingCubimal_hellbartender',
		'cubimal_ilmenskiejones': 'RacingCubimal_ilmenskiejones',
		'cubimal_juju': 'RacingCubimal_juju',
		'cubimal_magicrock': 'RacingCubimal_magicrock',
		'cubimal_maintenancebot': 'RacingCubimal_maintenancebot',
		'cubimal_mealvendor': 'RacingCubimal_mealvendor',
		'cubimal_phantom': 'RacingCubimal_phantom',
		'cubimal_piggy': 'RacingCubimal_piggy',
		'cubimal_rook': 'RacingCubimal_rook',
		'cubimal_rube': 'RacingCubimal_rube',
		'cubimal_scionofpurple': 'RacingCubimal_scionofpurple',
		'cubimal_senorfunpickle': 'RacingCubimal_senorfunpickle',
		'cubimal_sloth': 'RacingCubimal_sloth',
		'cubimal_smuggler': 'RacingCubimal_smuggler',
		'cubimal_snoconevendor': 'RacingCubimal_snoconevendor',
		'cubimal_squid': 'RacingCubimal_squid',
		'cubimal_toolvendor': 'RacingCubimal_toolvendor',
		'cubimal_trisor': 'RacingCubimal_trisor',
		'cubimal_unclefriendly': 'RacingCubimal_unclefriendly',
		'cubimal_uraliastreetspirit': 'RacingCubimal_uraliastreetspirit',
		'cubimal_yeti': 'RacingCubimal_yeti',
		'icon_of_alph': 'Icon_Alph',
		'icon_of_cosma': 'Icon_Cosma',
		'icon_of_friendly': 'Icon_Friendly',
		'icon_of_grendaline': 'Icon_Grendaline',
		'icon_of_humbaba': 'Icon_Humbaba',
		'icon_of_lem': 'Icon_Lem',
		'icon_of_mab': 'Icon_Mab',
		'icon_of_pot': 'Icon_Pot',
		'icon_of_spriggan': 'Icon_Spriggan',
		'icon_of_tii': 'Icon_Tii',
		'icon_of_zille': 'Icon_Zille',
		'still': 'Still',
	};

	static String getClassForItem(String itemType) => ITEM_ENTITIES[itemType];

	static String getItemForClass(String className) {
		try {
			return ITEM_ENTITIES.keys.singleWhere((String itemType) => ITEM_ENTITIES[itemType] == className);
		} catch (_) {
			return null;
		}
	}

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
	bool strictPickup = false;
	int ownerId = -1;

	EntityItem(String id, num x, num y, num z, num rotation, bool h_flip, String streetName) : super(id, x, y, z, rotation, h_flip, streetName) {
		speed = 0;
		facingRight = true;
	}

	@override
	void update({bool simulateTick: false}) {
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
		..['ownerId'] = ownerId.toString()
		..['itemType'] = itemType;

	@override
	void restoreState(Map<String, String> metadata) {
		super.restoreState(metadata);
		ownerId = int.parse((metadata['ownerId'] ?? -1).toString());
		itemType = metadata['itemType'] ?? itemType;
	}

	Future<bool> pickUp({WebSocket userSocket, String email}) async {
		if (email != await User.getEmailFromId(ownerId)) {
			toast("That's not yours!", userSocket);
			return false;
		}

		try {
			if (strictPickup) {
				// Delete from street, then add to inventory
				if (await StreetEntities.deleteEntity(id)) {
					return await InventoryV2.addItemToUser(email, itemType, 1) == 1;
				}
			} else {
				// Add to inventory, then delete from street
				if (await InventoryV2.addItemToUser(email, itemType, 1) == 1) {
					return await StreetEntities.deleteEntity(id);
				}
			}
			return false;
		} catch (e) {
			Log.warning('Could not pick up <ownerId=$ownerId> entity for item <itemType=$itemType>', e);
			return false;
		}
	}
}