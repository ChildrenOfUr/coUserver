part of item;

class Action {
	@Field()
	String actionName;
	@Field()
	bool multiEnabled = false;
	@Field()
	String description = '';
	@Field()
	int timeRequired = 0;
	@Field()
	ItemRequirements itemRequirements = new ItemRequirements();
	@Field()
	SkillRequirements skillRequirements = new SkillRequirements();
	@Field()
	String associatedSkill;

	Action();

	Action.withName(this.actionName);

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
}

class ItemRequirements {
	@Field()
	List<String> any = [];
	@Field()
	Map<String, int> all = {};
}
