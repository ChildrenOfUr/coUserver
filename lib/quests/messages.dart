part of quests;

class CompleteRequirement {
	Requirement requirement;
	String email;

	CompleteRequirement(this.requirement, this.email);
}

class FailRequirement {
	Requirement requirement;
	String email;

	FailRequirement(this.requirement, this.email);
}

class CompleteQuest {
	Quest quest;
	String email;

	CompleteQuest(this.quest, this.email);
}

class FailQuest {
	Quest quest;
	String email;

	FailQuest(this.quest, this.email);
}

class AcceptQuest {
	String email, questId;

	AcceptQuest(this.email, this.questId);
}

class RejectQuest {
	String email, questId;

	RejectQuest(this.email, this.questId);
}

class RequirementProgress {
	String eventType, email;
	int count;

	RequirementProgress(this.eventType, this.email, {this.count: 1});
}

class RequirementUpdated {
	Requirement requirement;
	String email;

	RequirementUpdated(this.requirement, this.email);
}
