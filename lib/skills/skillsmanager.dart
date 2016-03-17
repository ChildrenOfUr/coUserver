part of skills;

@app.Group("/skills")
class SkillManager {
	/// String used for querying for a specific skills_json cell
	/// Will return a length-1 list of rows from metabolics with only the skills_json column
	static final String CELL_QUERY = "SELECT skills_json FROM metabolics AS m"
		" JOIN users AS u ON m.user_id = u.id"
		" WHERE u.email = @email";

	/// All loaded skills...do not edit after initial load!
	static Map<String, Skill> SKILL_DATA = new Map();

	/// Load status
	static bool get loaded => _loading.isCompleted;
	static final Completer _loading = new Completer();

	/// Read skills from JSON file
	static void loadSkills() {
		String directory = Platform.script.toFilePath();
		directory = directory.substring(0, directory.lastIndexOf(Platform.pathSeparator));

		JSON.decode(
			new File(path.join(directory, 'lib', 'skills', 'skillsdata.json'))
				.readAsStringSync()
		).forEach((String id, Map data) {
			SKILL_DATA[id] = new Skill.fromMap(data, id);;
		});

		_loading.complete();
	}

	/// Add points to a player's skill
	static Future<bool> learn(String skillId, String email, [int newPoints = 1]) async {
		// Get existing skill or add if new
		PlayerSkill skill = await PlayerSkill.find(skillId, email);
		if (skill == null) {
			skill = new PlayerSkill(Skill.find(skillId), email);
		}

		// Save to database
		return await skill.addPoints(newPoints);
	}

	/// Get a player's level of a certain skil
	static Future<int> getLevel(String skillId, String email) async {
		PlayerSkill skill = await PlayerSkill.find(skillId, email);
		return skill?.level ?? 0;
	}

	/// Get all skills data for a user
	static Future<List<Map<String, dynamic>>> getPlayerSkills(email) async {
		PostgreSql dbConn = await dbManager.getConnection();
		try {
			// Get data from database
			Map<String, int> playerSkillsData = JSON.decode(
				(await dbConn.query(CELL_QUERY, Metabolics, {"email": email})).first.skills_json
			);

			// Fill in skill information
			List<Map<String, dynamic>> playerSkillsList = new List();
			playerSkillsData.forEach((String id, int points) {
				playerSkillsList.add(new PlayerSkill(Skill.find(id), email, points).toMap());
			});

			return playerSkillsList;
		} catch (e) {
			log("Error getting skill list for email $email: $e");
			return new List();
		} finally {
			dbManager.closeConnection(dbConn);
		}
	}

	/// API access to [getPlayerSkills]
	@app.Route("/get/:email")
	Future<List<Map<String, dynamic>>> getPlayerSkillsRoute(email) async {
		return await getPlayerSkills(email);
	}
}