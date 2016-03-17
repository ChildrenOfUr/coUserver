part of quests;

class CompleteRequirement extends harvest.Message {
	Requirement requirement;
	String email;

	CompleteRequirement(this.requirement, this.email);
}

class FailRequirement extends harvest.Message {
	Requirement requirement;
	String email;

	FailRequirement(this.requirement, this.email);
}

class CompleteQuest extends harvest.Message {
	Quest quest;
	String email;

	CompleteQuest(this.quest, this.email);
}

class FailQuest extends harvest.Message {
	Quest quest;
	String email;

	FailQuest(this.quest, this.email);
}

class AcceptQuest extends harvest.Message {
	String email, questId;

	AcceptQuest(this.email, this.questId);
}

class RejectQuest extends harvest.Message {
	String email, questId;

	RejectQuest(this.email, this.questId);
}

class RequirementProgress extends harvest.Message {
	String eventType, email;

	RequirementProgress(this.eventType, this.email);
}

class RequirementUpdated extends harvest.Message {
	Requirement requirement;
	String email;

	RequirementUpdated(this.requirement, this.email);
}