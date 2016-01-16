part of coUserver;

class CompleteRequirement extends harvest.Message {
	Requirement requirement;
	String email;

	CompleteRequirement(this.requirement, this.email);
}

class CompleteQuest extends harvest.Message {
	Quest quest;
	String email;

	CompleteQuest(this.quest, this.email);
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

abstract class Trackable {
	String email;
	bool beingTracked = false;
	StreamSubscription<harvest.Message> mbSubscription;

	void startTracking(String email) {
		this.email = email;
		beingTracked = true;
	}

	void stopTracking() {
		mbSubscription?.cancel();
		beingTracked = false;
	}
}

class Requirement extends Trackable {
	bool _fulfilled = false;
	int _numFulfilled = 0;
	@Field() int numRequired;
	@Field() String id, type, eventType;
	@Field() List<String> typeDone = [];

	@Field() bool get fulfilled => _fulfilled;

	@Field() void set fulfilled(bool value) {
		_fulfilled = value;
		if (_fulfilled && beingTracked) {
			messageBus.publish(new CompleteRequirement(this, email));
		}
	}

	@Field() int get numFulfilled => _numFulfilled;

	@Field() void set numFulfilled(int value) {
		_numFulfilled = value;
		if (_numFulfilled >= numRequired) {
			fulfilled = true;
		}
	}

	@override
	void startTracking(String email) {
		super.startTracking(email);
		mbSubscription = messageBus.subscribe(RequirementProgress, (RequirementProgress progress) {
			bool goodEvent = false;
			if (_matchingEvent(progress.eventType)) {
				if (type == 'counter_unique' && !typeDone.contains(progress.eventType)) {
					goodEvent = true;
					typeDone.add(progress.eventType);
				} else if (type == 'counter') {
					goodEvent = true;
				}
			}

			if (!goodEvent || progress.email != email || fulfilled) {
//				print('sorry, no go: $eventType, $email, $fulfilled');
				return;
			}
			numFulfilled += 1;
			messageBus.publish(new RequirementUpdated(this, email));
//			print('1 more ${eventType} towards completion of $id');
		});
	}

	bool _matchingEvent(String event) {
		RegExp matcher = new RegExp(eventType);
		return matcher.hasMatch(event);
	}

	@override
	String toString() => encode(this).toString();

	@override
	bool operator ==(Requirement other) => this.id == other.id;

	@override
	int get hashCode => id.hashCode;
}

class Conversation {
	@Field() String id, title;
	@Field() List<ConvoScreen> screens;
}

class ConvoScreen {
	@Field() List<String> paragraphs;
	@Field() List<ConvoChoice> choices;
}

class ConvoChoice {
	@Field() String text;
	@Field() int gotoScreen;
	@Field() bool isQuestAccept = false,
		isQuestReject = false;
}

class QuestRewards {
	@Field() int energy, mood, img, currants;
	@Field() List<QuestFavor> favor;
}

class QuestFavor {
	@Field() String giantName;
	@Field() int favAmt;
}

class Quest extends Trackable with MetabolicsChange {
	@Field() String id, title;
	@Field() bool complete = false;
	@Field() List<Quest> prerequisites = [];
	@Field() List<Requirement> requirements = [];
	@Field() Conversation conversation_start, conversation_end;
	@Field() QuestRewards rewards;

	@override
	void startTracking(String email) {
		super.startTracking(email);

		requirements.forEach((Requirement r) => r.startTracking(email));

		mbSubscription = messageBus.subscribe(CompleteRequirement, (CompleteRequirement r) {
			if (!requirements.contains(r.requirement) || r.email != email) {
				return;
			}

			List<Requirement> tmp = [];
			requirements.forEach((Requirement req) {
				if (req.id != r.requirement.id) {
					tmp.add(req);
				}
			});
			tmp.add(r.requirement);
			requirements = tmp;

			try {
				requirements.firstWhere((Requirement r) => !r.fulfilled);
			} catch (e) {
				complete = true;
				messageBus.publish(new CompleteQuest(this, email));
				print('$email complted the quest "${title}"');
				_giveRewards();
			}
		});
	}

	Future<bool> _giveRewards() {
		return trySetMetabolics(email, rewards: rewards);
	}

	@override
	void stopTracking() {
		super.stopTracking();
		requirements.forEach((Requirement r) => r.stopTracking());
	}

	@override
	bool operator ==(Quest other) => this.id == other.id;

	@override
	int get hashCode => id.hashCode;
}

class UserQuestLog extends Trackable {
	int questNum = 0;
	@Field() int id, user_id;
	@Field() String completed_list, in_progress_list;

	@override
	void startTracking(String email) {
		super.startTracking(email);

		//start tracking on all our in progress quests
		inProgressQuests.forEach((Quest q) => q.startTracking(email));

		//listen for quest completion events
		//if they don't belong to us, let someone else get them
		//if they do belong to us, send a message to the client to tell them of their success
		mbSubscription = messageBus.subscribe(CompleteQuest, (CompleteQuest q) {
			if (q.email != email) {
				return;
			}

			q.quest.complete = true;
			q.quest.stopTracking();

			Map map = {'questComplete': true, 'quest': encode(q.quest)};
			if (QuestEndpoint.userSockets[email] != null) {
				QuestEndpoint.userSockets[email].add(JSON.encode(map));
			}

			inProgressQuests = new List.from(inProgressQuests)
				..removeWhere((Quest quest) => quest == q.quest);
			completedQuests = new List.from(completedQuests)
				..add(q.quest);

			QuestService.updateQuestLog(this);
		});

		//save our progress to the database so it doesn't get lost
		messageBus.subscribe(RequirementUpdated, (RequirementUpdated update) {
//			print('got a progress event: ${update.requirement.eventType}, ${update.requirement.email}');
			if (update.email != email) {
				return;
			}

			List<Quest> tmp = [];
			inProgressQuests.forEach((Quest q) {
				q.requirements.removeWhere((Requirement r) => r == update.requirement);
				q.requirements.add(update.requirement);
				tmp.add(q);
			});
			inProgressQuests = tmp;

			QuestService.updateQuestLog(this);
		});
	}

	@override
	void stopTracking() {
		super.stopTracking();
		inProgressQuests.forEach((Quest q) => q.stopTracking());
	}

	Future<bool> addInProgressQuest(String questId) async {
		Quest questToAdd = quests[questId];
		if (_doingOrDone(questToAdd)) {
			return false;
		}

		questToAdd.startTracking(email);
		List<Quest> tmp = inProgressQuests;
		tmp.add(questToAdd);
		inProgressQuests = tmp;
		await QuestService.updateQuestLog(this);

		return true;
	}

	bool _doingOrDone(Quest quest) {
		if (quest == null) {
			return true;
		}

		if (completedQuests.contains(quest) ||
		    inProgressQuests.contains(quest)) {
			return true;
		}

		return false;
	}

	void offerQuest(String email, String questId) {
		Quest questToOffer = quests[questId];
		if (_doingOrDone(questToOffer)) {
			return;
		}

		StreamSubscription<harvest.Message> acceptanceListener, rejectionListener;
		acceptanceListener = messageBus.subscribe(AcceptQuest, (AcceptQuest acceptance) {
			QuestEndpoint.questLogCache[acceptance.email].addInProgressQuest(acceptance.questId);
			acceptanceListener.cancel();
			rejectionListener.cancel();
		});
		rejectionListener = messageBus.subscribe(RejectQuest, (RejectQuest rejection) {
			acceptanceListener.cancel();
			rejectionListener.cancel();
		});

		Map questOffer = {
			'questOffer': true,
			'quest': encode(questToOffer)
		};
		QuestEndpoint.userSockets[email].add(JSON.encode(questOffer));
	}

	List<Quest> get completedQuests => decode(JSON.decode(completed_list), Quest);

	void set completedQuests(List<Quest> value) {
		completed_list = JSON.encode(encode(value));
	}

	List<Quest> get inProgressQuests => decode(JSON.decode(in_progress_list), Quest);

	void set inProgressQuests(List<Quest> value) {
		in_progress_list = JSON.encode(encode(value));
	}

	@override
	String toString() => 'UserQuestLog: ${encode(this)}';
}