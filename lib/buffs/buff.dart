part of buffs;

class Buff {
	static Buff find(String id) => BuffManager.buffs[id].copy;

	Buff(this.id, this.name, this.description, this.length);

	Buff.fromMap(Map<String, dynamic> map, [String id]) {
		this.id = id ?? map["id"];
		this.name = map["name"];
		this.description = map["description"];
		this.length = new Duration(seconds: map["length"]);
	}

	Map<String, dynamic> toMap() => {
		"id": id,
		"name": name,
		"description": description,
		"length": length.inSeconds
	};

	Buff get copy => new Buff.fromMap(this.toMap());

	bool get indefinite => length == -1; // buffs with a length of -1 will stay until removed

	@override
	String toString() => "<Buff $id>";

	String id;
	String name;
	String description;
	Duration length;

	Future<PlayerBuff> getForPlayer(String email) async {
		// Cache (to prevent duplicate timers)
		PlayerBuff cached = PlayerBuff.getFromCache(id, email);
		if (cached != null) {
			return cached;
		}

		// Database
		PostgreSql dbConn = await dbManager.getConnection();
		try {
			List<Metabolics> rows = await dbConn.query(
				BuffManager.CELL_QUERY, Metabolics, {"email": email}
			);
			int remaining = JSON.decode(rows.first.buffs_json)[id] ?? length.inSeconds;
			return new PlayerBuff(copy, email, remaining);
		} catch (e, st) {
			Log.error('Error getting buff $id for <email=$email>', e, st);
			return null;
		} finally {
			dbManager.closeConnection(dbConn);
		}
	}
}
