part of util;

class StreetEntityRecord {
	@Field() String tsid;
	@Field() String json;
}

class StreetEntities {
	static final NO_ENTITIES = {"entities": []};

	static Future<Map<String, dynamic>> getEntities(String tsid) async {
		tsid = tsidL(tsid);

		PostgreSql dbConn = await dbManager.getConnection();

		try {
			String query = "SELECT json "
				"FROM street_entities "
				"WHERE tsid = @tsid";

			List<StreetEntityRecord> rows = await dbConn.query(
				query, StreetEntityRecord, {"tsid": tsid});

			return JSON.decode(rows.single.json);
		} catch (e) {
			log("Could not get entities for $tsid: $e");
			return NO_ENTITIES;
		} finally {
			dbManager.closeConnection(dbConn);
		}
	}

	static Future<bool> setEntities(String tsid, String json) async {
		tsid = tsidL(tsid);

		PostgreSql dbConn = await dbManager.getConnection();

		try {
			String query = "INSERT INTO street_entities (tsid, json) "
				"VALUES (@tsid, @json) "
				"ON CONFLICT (tsid) DO UPDATE "
				"SET json = @json";

			int result = await dbConn.execute(
				query, {"tsid": tsid, "json": json});

			return (result == 1);
		} catch (e) {
			log("Could not set entities for $tsid to $json: $e");
			return false;
		} finally {
			dbManager.closeConnection(dbConn);
		}
	}
}