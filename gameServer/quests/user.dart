part of coUserver;

class User {
	@Field() int id;
	@Field() String username, email, bio;
	@Field() bool chat_disabled;

	static Map<String, String> emailUsernames = {};
	static Future<String> getUsernameFromEmail(String email) async {
		if (emailUsernames[email] != null) {
			return emailUsernames[email];
		} else {
			PostgreSql dbConn = await dbManager.getConnection();

			try {
				emailUsernames[email] = (
				  await dbConn.query(
					"SELECT * FROM users WHERE email = @email", User, {"email": email})
				).first.username;
			} catch(e) {
				log("Error getting username for email $email: $e");
			} finally {
				dbManager.closeConnection(dbConn);
			}

			return emailUsernames[email];
		}
	}
}