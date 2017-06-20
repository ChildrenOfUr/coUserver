part of street;

class DBStreetInstance extends DBStreet {
	@Field() int uid;
	@Field() String tsid;
	@Field() bool is_home;

	DBStreetInstance({this.tsid, this.uid, this.is_home: false}) {
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
	static Future<StreetInstance> create(String tsid, int uid, {bool homeStreet}) async {
		StreetInstance instance = new StreetInstance(tsid, uid, homeStreet: homeStreet);
		if (await instance.save()) {
			return instance;
		} else {
			return null;
		}
	}

	DBStreetInstance database;

	StreetInstance(String tsid, int uid, {bool homeStreet}) : super(MapData.getStreetByTsid(tsid)['label'] ?? "$uid's $tsid", tsid) {
		database = new DBStreetInstance(tsid: tsid, uid: uid, is_home: homeStreet);

		// Load instance-specific entities
		loadEntities(database.id);
	}

	/// Save the state to the database.
	/// Returns database edit success as true/false.
	Future<bool> save() async {
		PostgreSql dbConn = await dbManager.getConnection();
		try {
			String query = 'INSERT INTO $TABLE (id, is_home, items) VALUES (@id, @is_home, @items)';
			int rows = await dbConn.execute(query, {'id': database.id, 'is_home': database.is_home, 'items': database.items});
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

@app.Group('/homestreet')
class HomeStreet {
	@app.Route('/get/:username')
	Future<String> getForPlayer(String username) async {
		try {
			int userId = await User.getIdFromUsername(username);
			String query = "SELECT tsid FROM ${StreetInstance.TABLE} WHERE is_home AND tsid LIKE '%.@userId'";
			List<String> rows = await dbConn.query(query, String, {'userId': userId});
			return rows.single;
		} catch (ex) {
			return null;
		}
	}

	@app.Route('/set/:username/:tsid')
	Future<bool> setForPlayer(String username, String tsid) async {
		int userId = await User.getIdFromUsername(username);
		return (await StreetInstance.create(tsid, userId, homeStreet: true)) != null;
	}
}