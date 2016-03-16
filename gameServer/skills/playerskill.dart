part of coUserver;

/*
 * PlayerSkill class, used to represent a single player's status on a skill.
 * Basically a Skill with stored player data.
 */

class PlayerSkill extends Skill {
	/// Get a PlayerSkill for any player, any skill
	static Future<PlayerSkill> find(String skillId, String email) async {
		return Skill.find(skillId).getForPlayer(email);
	}

	PlayerSkill(Skill base, this.email, [this.points]) : super.fromMap(base.toMap());

	PlayerSkill.fromMap(Map map) : super.fromMap(map) {
		email = map["email"];
		points = map["points"];
	}

	Map toMap() => super.toMap()..addAll({
		"player_email": email,
		"player_points": points,
		"player_nextPoints": pointsForLevel(level + 1),
		"player_level": level,
		"player_iconUrl": iconUrl,
		"player_description": description
	});

	String toString() => "<Skill $id for $email>";

	String email;

	// Points/Levels

	int points;

	/// True if level increased from new points, false if not
	Future<bool> addPoints(int newPoints) async {
		int oldLevel = level;
		points += newPoints;
		await _write();
		return (level > oldLevel);
	}

	int get level => levelForPoints(points);

	// Level-specific icon & description

	String get iconUrl => iconUrls[level - 1];
	String get description => descriptions[level - 1];

	// Database

	/// Save changes to database
	Future<bool> _write() async {
		PostgreSql dbConn = await dbManager.getConnection();
		try {
			// Get existing data
			Map<String, int> skillsData = JSON.decode(
				(await dbConn.query(SkillManager.CELL_QUERY, Metabolics, {"email": email})
			).first.skills_json);

			// Modify
			skillsData[id] = points;
			String newJson = JSON.encode(skillsData);

			// Write new data
			return (await (dbConn.execute(
				"UPDATE metabolics AS m SET skills_json = @newJson"
					" FROM users AS u"
					" WHERE m.user_id = u.id"
					" AND u.email = @email",
				{"newJson": newJson, "email": email}
			)) == 1);
		} catch (e) {
			log("Error setting skill $id for $email: $e");
		} finally {
			dbManager.closeConnection(dbConn);
		}
	}
}