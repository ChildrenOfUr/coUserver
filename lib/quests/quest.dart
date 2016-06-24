library quests;

import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:coUserver/common/util.dart';
import 'package:coUserver/common/user.dart';
import 'package:coUserver/entities/items/item.dart';
import 'package:coUserver/endpoints/inventory_new.dart';
import 'package:coUserver/endpoints/metabolics/metabolics.dart';

import 'package:message_bus/message_bus.dart';
import 'package:redstone_mapper/mapper.dart';
import 'package:redstone/redstone.dart' as app;
import 'package:redstone_mapper/plugin.dart';
import 'package:redstone_mapper_pg/manager.dart';
import 'package:path/path.dart' as path;

part 'messages.dart';

part 'quest_endpoint.dart';

part 'quest_service.dart';

abstract class Trackable implements EventHandler {
	String email;
	bool beingTracked = false;
	Timer limitTimer;
	Map<Type, EventHandler> mbSubscriptions = {};
	Map<String, dynamic> headers = {};

	void startTracking(String email) {
		this.email = email;
		beingTracked = true;
	}

	void stopTracking() {
		limitTimer?.cancel();
		mbSubscriptions.forEach((Type type, EventHandler handler) => messageBus.unsubscribe(type, handler));
		mbSubscriptions.clear();
		beingTracked = false;
	}
}

class Requirement extends Trackable {
	bool _fulfilled = false,
		failed = false;
	int _numFulfilled = 0;
	@Field() int numRequired, timeLimit;
	@Field() String id, text, type, eventType;
	@Field() String iconUrl = '';
	@Field() List<String> typeDone = [];

	@Field() bool get fulfilled => _fulfilled;

	@Field() void set fulfilled(bool value) {
		_fulfilled = value;
		if (_fulfilled && beingTracked) {
			try {
				messageBus.publish(new CompleteRequirement(this, email));
			} catch (e, st) {
				Log.error('Setting requirement <id=$id> fulfilled to $value for <email=$email>', e, st);
			}
		}
	}

	@Field() int get numFulfilled => _numFulfilled;

	@Field() void set numFulfilled(int value) {
		_numFulfilled = value;
		if (_numFulfilled >= numRequired) {
			fulfilled = true;
		}
	}

	Requirement();

	Requirement.clone(Requirement model) {
		numRequired = model.numRequired;
		timeLimit = model.timeLimit;
		id = model.id;
		text = model.text;
		type = model.type;
		eventType = model.eventType;
		iconUrl = model.iconUrl;
	}

	@override
	void handleEvent(RequirementProgress progress) {
		bool goodEvent = false;
		int count = 1;
		if (_matchingEvent(progress.eventType)) {
			if (type == 'counter_unique' && !typeDone.contains(progress.eventType)) {
				goodEvent = true;
				typeDone.add(progress.eventType);
			} else if (type == 'counter' || type == 'timed') {
				goodEvent = true;
				count = progress.count;
			}
		}

		if (!goodEvent || fulfilled) {
			return;
		}
		numFulfilled += count;
		try {
			messageBus.publish(new RequirementUpdated(this, email));
		} catch (e, st) {
			Log.error('Updating requirement <id=$id> for <email=$email>', e, st);
		}
	}

	@override
	void startTracking(String email) {
		if (fulfilled) {
			return;
		}

		super.startTracking(email);

		if (type == 'timed') {
			limitTimer = new Timer(new Duration(seconds: timeLimit), () {
				try {
					messageBus.publish(new FailRequirement(this, email));
				} catch (e, st) {
					Log.error('Failing time requirement <id=$id> for <email=$email>', e, st);
				}
			});
		}

		messageBus.subscribe(RequirementProgress, this,
								 whereFunc: (RequirementProgress progress) => progress.email == email);
		mbSubscriptions[RequirementProgress] = this;
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
	@Field() int energy = 0,
		mood = 0,
		img = 0,
		currants = 0;
	@Field() List<QuestFavor> favor = [];
}

class QuestFavor {
	@Field() String giantName;
	@Field() int favAmt;
}

class Quest extends Trackable with MetabolicsChange {
	@Field() String id, title, description;
	@Field() bool complete = false;
	@Field() List<String> prerequisites = [];
	@Field() List<Requirement> requirements = [];
	@Field() Conversation conversation_start, conversation_end, conversation_fail;
	@Field() QuestRewards rewards;

	Quest();

	Quest.clone(String questId) {
		Quest model = quests[questId];
		id = model.id;
		title = model.title;
		description = model.description;
		prerequisites = model.prerequisites;
		List<Requirement> requirements = [];
		model.requirements.forEach((Requirement req) => requirements.add(new Requirement.clone(req)));
		this.requirements = requirements;
		conversation_start = model.conversation_start;
		conversation_end = model.conversation_end;
		conversation_fail = model.conversation_fail;
		rewards = model.rewards;
	}

	@override
	Future handleEvent(dynamic r) async {
		if (r is CompleteRequirement) {
			try {
				requirements.firstWhere((Requirement r) => !r.fulfilled);
			} catch (e) {
				complete = true;

				try {
					messageBus.publish(new CompleteQuest(this, email));
				} catch (e, st) {
					Log.error('Completing requirement of <quest=$id> for <email=$email>', e, st);
				}

				await _giveRewards();
			}
		} else if (r is FailRequirement) {
			try {
				messageBus.publish(new FailQuest(this, email));
			} catch (e, st) {
				Log.error('Failing <quest=$id> for <email=$email>', e, st);
			}

			stopTracking();
		} else if (r is RequirementUpdated) {
			Map map = {'questUpdate': true, 'quest': encode(this)};
			QuestEndpoint.userSockets[email]?.add(JSON.encode(map));
		}
	}

	@override
	void startTracking(String email, {bool justStarted: false}) {
		if (complete) {
			return;
		}

		super.startTracking(email);

		requirements.forEach((Requirement r) => r.startTracking(email));

		String heading = justStarted ? 'questBegin' : 'questInProgress';
		Map questInProgress = {heading: true, 'quest': encode(this)};
		QuestEndpoint.userSockets[email]?.add(JSON.encode(questInProgress));

		messageBus.subscribe(CompleteRequirement, this, whereFunc: (CompleteRequirement r) {
			return requirements.contains(r.requirement) && r.email == email;
		});
		messageBus.subscribe(FailRequirement, this, whereFunc: (FailRequirement r) {
			return requirements.contains(r.requirement) && r.email == email;
		});
		messageBus.subscribe(RequirementUpdated, this, whereFunc: (RequirementUpdated update) {
			return requirements.contains(update.requirement) && update.email == email;
		});
		mbSubscriptions.addAll({
								   CompleteRequirement: this,
								   FailRequirement: this,
								   RequirementUpdated: this
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
	bool operator ==(other) => this.id == other.id;

	@override
	int get hashCode => id.hashCode;
}

class UserQuestLog extends Trackable {
	int questNum = 0;
	bool offeringQuest = false;
	@Field() int id, user_id;
	@Field() String completed_list, in_progress_list;

	@override
	Future handleEvent(dynamic event) async {
		if (event is CompleteQuest) {
			CompleteQuest q = event;
			if (q.quest == null) {
				Log.error('CompleteQuest missing Quest for <email=$email>');
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

			//if they completed the sammich quest, go get a snocone
			//wait for a minute before offering
			if (q.quest.id == 'Q1') {
				new Timer(new Duration(minutes: 1), () =>
					QuestEndpoint.questLogCache[email].offerQuest('Q7'));
			}
		} else if (event is FailQuest) {
			FailQuest q = event;
			q.quest.stopTracking();

			Map map = {'questFail': true, 'quest': encode(q.quest)};
			if (QuestEndpoint.userSockets[email] != null) {
				QuestEndpoint.userSockets[email].add(JSON.encode(map));
			}

			inProgressQuests = new List.from(inProgressQuests)
				..removeWhere((Quest quest) => quest == q.quest);

			QuestService.updateQuestLog(this);
		} else if (event is RequirementUpdated) {
			RequirementUpdated update = event;
			List<Quest> tmp = [];
			inProgressQuests.forEach((Quest q) {
				if (q.requirements.contains(update.requirement)) {
					q.requirements.remove(update.requirement);
					q.requirements.add(update.requirement);
				}
				tmp.add(q);
			});
			inProgressQuests = tmp;

			QuestService.updateQuestLog(this);
		} else if (event is AcceptQuest) {
			AcceptQuest acceptance = event;
			if (headers['fromItem'] ?? false) {
				Item itemInSlot = await InventoryV2.takeItemFromUser(email, headers['slot'], headers['subSlot'], 1);
				if (itemInSlot == null) {
					return;
				}
			}
			offeringQuest = false;
			QuestEndpoint.questLogCache[acceptance.email].addInProgressQuest(acceptance.questId);
		} else if (event is RejectQuest) {
			offeringQuest = false;
		}
	}

	@override
	void startTracking(String email) {
		super.startTracking(email);

		//start tracking on all our in progress quests
		inProgressQuests.forEach((Quest q) => q.startTracking(email));

		//listen for quest completion events
		//if they don't belong to us, let someone else get them
		//if they do belong to us, send a message to the client to tell them of their success
		messageBus.subscribe(CompleteQuest, this, whereFunc: (CompleteQuest q) {
			return q.email == email;
		});
		messageBus.subscribe(FailQuest, this, whereFunc: (FailQuest q) {
			return q.email == email;
		});
		messageBus.subscribe(RequirementUpdated, this, whereFunc: (RequirementUpdated update) {
			return update.email == email;
		});
		mbSubscriptions.addAll({
								   CompleteQuest: this,
								   FailQuest: this,
								   RequirementUpdated: this
							   });
	}

	@override
	void stopTracking() {
		super.stopTracking();
		inProgressQuests.forEach((Quest q) => q.stopTracking());
		QuestService.updateQuestLog(this);
	}

	Future<bool> addInProgressQuest(String questId) async {
		Quest questToAdd = new Quest.clone(questId);
		if (_doingOrDone(questToAdd)) {
			return false;
		}

		questToAdd.startTracking(email, justStarted: true);
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

	void offerQuest(String questId, {bool fromItem: false, int slot: -1, int subSlot: -1}) {
		Quest questToOffer = new Quest.clone(questId);

		if (_doingOrDone(questToOffer) || offeringQuest) {
			return;
		}

		//check if prerequisite quests are complete
		for (String prereq in questToOffer.prerequisites) {
			Quest previousQ = new Quest.clone(prereq);
			if (!completedQuests.contains(previousQ)) {
				return;
			}
		}

		messageBus.subscribe(AcceptQuest, this, whereFunc: (AcceptQuest acceptance) {
			return acceptance.email == email;
		}, enrichFunc: () {
			headers['fromItem'] = fromItem;
			headers['slot'] = slot;
			headers['subSlot'] = subSlot;
		});
		messageBus.subscribe(RejectQuest, this, whereFunc: (RejectQuest rejection) {
			return rejection.email == email;
		});
		mbSubscriptions.addAll({
								   AcceptQuest: this,
								   RejectQuest: this
							   });

		Map questOffer = {
			'questOffer': true,
			'quest': encode(questToOffer)
		};
		QuestEndpoint.userSockets[email].add(JSON.encode(questOffer));
		offeringQuest = true;
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
