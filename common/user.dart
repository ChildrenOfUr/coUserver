part of coUserver;

class User {
	@Field() int id;
	@Field() String username, email, bio, achievements;
	@Field() bool chat_disabled;

	static Map<String, String> _emailUsernames = {};
	static Map<int, String> _idUsernames = {};

	static Future<String> getUsernameFromEmail(String email) async {
		if (_emailUsernames[email] != null) {
			return _emailUsernames[email];
		} else {
			PostgreSql dbConn = await dbManager.getConnection();
			try {
				String query = "SELECT * FROM users WHERE email = @email";
				User u = (await dbConn.query(query, User, {"email": email})).first;
				_emailUsernames[email] = u.username;
				_idUsernames[u.id] = u.username;
			} catch(e) {
				log("Error getting username for email $email: $e");
			} finally {
				dbManager.closeConnection(dbConn);
			}

			return _emailUsernames[email];
		}
	}

	static Future<String> getUsernameFromId(int id) async {
		if (_idUsernames[id] != null) {
			return _idUsernames[id];
		} else {
			PostgreSql dbConn = await dbManager.getConnection();
			try {
				String query = "SELECT * FROM users WHERE id = @id";
				User u = (await dbConn.query(query, User, {"id": id})).first;
				_emailUsernames[u.email] = u.username;
				_idUsernames[id] = u.username;
			} catch(e) {
				log("Error getting username for id $id: $e");
			} finally {
				dbManager.closeConnection(dbConn);
			}

			return _idUsernames[id];
		}
	}
}