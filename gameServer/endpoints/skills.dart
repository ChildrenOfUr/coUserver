part of coUserver;

enum Skill {
	MINING,
	HARVESTING
}

@app.Group("/skills")
class SkillManager {
	static SkillManager INSTANCE = new SkillManager();

	static final Map<Skill, Map<String, dynamic>> SKILL_DATA = {
		Skill.MINING: {
			"levels": 4,
			"scale": {
				1: 50,
				2: 500,
				3: 5000,
				4: 10000
			}
		},
		Skill.HARVESTING: {
			"levels": 5,
			"scale": {
				1: 50,
				2: 350,
				3: 9000,
				4: 10000,
				5: 50000
			}
		}
	};

	// Convert a skill name to a skill enum reference
	Skill getSkillRef(String skillName) {
		skillName = skillName.trim().toUpperCase();
		for (Skill skill in Skill.values) {
			if (skill.toString().contains(skillName)) {
				return skill;
			}
		}
		return null;
	}

	// Convert a skill enum reference to a skill name
	String getSkillName(Skill skill) {
		String skillName = (skill.toString().split(".")[1]).toLowerCase();
		return (skillName.substring(0, 1).toUpperCase() + skillName.substring(1));
	}

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

	// Add progress to a skill for a user
	Future<bool> progress(String email, Skill skill, num amount) async {
		String skillName = getSkillName(skill);
		Map<String, num> data = await getPlayerSkills(email);

		if (data[skillName] == null) {
			data[skillName] = {"level": 0, "progress": 0};
		}

		num awarded = 0;
		while (awarded < amount) {
			// Max skill level
			if (data[skillName]["level"] >= skillLevels(skill)) {
				data[skillName]["level"] = skillLevels(skill);
				data[skillName]["progress"] = 0;
				break;
			}

			// Enough progress for next level, increment
			if (data[skillName]["progress"] >= maxProgress(skill, data[skillName]["level"] + 1)) {
				data[skillName]["progress"] -= maxProgress(skill, data[skillName]["level"] + 1);
				data[skillName]["level"]++;
				continue;
			}

			// Award progress
			data[skillName]["progress"]++;
			awarded++;
		}

		setPlayerSkills(email, data);

		return false;
	}

	// Get how many levels a skill has
	int skillLevels(Skill skill) {
		return SKILL_DATA[skill]["levels"] ?? 1;
	}

	// Get the max progress for any level of a skill
	int maxProgress(Skill skill, int level) {
		if (level < 1 || level > skillLevels(skill)) {
			return 0;
		}

		return SKILL_DATA[skill]["scale"][level];
	}
}