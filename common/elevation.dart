part of coUserver;

@app.Group("/elevation")
class Elevation {
	static Map<String, String> _cache = new Map();
	static Elevation INSTANCE = new Elevation();

	@app.Route("/get/:username")
	Future<String> get(String username) async {
		if (_cache[username] != null) {
			return _cache[username];
		} else {
			List<User> rows = await dbConn.query(
				"SELECT elevation FROM users WHERE username = @username",
				User, {"username": username}
			);

			String elevationStr = rows.first.elevation ?? "";

			_cache[username] = elevationStr;
			return elevationStr;
		}
	}

	@app.Route("/set/:username/:elevation/:key")
	Future<bool> set(String username, String elevation, String key) async {
		if (key != mapFillerReportsToken) {
			return false;
		}

		int rows = await dbConn.execute(
			"UPDATE users SET elevation = @elevation WHERE username = @username",
			{"elevation": elevation, "username": username}
		);

		if (rows > 0) {
			_cache[username] = elevation;
		}

		return (rows == 1);
	}
}