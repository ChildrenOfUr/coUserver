part of street_entities;

class StreetEntityBalancer {
	/// How many of a certain type of entity are allowed on a single street
	static int getStreetMaxOfType(String type) {
		return ({
			"Piggy": 10,
			"Butterfly": 30
		})[type] ?? 20;
	}

	String tsid;
	List<String> nearbyTsids;

	// TODO: test this
	StreetEntityBalancer(String balanceTsid) {
		// Always use the L form of the TSID
		this.tsid = tsidL(balanceTsid);

		// Find street data
		Map<String, dynamic> street = getStreetByTsid(tsid);
		nearbyTsids = _getRestOfHub(street["hub_id"]);
	}

	Future balance() async {
		// Maps entity type to list of entities of that type on this street
		Map<String, List<StreetEntity>> entityData = new Map();
		(await StreetEntities.getEntities(tsid)).forEach((StreetEntity entity) {
			if (entityData[entity.type] == null) {
				entityData[entity.type] = new List();
			}

			entityData[entity.type].add(entity);
		});

		// Find overcrowded entity types
		await Future.forEach(entityData.keys, (String type) async {
			List<StreetEntity> entities = entityData[type];

			// Needs balancing
			while (entities.length > getStreetMaxOfType(type)) {
				StreetEntity toMove = entities.first;
				toMove.tsid = await _findBetterTsid(toMove);
				StreetEntities.setEntity(toMove);
				entities.remove(toMove);
			}
		});
	}

	Future<String> _findBetterTsid(StreetEntity entity) async {
		// Count entities on nearby streets
		Map<String, int> numEntities = new Map();
		for (String tsid in nearbyTsids) {
			// Only entities of this type
			int onNearby = (await StreetEntities.getEntities(tsid))
				.where((StreetEntity e) => entity.type == e.type).toList().length;

			numEntities[tsid] = onNearby;
		}

		// Find least crowded street
		String leastCrowdedTsid;
		int leastCrowdedAmt;

		numEntities.forEach((String tsid, int count) {
			if (leastCrowdedAmt == null || count < leastCrowdedAmt) {
				leastCrowdedTsid = tsid;
				leastCrowdedAmt = count;
			}
		});

		return leastCrowdedTsid;
	}

	List<String> _getRestOfHub(String hubId) {
		// Get all streets in this hub
		List<Map<String, dynamic>> allStreets = getStreetsInHub(hubId);

		// Remove this one, and those missing a TSID
		List<String> tsids = new List();
		for (Map<String, dynamic> street in allStreets) {
			if (street["tsid"] == null) {
				continue;
			}

			String testTsid = tsidL(street["tsid"]);
			if (testTsid == this.tsid) {
				tsids.add(testTsid);
			}
		}
		return tsids;
	}
}
