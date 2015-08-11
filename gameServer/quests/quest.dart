part of coUserver;

Map<String,Quest> quests = {};
loadQuests() async {
	try {
		String directory = Platform.script.toFilePath();
		directory = directory.substring(0, directory.lastIndexOf('/'));
		File questsFile = new File('$directory/gameServer/quests/quests.json');

		// load quests
		List<Quest> qList = decode(JSON.decode(await questsFile.readAsString()), Quest);
		qList.forEach((Quest q) => quests[q.id] = q);
	}
	catch(e) {
		log("Problem loading quests: $e");
	}
}

class Requirement {
	@Field() String id, text, type, eventType;
	@Field() bool fulfilled = false;
	@Field() int numRequired;
	int numFulfilled = 0;
}

class Quest {
	@Field() String id, title, text;
	@Field() bool complete = false;
	@Field() List<Quest> prerequisites = [];
	@Field() List<Requirement> requirements = [];
}

class UserQuest {
	@Field() int id, user_id;
	@Field() String completed_list, in_progress_list;
}

class QuestInstance extends Object with Events {
	Quest quest;

	QuestInstance(String questId) {
		quest = quests[questId];
		quest.requirements.forEach((Requirement r) {
			on(r.eventType,(dynamic d){print('1 more ${r.eventType} towards completion of ${r.text}');});
		});
	}
}

@app.Group("/quest")
class QuestService {
	@app.Route("/completed/:playerId")
	@Encode()
	Future<List<Quest>> getCompleted(int playerId) async {
		return await _getQuestList(playerId,'completed_list');
	}

	@app.Route("/inProgress/:playerId")
	@Encode()
	Future<List<Quest>> getInProgress(int playerId) async {
		return await _getQuestList(playerId,'in_progress_list');
	}

	Future<List<Quest>> _getQuestList(int playerId, String listType) async {
		String query = "SELECT * FROM user_quests WHERE user_id = @user_id";
		List<UserQuest> results = await dbConn.query(query,UserQuest,{'user_id':playerId});
		if(results.length <= 0) {
			return [];
		}

		List<String> ids;
		if(listType == 'completed_list') {
			ids = JSON.decode(results.first.completed_list);
		} else if (listType == 'in_progress_list') {
			ids = JSON.decode(results.first.in_progress_list);
		} else {
			return [];
		}

		List<Quest> questList = [];
		ids.forEach((String id) => questList.add(quests[id]));
		return questList;
	}
}