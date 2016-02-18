part of coUserver;

/*
 *	Skill class, used for easy math and to prevent crazy map referencing.
 *	Instances should not be created/modified/destroyed after the server has initially loaded.
 */

class Skill {
	Skill({
		String id,
		String name,
		List<int> levels,
		List<String> icons,
		Map<String, dynamic> requirements,
		List<String> giants
	}) {
		this._id = id;
		this._name = name;
		this._levels = levels;
		this._icons = icons;
		this._requirements = requirements;
		this._giants = giants;
	}

	String get id => _id;
	String _id;

	String get name => _name;
	String _name;

	List<String> get icons => _icons;
	List<String> _icons;

	String getLevelIcon(int level) => icons[level];

	Map<String, dynamic> get rawRequirements => _requirements;
	Map<String, dynamic> _requirements;

	Map<Skill, int> get skillRequirements {
		Map reqs = new Map();
		if (_requirements["skills"] == null) {
			return reqs;
		} else {
			rawRequirements["skills"].forEach((String skillName, int level) {
				reqs.addAll({SkillManager.find(skillName): level});
			});
			return reqs;
		}
	}

	List<String> get giants => _giants;
	List<String> _giants;

	String get primaryGiant => giants.first;

	List<int> get levels => _levels;
	List<int> _levels;

	int get numLevels => _levels.length;

	int pointsForLevel(int level) {
		level = level.clamp(1, numLevels);
		return levels[level];
	}

	int levelForPoints(int points) {
		for (int level = 0; level < numLevels; level++) {
			if (pointsForLevel(level) < points) {
				return (level - 1).clamp(1, numLevels);
			}
		}
		return null; // Shut up, WebStorm!
	}

	String toString() => "<Skill: $id>";
}