part of street_entities;

class StreetEntityBalancer {
	/// Max of all entities where the max is unspecified
	static final int _DEFAULT_MAX = 20;

	/// Specific maxes for entity populations per street
	static final Map<String, int> _ENTITY_MAX = {
		"Piggy": 10,
		"Butterfly": 30
	};

	/// How many of a certain type of entity are allowed on a single street
	static int getMaxOfType(String type) {
		return _ENTITY_MAX[type] ?? _DEFAULT_MAX;
	}

	/// Whether a street is full of a certain type of entity
	static Future<bool> streetIsFull(String type, String tsid) async {
		// Get entities from database
		List<StreetEntity> entities = await StreetEntities.getEntities(tsid);

		// Count entities of this type
		int count = entities
			.where((StreetEntity entity) => entity.type == type)
			.toList().length;

		// Compare to max
		return (count >= getMaxOfType(type));
	}
}
