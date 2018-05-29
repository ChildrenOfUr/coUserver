part of entity;

class Icon extends EntityItem {
	static final Map<String, Spritesheet> SPRITESHEETS = {
		'Alph': new Spritesheet('Alph',
			'https://childrenofur.com/assets/entityImages/icon_alph__x1_1_png_1354836409.png',
			86, 103, 86, 103, 1, true),
		'Cosma': new Spritesheet('Cosma',
			'https://childrenofur.com/assets/entityImages/icon_cosma__x1_1_png_1354836412.png',
			94, 92, 94, 92, 1, true),
		'Friendly': new Spritesheet('Friendly',
			'https://childrenofur.com/assets/entityImages/icon_friendly__x1_1_png_1354836414.png',
			85, 87, 85, 87, 1, true),
		'Grendaline': new Spritesheet('Grendaline',
			'https://childrenofur.com/assets/entityImages/icon_grendaline__x1_1_png_1354836417.png',
			81, 96, 81, 96, 1, true),
		'Humbaba': new Spritesheet('Humbaba',
			'https://childrenofur.com/assets/entityImages/icon_humbaba__x1_1_png_1354836421.png',
			79, 93, 79, 93, 1, true),
		'Lem': new Spritesheet('Lem',
			'https://childrenofur.com/assets/entityImages/icon_lem__x1_1_png_1354836425.png',
			88, 93, 88, 93, 1, true),
		'Mab': new Spritesheet('Mab',
			'https://childrenofur.com/assets/entityImages/icon_mab__x1_1_png_1354836427.png',
			78, 95, 78, 95, 1, true),
		'Pot': new Spritesheet('Pot',
			'https://childrenofur.com/assets/entityImages/icon_pot__x1_1_png_1354836430.png',
			104, 89, 104, 89, 1, true),
		'Spriggan': new Spritesheet('Spriggan',
			'https://childrenofur.com/assets/entityImages/icon_spriggan__x1_1_png_1354836433.png',
			69, 94, 69, 94, 1, true),
		'Tii': new Spritesheet('Tii',
			'https://childrenofur.com/assets/entityImages/icon_tii__x1_1_png_1354836435.png',
			86, 77, 86, 77, 1, true),
		'Zille': new Spritesheet('Zille',
			'https://childrenofur.com/assets/entityImages/icon_zille__x1_1_png_1354836438.png',
			97, 90, 97, 90, 1, true),
	};

	static final int PRICE_OF_TITHE = 100;

	static final Action ACTION_TITHE = new Action.withName('tithe')
		..description = 'Insert $PRICE_OF_TITHE currants to support the Icon';

	static final Action ACTION_RUMINATE = new Action.withName('ruminate')
		..description = 'Soak up the happysauce emanating from the Icon'
		..timeRequired = 11000;

	static final Action ACTION_REVERE = new Action.withName('revere')
		..description = 'Let the Icon replenish you while you adore it'
		..timeRequired = 11000;

	static final Action ACTION_REFLECT = new Action.withName('reflect')
		..description = 'Dwell a while on the true meaning of the Icon'
		..timeRequired = 11000;

	static final int PRICE_OF_ACTION = 30;

	String username;
	String email;
	int currants = 0;

	Icon(String id, num x, num y, num z, num rotation, bool h_flip, String streetName)
	: super(id, x, y, z, rotation, h_flip, streetName) {
		states = SPRITESHEETS;
		actions = [];
		speed = 0;
		itemType = EntityItem.getItemForClass(this.runtimeType.toString());

		try {
			_init();
		} catch (e) {
			Log.warning('Could not load Icon <id=$id>', e);
		}
	}

	Future _init() async {
		// Fill in missing info
		username = await User.getUsernameFromId(ownerId);
		email = await User.getEmailFromId(ownerId);
	}

	@override
	Map<String,String> getPersistMetadata() => super.getPersistMetadata()
		..['currants'] = currants.toString();

	@override
	void restoreState(Map<String, String> metadata) {
		super.restoreState(metadata);
		currants = int.parse((metadata['currants'] ?? 0).toString());
	}

	@override
	Future<List<Action>> customizeActions(String email) async {
		List<Action> customActions = new List.from(await super.customizeActions(email));

		if (currants > PRICE_OF_ACTION) {
			customActions
				..add(ACTION_RUMINATE)
				..add(ACTION_REVERE)
				..add(ACTION_REFLECT);
		} else if ((await getMetabolics(email: email)).currants >= PRICE_OF_TITHE) {
			customActions.add(ACTION_TITHE);
		}

		return customActions;
	}

	Future<bool> tithe({WebSocket userSocket, String email}) async {
		MetabolicsChange mc = new MetabolicsChange();
		bool success = await mc.trySetMetabolics(email, currants: -PRICE_OF_TITHE);

		if (success) {
			currants += PRICE_OF_TITHE;
		}

		return success;
	}

	Future<bool> ruminate({WebSocket userSocket, String email}) async {
		MetabolicsChange mc = new MetabolicsChange();
		bool success = await mc.trySetMetabolics(email, mood: 50);

		if (success) {
			currants -= PRICE_OF_ACTION;
			say();
		}

		return success;
	}

	Future<bool> revere({WebSocket userSocket, String email}) async {
		MetabolicsChange mc = new MetabolicsChange();
		bool success = await mc.trySetMetabolics(email, energy: 50);

		if (success) {
			currants -= PRICE_OF_ACTION;
			say();
		}

		return success;
	}

	Future<bool> reflect({WebSocket userSocket, String email}) async {
		MetabolicsChange mc = new MetabolicsChange();
		bool success = await mc.trySetMetabolics(email, imgMin: 50);

		if (success) {
			currants -= PRICE_OF_ACTION;
			say();
		}

		return success;
	}
}

class Icon_Alph extends Icon {
	Icon_Alph(String id, num x, num y, num z, num rotation, bool h_flip, String streetName)
	: super(id, x, y, z, rotation, h_flip, streetName) {
		type = 'Icon of Alph';
		setState('Alph');
	}
}

class Icon_Cosma extends Icon {
	Icon_Cosma(String id, num x, num y, num z, num rotation, bool h_flip, String streetName)
	: super(id, x, y, z, rotation, h_flip, streetName) {
		type = 'Icon of Cosma';
		setState('Cosma');
	}
}

class Icon_Friendly extends Icon {
	Icon_Friendly(String id, num x, num y, num z, num rotation, bool h_flip, String streetName)
	: super(id, x, y, z, rotation, h_flip, streetName) {
		type = 'Icon of Friendly';
		setState('Friendly');
	}
}

class Icon_Grendaline extends Icon {
	Icon_Grendaline(String id, num x, num y, num z, num rotation, bool h_flip, String streetName)
	: super(id, x, y, z, rotation, h_flip, streetName) {
		type = 'Icon of Grendaline';
		setState('Grendaline');
	}
}

class Icon_Humbaba extends Icon {
	Icon_Humbaba(String id, num x, num y, num z, num rotation, bool h_flip, String streetName)
	: super(id, x, y, z, rotation, h_flip, streetName) {
		type = 'Icon of Humbaba';
		setState('Humbaba');
	}
}

class Icon_Lem extends Icon {
	Icon_Lem(String id, num x, num y, num z, num rotation, bool h_flip, String streetName)
	: super(id, x, y, z, rotation, h_flip, streetName) {
		type = 'Icon of Lem';
		setState('Lem');
	}
}

class Icon_Mab extends Icon {
	Icon_Mab(String id, num x, num y, num z, num rotation, bool h_flip, String streetName)
	: super(id, x, y, z, rotation, h_flip, streetName) {
		type = 'Icon of Mab';
		setState('Mab');
	}
}

class Icon_Pot extends Icon {
	Icon_Pot(String id, num x, num y, num z, num rotation, bool h_flip, String streetName)
	: super(id, x, y, z, rotation, h_flip, streetName) {
		type = 'Icon of Pot';
		setState('Pot');
	}
}

class Icon_Spriggan extends Icon {
	Icon_Spriggan(String id, num x, num y, num z, num rotation, bool h_flip, String streetName)
	: super(id, x, y, z, rotation, h_flip, streetName) {
		type = 'Icon of Spriggan';
		setState('Spriggan');
	}
}

class Icon_Tii extends Icon {
	Icon_Tii(String id, num x, num y, num z, num rotation, bool h_flip, String streetName)
	: super(id, x, y, z, rotation, h_flip, streetName) {
		type = 'Icon of Tii';
		setState('Tii');
	}
}

class Icon_Zille extends Icon {
	Icon_Zille(String id, num x, num y, num z, num rotation, bool h_flip, String streetName)
	: super(id, x, y, z, rotation, h_flip, streetName) {
		type = 'Icon of Zille';
		setState('Zille');
	}
}
