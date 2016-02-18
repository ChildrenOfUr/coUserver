part of coUserver;

/*
 * PlayerSkill class, used to represent a single player's status on a skill.
 * Basically a Skill with stored player data.
 */

class PlayerSkill extends Skill {
	PlayerSkill({Skill base, String email, int points}) {
		this._email = email;
		this._points = points;

		super._id = base.id;
		super._levels = base.levels;
		super._name = base._name;
	}

	String get email => _email;
	String _email;

	int get points => _points;
	int _points;

	// True if level increased from new points, false if not
	bool addPoints(int newPoints) {
		int oldLevel = level;
		_points += newPoints;
		return (level > oldLevel);
	}

	int get level => levelForPoints(points);

	String toString() => "<Skill: $id for $email>";
}