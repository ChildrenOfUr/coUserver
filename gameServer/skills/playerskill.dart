part of coUserver;

/*
 * PlayerSkill class, used to represent a single player's status on a skill.
 * Basically a Skill with stored player data.
 */

class PlayerSkill extends Skill {
	PlayerSkill(Skill base, this.email, this.points) : super.fromMap(base.toMap());

	PlayerSkill.fromMap(Map map) : super.fromMap(map) {
		email = map["email"];
		points = map["points"];
	}

	Map toMap() => super.toMap()..addAll({
		"player_email": email,
		"player_points": points,
		"player_level": level,
		"player_iconUrl": iconUrl
	});

	String toString() => "<Skill $id for $email>";

	String email;

	// Points/Levels

	int points;

	/// True if level increased from new points, false if not
	bool addPoints(int newPoints) {
		int oldLevel = level;
		points += newPoints;
		write();
		return (level > oldLevel);
	}

	int get level => levelForPoints(points);

	// Level-specific icon

	String get iconUrl => iconUrls[level - 1];

	// Database

	Future<bool> write() async {
		PostgreSql dbConn = await dbManager.getConnection();
		try {
			// Get existing data
			Map<String, int> skillsData = JSON.decode((await dbConn.query(
				"SELECT skills_json FROM metabolics AS m"
					" JOIN users AS u ON m.user_id = u.id"
					" WHERE u.email = @email",
				Metabolics, {"email": email}
			)).first.skills_json);

			// Modify
			skillsData[id] = points;
			String newJson = JSON.encode(skillsData);

			// Write new data
			return (await (dbConn.execute(
				"UPDATE users SET skills_json = @newJson"
					" JOIN users AS u ON m.user_id = u.id"
					" WHERE u.email = @email",
				{"newJson": newJson, "email": email}
			)) == 1);
		} catch (e) {
			log("Error setting skill $id for $email: $e");
		} finally {
			dbManager.closeConnection(dbConn);
		}
	}
}