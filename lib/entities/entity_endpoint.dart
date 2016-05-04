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

		if (mirror.isSubclassOf(findClassMirror("Vendor")) && entity.itemsPredefined) {
			map
				..["category"] = "Vendor"
				..["sellItems"] = new List();
			entity.itemsForSale.forEach((Map item) => map["sellItems"].add(item["itemType"]));
		}

		if (mirror.isSubclassOf(findClassMirror("Shrine"))) {
			map["category"] = "Shrine";
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
			// Most entity constructors have 4 arguments
			return _construct(4);
		} catch(_) {
			// Some entity constructors have 5 arguments
			return _construct(5);
		}
	}

	static final List<Type> entities = [
		// NPCs
		Auctioneer, Crab, DustTrap, Mailbox, VisitingStone,
		// NPCs -> Animals
		Batterfly, Butterfly, Chicken, Firefly, HeliKitty, Piggy, Salmon,
		// NPCs -> Shrines
		Alph, AlphFirebog, AlphIx, AlphUralia,
		Cosma, CosmaFirebog, CosmaIx, CosmaUralia,
		Friendly, FriendlyFirebog, FriendlyIx, FriendlyUralia,
		Grendaline, GrendalineFirebog, GrendalineIx, GrendalineUralia,
		Humbaba, HumbabaFirebog, HumbabaIx, HumbabaUralia,
		Lem, LemFirebog, LemIx, LemUralia,
		Mab, MabFirebog, MabIx, MabUralia,
		Pot, PotFirebog, PotIx, PotUralia,
		Shrine,
		Spriggan, SprigganFirebog, SprigganIx, SprigganUralia,
		Tii, TiiFirebog, TiiIx, TiiUralia,
		Zille, ZilleFirebog, ZilleIx, ZilleUralia,
		// NPCs -> Vendors
		Helga, UncleFriendly, MealVendor, SnoConeVendingMachine,
		StreetSpirit, StreetSpiritFirebog, StreetSpiritGroddle, StreetSpiritZutto,
		ToolVendor,
		// Plants
		DirtPile, HellGrapes, IceNubbin, Jellisac, MortarBarnacle, PeatBog,
		// Plants -> Rocks
		BerylRock, DulliteRock, MetalRock, SparklyRock,
		// Plants -> Trees
		BeanTree, BubbleTree, EggPlant, FruitTree, GasPlant, PaperTree, SpicePlant, WoodTree
	];

	static List<Map<String, dynamic>> cachedData;
}