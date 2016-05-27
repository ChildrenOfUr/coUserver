part of item;

abstract class BabyAnimals {
	static Future<bool> spawn(String type, String tsid, int pX, int pY) async {
		// Check for overcrowding
		if (await StreetEntityBalancer.streetIsFull(type, tsid)) {
			return false;
		}

		// Instantiate a new entity
		StreetEntity newEntity = new StreetEntity.create(
			id: "fed_${rand.nextInt(9999)}",
			type: type,
			tsid: tsid,
			x: pX,
			y: pY
		);

		if (!(await StreetEntities.setEntity(newEntity))) {
			// Spawn failed
			return false;
		}

		// Spawn succeeded
		// TODO: load onto street
		return true;
	}

	static Future<bool> feed(int slot, int subSlot) async {
		return false;
	}
}
