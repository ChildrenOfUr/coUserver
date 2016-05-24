part of util;

class StreetEntity {
	StreetEntity({this.id, this.type, this.tsid, this.x: 0, this.y: 0}) {
		assert(id != null);
		assert(type != null);
		assert(tsid != null);
	}

	/// Unique ID across all streets
	@Field() String id;

	@Field() String type;

	/// Must start with L
	@Field() String tsid;

	@Field() int x, y;

	@override String toString() => "<Entity $id ($type) on $tsid at ($x, $y)>";
}

class StreetEntities {
	static Future<List<StreetEntity>> getEntities(String tsid) async {
		tsid = tsidL(tsid);

		PostgreSql dbConn = await dbManager.getConnection();

		try {
			String query = "SELECT * "
				"FROM street_entities "
				"WHERE tsid = @tsid";

			List<StreetEntity> rows = await dbConn.query(
				query, StreetEntity, {"tsid": tsid});

			return rows;
		} catch (e) {
			log("Could not get entities for $tsid: $e");
			return new List();
		} finally {
			dbManager.closeConnection(dbConn);
		}
	}

	static Future<bool> setEntity(StreetEntity entity) async {
		PostgreSql dbConn = await dbManager.getConnection();

		try {
			String query = "INSERT INTO street_entities (id, type, tsid, x, y) "
				"VALUES (@id, @type, @tsid, @x, @y) "
				"ON CONFLICT (id) DO UPDATE "
				"SET tsid = @tsid, x = @x, y = @y";

			int result = await dbConn.execute(
				query, encode(entity));

			return (result == 1);
		} catch (e) {
			log("Could not edit entity $entity: $e");
			return false;
		} finally {
			dbManager.closeConnection(dbConn);
		}
	}
}