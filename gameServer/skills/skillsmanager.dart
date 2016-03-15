part of coUserver;

@app.Group("/skills")
class SkillManager {
	static Map<String, Skill> _SKILL_DATA = new Map();

	static bool get loaded => _loading.isCompleted;
	static final Completer _loading = new Completer();

	static void loadSkills() {
		String directory = Platform.script.toFilePath();
		directory = directory.substring(0, directory.lastIndexOf(Platform.pathSeparator));

		JSON.decode(
			new File(path.join(directory, 'gameServer', 'skills', 'skillsdata.json'))
				.readAsStringSync()
		).forEach((String id, Map data) {
			_SKILL_DATA[id] = new Skill.fromMap(data, id);;
		});

		_loading.complete();
	}

	static SkillManager INSTANCE = new SkillManager();

	static List<Skill> get skills => _SKILL_DATA.values;

	// Convert a skill name to a skill reference
	static Skill find(String id) => _SKILL_DATA[id].copy;

	// Get all skills data for a user
	@app.Route("/get/:email")
	Future<List<Map<String, dynamic>>> getPlayerSkills(email) async {
		PostgreSql dbConn = await dbManager.getConnection();
		try {
			// Get data from database
			Map<String, int> playerSkillsData = JSON.decode(
				(await dbConn.query(
					"SELECT skills_json FROM metabolics"
						" JOIN users ON users.id = user_id"
						" WHERE users.email = @email",
					Metabolics, {"email": email})
				).first.skills_json
			);

			// Fill in skill information
			List<Map<String, dynamic>> playerSkillsList = new List();
			playerSkillsData.forEach((String id, int points) {
				playerSkillsList.add(new PlayerSkill(find(id), email, points).toMap());
			});

			return playerSkillsList;
		} catch (e) {
			log("Error getting skill list for email $email: $e");
			return new List();
		} finally {
			dbManager.closeConnection(dbConn);
		}
	}
}