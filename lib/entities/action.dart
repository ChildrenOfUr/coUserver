part of item;

class Action {
	@Field()
	String actionName, _actionWord, error;
	@Field()
	bool enabled = true, multiEnabled = false, groundAction = false;
	@Field()
	String description = '';
	@Field()
	int timeRequired = 0;
	@Field()
	ItemRequirements itemRequirements = new ItemRequirements();
	@Field()
	SkillRequirements skillRequirements = new SkillRequirements();
	@Field()
	EnergyRequirements energyRequirements = new EnergyRequirements();
	@Field()
	String associatedSkill;

	Action();

	Action.withName(this.actionName);

	Action.clone(Action action) {
		actionName = action.actionName;
		_actionWord = action._actionWord;
		enabled = action.enabled;
		multiEnabled = action.multiEnabled;
		groundAction = action.groundAction;
		description = action.description;
		timeRequired = action.timeRequired;
		itemRequirements = new ItemRequirements.clone(action.itemRequirements);
		skillRequirements = new SkillRequirements.clone(action.skillRequirements);
		energyRequirements = new EnergyRequirements.clone(action.energyRequirements);
		associatedSkill = action.associatedSkill;
	}

	String get actionWord => _actionWord ?? actionName.toLowerCase();
	void set actionWord(String word) {
		_actionWord = word;
	}

	@override
	String toString() {
		String returnString = "$actionName requires any of ${itemRequirements.any}, all of ${itemRequirements.all} and at least ";
		skillRequirements.requiredSkillLevels.forEach((String skill, int level) {
			returnString += "$level level of $skill, ";
		});
		returnString = returnString.substring(0, returnString.length - 1);

		return returnString;
	}
}

class SkillRequirements {
	@Field()
	Map<String, int> requiredSkillLevels = {};
	@Field()
	String error = "You don't have the required skill(s)";

	SkillRequirements();
	SkillRequirements.clone(SkillRequirements req) {
		requiredSkillLevels = new Map.from(req.requiredSkillLevels);
		error = req.error;
	}
}

class ItemRequirements {
	@Field()
	List<String> any = [];
	@Field()
	Map<String, int> all = {};
	@Field()
	String error = "You don't have the required item(s)";

	ItemRequirements();

	ItemRequirements.clone(ItemRequirements req) {
		any = new List.from(req.any);
		all = new Map.from(req.all);
		error = req.error;
	}

	ItemRequirements.set({this.any, this.all});
}

class EnergyRequirements {
	@Field()
	int energyAmount;
	@Field()
	String error;

	EnergyRequirements({this.energyAmount: 0}) {
		error = 'You need at least $energyAmount energy to perform this action';
	}
	EnergyRequirements.clone(EnergyRequirements req) {
		energyAmount = req.energyAmount;
		error = req.error;
	}
}