part of street;

class DBStreetInstance extends DBStreet {
	@Field() int uid;
	@Field() String tsid;

	DBStreetInstance({this.tsid, this.uid}) {
		id = '${tsidL(tsid)}.$uid';
	}

	@override
	String toString() {
		return "DBStreetInstance <id=$id> <uid=$uid> <tsid=$tsid> <grounditems=${groundItems.length}>";
	}
}

class StreetInstance extends Street {
	static final String TABLE = 'streets';

	/// Instance a street for a user.
	/// Returns null if the database edit fails.
	/// If an instance already exists, it will be returned instead
	static Future<StreetInstance> create(String tsid, int uid) async {
		StreetInstance instance = new StreetInstance(tsid: tsid, uid: uid);
		if (await instance.save()) {
			return instance;
		} else {
			return null;
		}
	}

	DBStreetInstance database;

	StreetInstance({String tsid, int uid}) : super(MapData.getStreetByTsid(tsid)['label'] ?? "$uid's $tsid", tsid) {
		database = new DBStreetInstance(tsid: tsid, uid: uid);

		// Load instance-specific entities
		loadEntities(database.id);
	}

	/// Save the state to the database.
	/// Returns database edit success as true/false.
	Future<bool> save() async {
		PostgreSql dbConn = await dbManager.getConnection();
		try {
			String query = 'INSERT INTO $TABLE (id, tsid, uid) VALUES (@id, @tsid, @uid)';
			int rows = await dbConn.execute(query, {'id': database.id, 'tsid': database.tsid, 'uid': database.uid});
			return (rows == 1);
		} catch (e) {
			Log.error('Could not save street instance <id=${database.id}>', e);
			return false;
		} finally {
			dbManager.closeConnection(dbConn);
		}
	}

	/// Delete a street instance.
	/// Will throw an error if the street is occupied.
	/// Returns database edit success as true/false.
	Future<bool> destroy() async {
		if (this.occupants.length > 0) {
			throw new ConcurrentModificationError('Cannot delete occupied street instance');
		}

		PostgreSql dbConn = await dbManager.getConnection();
		try {
			String query = 'DELETE FROM $TABLE WHERE id = @id';
			int rows = await dbConn.execute(query, {'id': database.id});
			return (rows == 1);
		} catch (e) {
			Log.error('Could not delete street instance <id=${database.id}>', e);
			return false;
		} finally {
			dbManager.closeConnection(dbConn);
		}
	}

	@override
	String toString() => 'Street <tsid=${database.tsid}> for <uid=${database.id}>';
}