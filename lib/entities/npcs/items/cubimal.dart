part of entity;

class RacingCubimal extends EntityItem {
	static final Map<String, Spritesheet> SPRITESHEETS = {
		'race_batterfly': new Spritesheet('race',
			'http://childrenofur.com/assets/entityImages/npc_cubimal_batterfly__x1_race_png_1354836243.png',
			720, 117, 36, 39, 60, true),
		'race_bureaucrat': new Spritesheet('race',
			'http://childrenofur.com/assets/entityImages/npc_cubimal_bureaucrat__x1_race_png_1354836246.png',
			720, 81, 36, 27, 60, true),
		'race_butler': new Spritesheet('race',
			'http://childrenofur.com/assets/entityImages/npc_cubimal_butler__x1_race_png_1354839843.png',
			720, 78, 36, 26, 60, true),
		'race_butterfly': new Spritesheet('race',
			'http://childrenofur.com/assets/entityImages/npc_cubimal_butterfly__x1_race_png_1354836249.png',
			760, 108, 38, 36, 60, true),
		'race_cactus': new Spritesheet('race',
			'http://childrenofur.com/assets/entityImages/npc_cubimal_cactus__x1_race_png_1354836252.png',
			720, 78, 36, 26, 60, true),
		'race_chick': new Spritesheet('race',
			'http://childrenofur.com/assets/entityImages/npc_cubimal_chick__x1_race_png_1354836255.png',
			720, 96, 36, 32, 60, true),
		'race_crab': new Spritesheet('race',
			'http://childrenofur.com/assets/entityImages/npc_cubimal_crab__x1_race_png_1354836258.png',
			760, 93, 38, 31, 60, true),
		'race_craftybot': new Spritesheet('race',
			'http://childrenofur.com/assets/entityImages/npc_cubimal_craftybot__x1_race_png_1354839845.png',
			720, 78, 36, 26, 60, true),
		'race_deimaginator': new Spritesheet('race',
			'http://childrenofur.com/assets/entityImages/npc_cubimal_deimaginator__x1_race_png_1354836263.png',
			720, 87, 36, 29, 60, true),
		'race_dustbunny': new Spritesheet('race',
			'http://childrenofur.com/assets/entityImages/npc_cubimal_dustbunny__x1_race_png_1354836266.png',
			740, 72, 37, 24, 60, true),
		'race_emobear': new Spritesheet('race',
			'http://childrenofur.com/assets/entityImages/npc_cubimal_emobear__x1_race_png_1354839825.png',
			780, 84, 39, 28, 60, true),
		'race_factorydefect_chick': new Spritesheet('race',
			'http://childrenofur.com/assets/entityImages/npc_cubimal_factorydefect_chick__x1_race_png_1354840105.png',
			780, 132, 52, 33, 59, true),
		'race_firebogstreetspirit': new Spritesheet('race',
			'http://childrenofur.com/assets/entityImages/npc_cubimal_firebogstreetspirit__x1_race_png_1354839837.png',
			740, 87, 37, 29, 60, true),
		'race_firefly': new Spritesheet('race',
			'http://childrenofur.com/assets/entityImages/npc_cubimal_firefly__x1_race_png_1354836269.png',
			720, 108, 36, 36, 60, true),
		'race_fox': new Spritesheet('race',
			'http://childrenofur.com/assets/entityImages/npc_cubimal_fox__x1_race_png_1354839818.png',
			740, 84, 37, 28, 60, true),
		'race_foxranger': new Spritesheet('race',
			'http://childrenofur.com/assets/entityImages/npc_cubimal_foxranger__x1_race_png_1354839827.png',
			720, 78, 36, 26, 60, true),
		'race_frog': new Spritesheet('race',
			'http://childrenofur.com/assets/entityImages/npc_cubimal_frog__x1_race_png_1354836277.png',
			760, 93, 38, 31, 60, true),
		'race_gardeningtoolsvendor': new Spritesheet('race',
			'http://childrenofur.com/assets/entityImages/npc_cubimal_gardeningtoolsvendor__x1_race_png_1354839863.png',
			760, 96, 38, 32, 60, true),
		'race_gnome': new Spritesheet('race',
			'http://childrenofur.com/assets/entityImages/npc_cubimal_gnome__x1_race_png_1354839840.png',
			760, 93, 38, 31, 60, true),
		'race_greeterbot': new Spritesheet('race',
			'http://childrenofur.com/assets/entityImages/npc_cubimal_greeterbot__x1_race_png_1354836279.png',
			720, 84, 36, 28, 60, true),
		'race_groddlestreetspirit': new Spritesheet('race',
			'http://childrenofur.com/assets/entityImages/npc_cubimal_groddlestreetspirit__x1_race_png_1354839830.png',
			780, 99, 39, 33, 60, true),
		'race_gwendolyn': new Spritesheet('race',
			'http://childrenofur.com/assets/entityImages/npc_cubimal_gwendolyn__x1_race_png_1354836282.png',
			720, 78, 36, 26, 60, true),
		'race_helga': new Spritesheet('race',
			'http://childrenofur.com/assets/entityImages/npc_cubimal_helga__x1_race_png_1354836288.png',
			740, 90, 37, 30, 60, true),
		'race_hellbartender': new Spritesheet('race',
			'http://childrenofur.com/assets/entityImages/npc_cubimal_hellbartender__x1_race_png_1354839855.png',
			780, 144, 39, 48, 60, true),
		'race_ilmenskiejones': new Spritesheet('race',
			'http://childrenofur.com/assets/entityImages/npc_cubimal_ilmenskiejones__x1_race_png_1354839851.png',
			740, 90, 37, 30, 60, true),
		'race_juju': new Spritesheet('race',
			'http://childrenofur.com/assets/entityImages/npc_cubimal_juju__x1_race_png_1354836285.png',
			720, 81, 36, 27, 60, true),
		'race_magicrock': new Spritesheet('race',
			'http://childrenofur.com/assets/entityImages/npc_cubimal_magicrock__x1_race_png_1354836290.png',
			720, 72, 36, 24, 60, true),
		'race_maintenancebot': new Spritesheet('race',
			'http://childrenofur.com/assets/entityImages/npc_cubimal_maintenancebot__x1_race_png_1354839966.png',
			720, 84, 36, 28, 60, true),
		'race_mealvendor': new Spritesheet('race',
			'http://childrenofur.com/assets/entityImages/npc_cubimal_mealvendor__x1_race_png_1354839861.png',
			760, 87, 38, 29, 60, true),
		'race_phantom': new Spritesheet('race',
			'http://childrenofur.com/assets/entityImages/npc_cubimal_phantom__x1_race_png_1354839848.png',
			720, 99, 36, 33, 60, true),
		'race_piggy': new Spritesheet('race',
			'http://childrenofur.com/assets/entityImages/npc_cubimal_piggy__x1_race_png_1354836293.png',
			740, 84, 37, 28, 60, true),
		'race_rook': new Spritesheet('race',
			'http://childrenofur.com/assets/entityImages/npc_cubimal_rook__x1_race_png_1354836296.png',
			800, 87, 40, 29, 60, true),
		'race_rube': new Spritesheet('race',
			'http://childrenofur.com/assets/entityImages/npc_cubimal_rube__x1_race_png_1354836298.png',
			760, 78, 38, 26, 60, true),
		'race_scionofpurple': new Spritesheet('race',
			'http://childrenofur.com/assets/entityImages/npc_cubimal_scionofpurple__x1_race_png_1354839874.png',
			780, 105, 39, 35, 60, true),
		'race_senorfunpickle': new Spritesheet('race',
			'http://childrenofur.com/assets/entityImages/npc_cubimal_senorfunpickle__x1_race_png_1354839878.png',
			860, 99, 43, 33, 60, true),
		'race_sloth': new Spritesheet('race',
			'http://childrenofur.com/assets/entityImages/npc_cubimal_sloth__x1_race_png_1354839821.png',
			720, 90, 36, 30, 60, true),
		'race_smuggler': new Spritesheet('race',
			'http://childrenofur.com/assets/entityImages/npc_cubimal_smuggler__x1_race_png_1354836301.png',
			740, 78, 37, 26, 60, true),
		'race_snoconevendor': new Spritesheet('race',
			'http://childrenofur.com/assets/entityImages/npc_cubimal_snoconevendor__x1_race_png_1354836305.png',
			720, 84, 36, 28, 60, true),
		'race_squid': new Spritesheet('race',
			'http://childrenofur.com/assets/entityImages/npc_cubimal_squid__x1_race_png_1354836309.png',
			760, 81, 38, 27, 60, true),
		'race_toolvendor': new Spritesheet('race',
			'http://childrenofur.com/assets/entityImages/npc_cubimal_toolvendor__x1_race_png_1354839858.png',
			720, 87, 36, 29, 60, true),
		'race_trisor': new Spritesheet('race',
			'http://childrenofur.com/assets/entityImages/npc_cubimal_trisor__x1_race_png_1354839871.png',
			720, 72, 36, 24, 60, true),
		'race_unclefriendly': new Spritesheet('race',
			'http://childrenofur.com/assets/entityImages/npc_cubimal_unclefriendly__x1_race_png_1354836312.png',
			740, 93, 37, 31, 60, true),
		'race_uraliastreetspirit': new Spritesheet('race',
			'http://childrenofur.com/assets/entityImages/npc_cubimal_uraliastreetspirit__x1_race_png_1354839833.png',
			780, 90, 39, 30, 60, true),
		'race_yeti': new Spritesheet('race',
			'http://childrenofur.com/assets/entityImages/npc_cubimal_yeti__x1_race_png_1354836351.png',
			760, 90, 38, 30, 60, true)
	};

	String username;
	String email;
	String itemType;

	RacingCubimal(String id, int x, int y, int z, String streetName) : super(id, x, y, z, streetName) {
		type = 'Cubimal';
		states = SPRITESHEETS;
		actions = [];
		speed = 0;

		try {
			_init();
		} catch (e, st) {
			Log.error('Could not race cubimal $id', e, st);
		}
	}

	Future _init() async {
		// Fill in missing info
		username = await User.getUsernameFromId(ownerId);
		email = await User.getEmailFromId(ownerId);

		// Race
		String result = await race();

		// Notify everyone
		StreetUpdateHandler.streets[streetName].occupants.values.forEach((WebSocket userSocket) {
			toast(result, userSocket);
		});

		// Return item
		InventoryV2.addItemToUser(email, itemType, 1);
	}

	@override
	Map<String,String> getPersistMetadata() => super.getPersistMetadata()
		..['itemType'] = itemType;

	@override
	void restoreState(Map<String, String> metadata) {
		super.restoreState(metadata);
		itemType = metadata['itemType'];
	}

	Future<String> race() async {
		// How far to go, from 00.01 to 99.99 planks
		int max = (rand.nextBool() ? 100 : 50);
		num distance = double.parse('${rand.nextInt(max)}.${rand.nextInt(99) + 1}');

		// Sit for 1 second
		speed = 0;
		await new Future.delayed(new Duration(seconds: 1));

		// Move at 5 planks per second
		speed = rand.nextInt(70) + 15;
		await new Future.delayed(new Duration(seconds: distance ~/ 5));

		// Stop and sit for 1 second
		speed = 0;
		await new Future.delayed(new Duration(seconds: 1));

		// Disappear
		await StreetEntities.deleteEntity(id);

		return "$username's $type travelled $distance planks before stopping";
	}
}

class RacingCubimal_batterfly extends RacingCubimal {
	RacingCubimal_batterfly(String id, int x, int y, int z, String streetName) : super (id, x, y, z, streetName) {
		type = 'Batterfly Cubimal';
		setState('race_batterfly');
	}
}

class RacingCubimal_bureaucrat extends RacingCubimal {
	RacingCubimal_bureaucrat(String id, int x, int y, int z, String streetName) : super (id, x, y, z, streetName) {
		type = 'Bureaucrat Cubimal';
		setState('race_bureaucrat');
	}
}

class RacingCubimal_butler extends RacingCubimal {
	RacingCubimal_butler(String id, int x, int y, int z, String streetName) : super (id, x, y, z, streetName) {
		type = 'Butler Cubimal';
		setState('race_butler');
	}
}

class RacingCubimal_butterfly extends RacingCubimal {
	RacingCubimal_butterfly(String id, int x, int y, int z, String streetName) : super (id, x, y, z, streetName) {
		type = 'Butterfly Cubimal';
		setState('race_butterfly');
	}
}

class RacingCubimal_cactus extends RacingCubimal {
	RacingCubimal_cactus(String id, int x, int y, int z, String streetName) : super (id, x, y, z, streetName) {
		type = 'Cactus Cubimal';
		setState('race_cactus');
	}
}

class RacingCubimal_chick extends RacingCubimal {
	RacingCubimal_chick(String id, int x, int y, int z, String streetName) : super (id, x, y, z, streetName) {
		type = 'Chick Cubimal';
		setState('race_chick');
	}
}

class RacingCubimal_crab extends RacingCubimal {
	RacingCubimal_crab(String id, int x, int y, int z, String streetName) : super (id, x, y, z, streetName) {
		type = 'Crab Cubimal';
		setState('race_crab');
	}
}

class RacingCubimal_craftybot extends RacingCubimal {
	RacingCubimal_craftybot(String id, int x, int y, int z, String streetName) : super (id, x, y, z, streetName) {
		type = 'Craftybot Cubimal';
		setState('race_craftybot');
	}
}

class RacingCubimal_deimaginator extends RacingCubimal {
	RacingCubimal_deimaginator(String id, int x, int y, int z, String streetName) : super (id, x, y, z, streetName) {
		type = 'Deimaginator Cubimal';
		setState('race_deimaginator');
	}
}

class RacingCubimal_dustbunny extends RacingCubimal {
	RacingCubimal_dustbunny(String id, int x, int y, int z, String streetName) : super (id, x, y, z, streetName) {
		type = 'Dustbunny Cubimal';
		setState('race_dustbunny');
	}
}

class RacingCubimal_emobear extends RacingCubimal {
	RacingCubimal_emobear(String id, int x, int y, int z, String streetName) : super (id, x, y, z, streetName) {
		type = 'Emobear Cubimal';
		setState('race_emobear');
	}
}

class RacingCubimal_factorydefect_chick extends RacingCubimal {
	RacingCubimal_factorydefect_chick(String id, int x, int y, int z, String streetName) : super (id, x, y, z, streetName) {
		type = 'Factory Defect Chick Cubimal';
		setState('race_factorydefect_chick');
	}

	@override
	Future<String> race() async {
		// How far to go, from 00.01 to 49.99 planks
		num distance = double.parse('${rand.nextInt(50)}.${rand.nextInt(99) + 1}');

		// Sit for 2 seconds
		speed = 0;
		await new Future.delayed(new Duration(seconds: 2));

		// Move at -10 planks per second
		speed = -(rand.nextInt(100) + 10);
		await new Future.delayed(new Duration(seconds: distance ~/ 10));

		// Stop and sit for 1 second
		speed = 0;
		await new Future.delayed(new Duration(seconds: 1));

		// Disappear
		await StreetEntities.deleteEntity(id);

		return "$username's $type travelled -$distance planks, and broke";
	}
}

class RacingCubimal_firebogstreetspirit extends RacingCubimal {
	RacingCubimal_firebogstreetspirit(String id, int x, int y, int z, String streetName) : super (id, x, y, z, streetName) {
		type = 'Firebog Street Spirit Cubimal';
		setState('race_firebogstreetspirit');
	}
}

class RacingCubimal_firefly extends RacingCubimal {
	RacingCubimal_firefly(String id, int x, int y, int z, String streetName) : super (id, x, y, z, streetName) {
		type = 'Firefly Cubimal';
		setState('race_firefly');
	}
}

class RacingCubimal_fox extends RacingCubimal {
	RacingCubimal_fox(String id, int x, int y, int z, String streetName) : super (id, x, y, z, streetName) {
		type = 'Fox Cubimal';
		setState('race_fox');
	}
}

class RacingCubimal_foxranger extends RacingCubimal {
	RacingCubimal_foxranger(String id, int x, int y, int z, String streetName) : super (id, x, y, z, streetName) {
		type = 'Fox Ranger Cubimal';
		setState('race_foxranger');
	}
}

class RacingCubimal_frog extends RacingCubimal {
	RacingCubimal_frog(String id, int x, int y, int z, String streetName) : super (id, x, y, z, streetName) {
		type = 'Frog Cubimal';
		setState('race_frog');
	}
}

class RacingCubimal_gardeningtoolsvendor extends RacingCubimal {
	RacingCubimal_gardeningtoolsvendor(String id, int x, int y, int z, String streetName) : super (id, x, y, z, streetName) {
		type = 'Gardening Tools Vendor Cubimal';
		setState('race_gardeningtoolsvendor');
	}
}

class RacingCubimal_gnome extends RacingCubimal {
	RacingCubimal_gnome(String id, int x, int y, int z, String streetName) : super (id, x, y, z, streetName) {
		type = 'Gnome Cubimal';
		setState('race_gnome');
	}
}

class RacingCubimal_greeterbot extends RacingCubimal {
	RacingCubimal_greeterbot(String id, int x, int y, int z, String streetName) : super (id, x, y, z, streetName) {
		type = 'Greeterbot Cubimal';
		setState('race_greeterbot');
	}
}

class RacingCubimal_groddlestreetspirit extends RacingCubimal {
	RacingCubimal_groddlestreetspirit(String id, int x, int y, int z, String streetName) : super (id, x, y, z, streetName) {
		type = 'Groddle Street Spirit Cubimal';
		setState('race_groddlestreetspirit');
	}
}

class RacingCubimal_gwendolyn extends RacingCubimal {
	RacingCubimal_gwendolyn(String id, int x, int y, int z, String streetName) : super (id, x, y, z, streetName) {
		type = 'Gwendolyn Cubimal';
		setState('race_gwendolyn');
	}
}

class RacingCubimal_helga extends RacingCubimal {
	RacingCubimal_helga(String id, int x, int y, int z, String streetName) : super (id, x, y, z, streetName) {
		type = 'Helga Cubimal';
		setState('race_helga');
	}
}

class RacingCubimal_hellbartender extends RacingCubimal {
	RacingCubimal_hellbartender(String id, int x, int y, int z, String streetName) : super (id, x, y, z, streetName) {
		type = 'Hell Bartender Cubimal';
		setState('race_hellbartender');
	}
}

class RacingCubimal_ilmenskiejones extends RacingCubimal {
	RacingCubimal_ilmenskiejones(String id, int x, int y, int z, String streetName) : super (id, x, y, z, streetName) {
		type = 'Ilmenskie Jones Cubimal';
		setState('race_ilmenskiejones');
	}
}

class RacingCubimal_juju extends RacingCubimal {
	RacingCubimal_juju(String id, int x, int y, int z, String streetName) : super (id, x, y, z, streetName) {
		type = 'Juju Cubimal';
		setState('race_juju');
	}
}

class RacingCubimal_magicrock extends RacingCubimal {
	RacingCubimal_magicrock(String id, int x, int y, int z, String streetName) : super (id, x, y, z, streetName) {
		type = 'Magic Rock Cubimal';
		setState('race_magicrock');
	}
}

class RacingCubimal_maintenancebot extends RacingCubimal {
	RacingCubimal_maintenancebot(String id, int x, int y, int z, String streetName) : super (id, x, y, z, streetName) {
		type = 'Maintenance Bot Cubimal';
		setState('race_maintenancebot');
	}
}

class RacingCubimal_mealvendor extends RacingCubimal {
	RacingCubimal_mealvendor(String id, int x, int y, int z, String streetName) : super (id, x, y, z, streetName) {
		type = 'Meal Vendor Cubimal';
		setState('race_mealvendor');
	}
}

class RacingCubimal_phantom extends RacingCubimal {
	RacingCubimal_phantom(String id, int x, int y, int z, String streetName) : super (id, x, y, z, streetName) {
		type = 'Phantom Cubimal';
		setState('race_phantom');
	}
}

class RacingCubimal_piggy extends RacingCubimal {
	RacingCubimal_piggy(String id, int x, int y, int z, String streetName) : super (id, x, y, z, streetName) {
		type = 'Piggy Cubimal';
		setState('race_piggy');
	}
}

class RacingCubimal_rook extends RacingCubimal {
	RacingCubimal_rook(String id, int x, int y, int z, String streetName) : super (id, x, y, z, streetName) {
		type = 'Rook Cubimal';
		setState('race_rook');
	}
}

class RacingCubimal_rube extends RacingCubimal {
	RacingCubimal_rube(String id, int x, int y, int z, String streetName) : super (id, x, y, z, streetName) {
		type = 'Rube Cubimal';
		setState('race_rube');
	}
}

class RacingCubimal_scionofpurple extends RacingCubimal {
	RacingCubimal_scionofpurple(String id, int x, int y, int z, String streetName) : super (id, x, y, z, streetName) {
		type = 'Scionofpurple Cubimal';
		setState('race_scionofpurple');
	}
}

class RacingCubimal_senorfunpickle extends RacingCubimal {
	RacingCubimal_senorfunpickle(String id, int x, int y, int z, String streetName) : super (id, x, y, z, streetName) {
		type = 'Señor Funpickle Cubimal';
		setState('race_senorfunpickle');
	}
}

class RacingCubimal_sloth extends RacingCubimal {
	RacingCubimal_sloth(String id, int x, int y, int z, String streetName) : super (id, x, y, z, streetName) {
		type = 'Sloth Cubimal';
		setState('race_sloth');
	}
}

class RacingCubimal_smuggler extends RacingCubimal {
	RacingCubimal_smuggler(String id, int x, int y, int z, String streetName) : super (id, x, y, z, streetName) {
		type = 'Smuggler Cubimal';
		setState('race_smuggler');
	}
}

class RacingCubimal_snoconevendor extends RacingCubimal {
	RacingCubimal_snoconevendor(String id, int x, int y, int z, String streetName) : super (id, x, y, z, streetName) {
		type = 'Sno Cone Vendor Cubimal';
		setState('race_snoconevendor');
	}
}

class RacingCubimal_squid extends RacingCubimal {
	RacingCubimal_squid(String id, int x, int y, int z, String streetName) : super (id, x, y, z, streetName) {
		type = 'Squid Cubimal';
		setState('race_squid');
	}
}

class RacingCubimal_toolvendor extends RacingCubimal {
	RacingCubimal_toolvendor(String id, int x, int y, int z, String streetName) : super (id, x, y, z, streetName) {
		type = 'Tool Vendor Cubimal';
		setState('race_toolvendor');
	}
}

class RacingCubimal_trisor extends RacingCubimal {
	RacingCubimal_trisor(String id, int x, int y, int z, String streetName) : super (id, x, y, z, streetName) {
		type = 'Trisor Cubimal';
		setState('race_trisor');
	}
}

class RacingCubimal_unclefriendly extends RacingCubimal {
	RacingCubimal_unclefriendly(String id, int x, int y, int z, String streetName) : super (id, x, y, z, streetName) {
		type = 'Uncle Friendly Cubimal';
		setState('race_unclefriendly');
	}
}

class RacingCubimal_uraliastreetspirit extends RacingCubimal {
	RacingCubimal_uraliastreetspirit(String id, int x, int y, int z, String streetName) : super (id, x, y, z, streetName) {
		type = 'Uralia Street Spirit Cubimal';
		setState('race_uraliastreetspirit');
	}
}

class RacingCubimal_yeti extends RacingCubimal {
	RacingCubimal_yeti(String id, int x, int y, int z, String streetName) : super (id, x, y, z, streetName) {
		type = 'Yeti Cubimal';
		setState('race_yeti');
	}
}