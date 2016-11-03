part of skills;

/*
 *  Stores information about a specific skill.
 *	Instances should not be created/modified/destroyed after the server has initially loaded.
 */

class Skill {
	/// Convert a skill name to a skill reference
	static Skill find(String id) => SkillManager.SKILL_DATA[id]?.copy;

	Skill(
		this.id,
		this.name,
		this.category,
		this.descriptions,
		this.levels,
		this.iconUrls,
		this.requirements,
		this.giants,
		this.color,
		this.title
	) {
		_verifyZeroState();
	}

	Skill.fromMap(Map map, [String id]) {
		this.id = id ?? map["id"];
		this.name = map["name"];
		this.category = map["category"];
		this.descriptions = map["descriptions"];
		this.levels = map["levels"];
		this.iconUrls = map["iconUrls"];
		this.requirements = map["requirements"];
		this.giants = map["giants"];
		this.color = map["color"];
		this.title = map["title"];

		_verifyZeroState();
	}

	Map toMap() => {
		"id": id,
		"name": name,
		"category": category,
		"descriptions": descriptions,
		"levels": levels,
		"num_levels": numLevels,
		"iconUrls": iconUrls,
		"requirements": requirements,
		"giants": giants,
		"primary_giant": primaryGiant,
		"color": color,
		"title": title
	};

	/// Copy (new object, not reference)
	Skill get copy => new Skill.fromMap(toMap());

	String toString() => "<Skill $id>";

	String id;
	String name;
	String category;
	List<String> descriptions;
	String color; // #123456, used for client progress bars
	String title; // Badge after fully complete

	// Levels

	/// Points required for each level, including the unlearned state
	List<int> levels;

	/// How many levels the skill has, not including the unlearned state
	int get numLevels => levels.length - 1;

	/// Make sure the levels list contains an unlearned state
	void _verifyZeroState() {
		if (levels[0] != 0) {
			levels.insert(0, 0);
		}

		if (levels.length - 1 != descriptions.length) {
			throw new Exception('Levels and descriptions for <Skill=$id> do not match!');
		}

		if (levels.length - 1 != iconUrls.length) {
			throw new Exception('Levels and icons for <Skill=$id> do not match!');
		}
	}

	/// x points yields y level
	int pointsForLevel(int level) {
		level = level.clamp(0, numLevels);
		return levels[level];
	}

	/// x level requires y points
	int levelForPoints(int points) {
		for (int level = 0; level <= numLevels; level++) {
			if (pointsForLevel(level) > points) {
				// This level requires more points than we have, go back one
				return (level - 1).clamp(0, numLevels);
			}
		}

		// Points maxed out
		return numLevels;
	}

	// Icons

	/// Image URLs for every level
	List<String> iconUrls;

	// Requirements

	/// Requirement name/category => specific requirement
	Map<String, dynamic> requirements;

	// Giants

	/// All giant affiliatinos
	List<String> giants;

	/// Primary giant affiliation (first in file)
	String get primaryGiant => giants.first;

	// Database

	/// Get a PlayerSkill for this skill
	Future<PlayerSkill> getForPlayer(String email) async {
		PostgreSql dbConn = await dbManager.getConnection();
		try {
			List<Metabolics> rows = await dbConn.query(
				SkillManager.CELL_QUERY, Metabolics, {"email": email}
			);
			int points = 0;
			if (rows.length > 0) {
				points = JSON.decode(rows.first.skills_json)[id] ?? 0;
			}
			return new PlayerSkill(copy, email, points);
		} catch (e, st) {
			Log.error('Error getting skill $id', e, st);
			return null;
		} finally {
			dbManager.closeConnection(dbConn);
		}
	}
}
