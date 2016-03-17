library skills;

import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:coUserver/common/util.dart';
import 'package:coUserver/endpoints/metabolics/metabolics.dart';

import 'package:redstone/redstone.dart' as app;
import 'package:redstone_mapper_pg/manager.dart';
import 'package:path/path.dart' as path;

part 'playerskill.dart';
part 'skillsmanager.dart';

/*
 *	Skill class, used for easy math and to prevent crazy map referencing.
 *	Instances should not be created/modified/destroyed after the server has initially loaded.
 */

class Skill {
	/// Convert a skill name to a skill reference
	static Skill find(String id) => SkillManager.SKILL_DATA[id].copy;

	Skill(
		this.id,
		this.name,
		this.category,
		this.descriptions,
		this.levels,
		this.iconUrls,
		this.requirements,
		this.giants
	);

	Skill.fromMap(Map map, [String id]) {
		this.id = id ?? map["id"];
		this.name = map["name"];
		this.category = map["category"];
		this.descriptions = map["descriptions"];
		this.levels = map["levels"];
		this.iconUrls = map["iconUrls"];
		this.requirements = map["requirements"];
		this.giants = map["giants"];
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
		"primary_giant": primaryGiant
	};

	/// Copy (new object, not reference)
	Skill get copy => new Skill.fromMap(toMap());

	String toString() => "<Skill $id>";

	String id;
	String name;
	String category;
	List<String> descriptions;

	// Levels

	List<int> levels;

	int get numLevels => levels.length;

	/// x points yields y level
	int pointsForLevel(int level) {
		level = level.clamp(1, numLevels);
		return levels[level - 1];
	}

	/// x level requires y points
	int levelForPoints(int points) {
		for (int level = 1; level <= numLevels; level++) {
			if (pointsForLevel(level) > points) {
				return (level - 1).clamp(1, numLevels);
			}
		}

		// Points maxed out
		return numLevels;
	}

	// Icons

	List<String> iconUrls;

	// Requirements

	Map<String, dynamic> requirements;

	Map<Skill, int> get skillRequirements {
		Map reqs = new Map();
		if (requirements["skills"] == null) {
			return reqs;
		} else {
			requirements["skills"].forEach((String skillName, int level) {
				reqs.addAll({Skill.find(skillName): level});
			});
			return reqs;
		}
	}

	// Giants

	List<String> giants;

	String get primaryGiant => giants.first;

	// Database

	/// Get a PlayerSkill for this skill
	Future<PlayerSkill> getForPlayer(String email) async {
		PostgreSql dbConn = await dbManager.getConnection();
		try {
			List<Metabolics> rows = await dbConn.query(
				SkillManager.CELL_QUERY, Metabolics, {"email": email}
			);
			int points = JSON.decode(rows.first.skills_json)[id] ?? 0;
			return new PlayerSkill(copy, email, points);
		} catch (e) {
			log("Error getting skill $id for $email: $e");
		} finally {
			dbManager.closeConnection(dbConn);
		}
	}
}