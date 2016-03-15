part of coUserver;

/*
 *	Skill class, used for easy math and to prevent crazy map referencing.
 *	Instances should not be created/modified/destroyed after the server has initially loaded.
 */

class Skill {
	Skill(
		this.id,
		this.name,
		this.levels,
		this.iconUrls,
		this.requirements,
		this.giants
	);

	Skill.fromMap(Map map, [String id]) {
		this.id = id ?? map["id"];
		this.name = map["name"];
		this.levels = map["levels"];
		this.iconUrls = map["iconUrls"];
		this.requirements = map["requirements"];
		this.giants = map["giants"];
	}

	Map toMap() => {
		"id": id,
		"name": name,
		"levels": levels,
		"num_levels": numLevels,
		"iconUrls": iconUrls,
		"requirements": requirements,
		"giants": giants,
		"primary_giant": primaryGiant
	};

	Skill get copy => new Skill.fromMap(toMap());

	String toString() => "<Skill $id>";

	String id;
	String name;

	// Levels

	List<int> levels;

	int get numLevels => levels.length;

	int pointsForLevel(int level) {
		level = level.clamp(1, numLevels);
		return levels[level - 1];
	}

	int levelForPoints(int points) {
		for (int level = 1; level <= numLevels; level++) {
			if (pointsForLevel(level) < points) {
				return (level - 1).clamp(1, numLevels);
			}
		}
		return 1;
	}

	// Icons

	List<String> iconUrls;

	String getLevelIcon(int level) => iconUrls[level];

	// Requirements

	Map<String, dynamic> requirements;

	Map<Skill, int> get skillRequirements {
		Map reqs = new Map();
		if (requirements["skills"] == null) {
			return reqs;
		} else {
			requirements["skills"].forEach((String skillName, int level) {
				reqs.addAll({SkillManager.find(skillName): level});
			});
			return reqs;
		}
	}

	// Giants

	List<String> giants;

	String get primaryGiant => giants.first;

	// Database

	Future<PlayerSkill> getPlayer(String email) async {
		PostgreSql dbConn = await dbManager.getConnection();
		try {
			int points = JSON.decode((await dbConn.query(
				"SELECT skills_json FROM metabolics AS m"
					" JOIN users AS u ON m.user_id = u.id"
					" WHERE u.email = @email",
				Metabolics, {"email": email}
			)).first.skills_json)[id];
			return new PlayerSkill(copy, email, points);
		} catch (e) {
			log("Error getting skill $id for $email: $e");
		} finally {
			dbManager.closeConnection(dbConn);
		}
	}
}