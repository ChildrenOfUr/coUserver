part of entity;

@app.Group("/entities")
class EntityEndpoint {
	@app.Route("/list")
	List<Map<String, dynamic>> allEntities(@app.QueryParam("token") String token) {
		if (token != redstoneToken) {
			return [{"error": "true"}, {"token": "invalid"}];
		}

		if (cachedData == null) {
			List<Map<String, dynamic>> result = new List();
			entities.forEach((Type type) => result.add(aboutEntity(type.toString())));
			cachedData = result;
			return result;
		} else {
			return cachedData;
		}
	}

	static Map<String, dynamic> aboutEntity(dynamic entity) {
		if (entity is String) {
			try {
				entity = findByName(entity.trim());
			} catch(_) {
				return null;
			}
		}
		if (entity is! Entity) {
			return null;
		}

		ClassMirror mirror = findClassMirror(entity.runtimeType.toString());

		Map<String, dynamic> map = new Map()
			..["id"] = entity.runtimeType.toString()
			..["name"] = splitCamelCase(entity.runtimeType.toString())
			..["responses"] = entity.responses;

		if (entity.runtimeType == NPC) {
			map["name"] = entity.type;
		}

		if (mirror.isSubclassOf(findClassMirror("Vendor"))) {
			map
				..["category"] = "Vendor"
				..["sellItems"] = new List();
			if (entity.itemsPredefined) {
				entity.itemsForSale.forEach((Map item) => map["sellItems"].add(item["itemType"]));
			}
		}

		if (mirror.isSubclassOf(findClassMirror("Shrine"))) {
			map["category"] = "Shrine";
		}

		if (mirror.isSubclassOf(findClassMirror("Tree"))) {
			map["category"] = "Tree";
		} else if (mirror.isSubclassOf(findClassMirror("Rock"))) {
			map["category"] = "Rock";
		} else if (mirror.isSubclassOf(findClassMirror("Plant"))) {
			map["category"] = "Plant";
		}

		if (entity.states != null) {
			map
				..["currentState"] = entity.currentState.stateName
				..["states"] = new List();
			entity.states.values.forEach((Spritesheet state) => map["states"].add(state.toMap()));
		}

		return map;
	}

	/// This method is awful.
	static Entity findByName(String entityClassName) {
		ClassMirror mirror = findClassMirror(entityClassName);

		dynamic _construct(int attempt) {
			// Call the default constructor with attempt number of null values
			List args = new List.filled(attempt, null);
			return mirror
				.newInstance(new Symbol(""), args)
				.reflectee;
		}

		try {
			// Fake vendor constructors have 0 arguments
			return _construct(0);
		} catch(_) {
			try {
				// Most entity constructors have 4 arguments
				return _construct(4);
			} catch(_) {
				// Some entity constructors have 5 arguments
				return _construct(5);
			}
		}
	}

	static final List<Type> entities = [
		// NPCs
		Auctioneer, Crab, DustTrap, Mailbox, VisitingStone, Garden,
		// NPCs -> Animals
		Batterfly, Butterfly, Chicken, Firefly, Fox, HeliKitty, Piggy, Salmon, SilverFox,
		// NPCs -> Shrines
		Alph, AlphFirebog, AlphIx, AlphUralia,
		Cosma, CosmaFirebog, CosmaIx, CosmaUralia,
		Friendly, FriendlyFirebog, FriendlyIx, FriendlyUralia,
		Grendaline, GrendalineFirebog, GrendalineIx, GrendalineUralia,
		Humbaba, HumbabaFirebog, HumbabaIx, HumbabaUralia,
		Lem, LemFirebog, LemIx, LemUralia,
		Mab, MabFirebog, MabIx, MabUralia,
		Pot, PotFirebog, PotIx, PotUralia,
		Spriggan, SprigganFirebog, SprigganIx, SprigganUralia,
		Tii, TiiFirebog, TiiIx, TiiUralia,
		Zille, ZilleFirebog, ZilleIx, ZilleUralia,
		// NPCs -> Vendors
		Helga, UncleFriendly, MealVendor, SnoConeVendingMachine,
		StreetSpiritFirebog, StreetSpiritGroddle, StreetSpiritZutto,
		ToolVendor, GardeningGoodsVendor,
		AlchemicalVendor, AnimalVendor, GardeningVendor, GroceriesVendor,
		HardwareVendor, KitchenVendor, MiningVendor, ProduceVendor, ToyVendor,
		// Plants
		DirtPile, HellGrapes, IceNubbin, Jellisac, MortarBarnacle, PeatBog,
		// Plants -> Rocks
		BerylRock, DulliteRock, MetalRock, SparklyRock,
		// Plants -> Trees
		BeanTree, BubbleTree, EggPlant, FruitTree, GasPlant, PaperTree, SpicePlant, WoodTree
	];

	static List<Map<String, dynamic>> cachedData;
}

////These two methods are used by the map filler
////I will leave them commented out when not in use
@app.Route('/getEntities')
Future<Map<String, StreetEntity>> getEntities(@app.QueryParam('tsid') String tsid) async {
	return {"entities": encode(await StreetEntities.getEntities(tsid))};
}

class EntitySet {
	@Field() String tsid;
	@Field() List<StreetEntity> entities;
}

@app.Route('/setEntities', methods: const[app.POST])
Future<String> setEntities(@Decode() EntitySet entitySet) async {
	bool success = true;
	String error = '';

	if (entitySet.tsid == null) {
		return 'Error: You must provide a tsid';
	}

	//we need to know what entities are currently on the street
	//if there is one on the street that isn't in the list we get
	//here, then we need to remove it
	List<StreetEntity> existingEntities = await StreetEntities.getEntities(entitySet.tsid);

	await Future.forEach(entitySet.entities, (StreetEntity entity) async {
		try {
			if (entity.id == null) {
				entity.id = createId(entity.x, entity.y, entity.type, tsidL(entity.tsid));
			}
			await StreetEntities.setEntity(entity);
			existingEntities.removeWhere((StreetEntity ent) => ent.id == entity.id);
		} catch (e, st) {
			success = false;
			error = e.toString();
			Log.error('Could not save entity',e,st);
		}
	});

	//any entities remaining in existingEntities must have been deleted
	//from the map filler so we will remove them from the db
	List<String> idList = [];
	for (StreetEntity ent in existingEntities) {
		idList.add("'${ent.id}'");
	}

	if (idList.length > 0) {
		String ids = idList.toString().replaceAll('[','(').replaceAll(']',')');
		String query = 'DELETE FROM ${StreetEntities.TABLE} WHERE id IN $ids';
		await dbConn.execute(query);
	}

	if (success) {
		return 'OK';
	} else {
		return 'Error saving entities: $error';
	}
}
