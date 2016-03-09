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
			new File(path.join(directory, 'gameServer', 'skills', 'skillsdata.json')).readAsStringSync()
		).forEach((String id, Map data) {
			Skill skill = new Skill(
				id: id,
				name: data["name"],
				icons: data["icons"],
				requirements: data["requirements"],
				giants: data["giants"]
			);
			_SKILL_DATA[id] = skill;
		});

		_loading.complete();
	}

	static SkillManager INSTANCE = new SkillManager();

	static List<Skill> get skills => _SKILL_DATA.values;

	// Convert a skill name to a skill enum reference
	static Skill find(String skillName) => _SKILL_DATA[skillName];

	// Get all skills data for a user
	@app.Route("/get/:email")
	Future<Map<String, Map<String, num>>> getPlayerSkills(@app.QueryParam("email") email) async {
		PostgreSql dbConn = await dbManager.getConnection();

		try {
			return JSON.decode(
			  (await dbConn.query(
				"SELECT skills_json FROM metabolics JOIN users ON users.id = user_id WHERE users.email = @email", Metabolics,
				{"email": email})).first.skills_json
			);
		} catch (e) {
			log("Error getting skills for email $email: $e");
			return {};
		} finally {
			dbManager.closeConnection(dbConn);
		}
	}

	// Set all skills data for a user
	Future<bool> setPlayerSkills(email, Map data) async {
		PostgreSql dbConn = await dbManager.getConnection();

		try {
			return (
			  (await dbConn.execute(
				"UPDATE metabolics AS m SET skills_json = @json FROM users AS u WHERE u.id = m.user_id AND u.email = @email",
				{"email": email, "json": JSON.encode(data)})) == 1
			);
		} catch (e) {
			log("Error setting skills for email $email: $e");
			return false;
		} finally {
			dbManager.closeConnection(dbConn);
		}
	}
}