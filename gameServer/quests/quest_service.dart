part of coUserver;

Map<String, Quest> quests = {};

@app.Group("/quest")
class QuestService {
	@app.Route("/completed/:email")
	@Encode()
	static Future<List<Quest>> getCompleted(String email) async {
		return await _getQuestList(email, 'completed_list');
	}

	@app.Route("/inProgress/:email")
	@Encode()
	static Future<List<Quest>> getInProgress(String email) async {
		return await _getQuestList(email, 'in_progress_list');
	}

	@app.Route("/getQuestLog/:email")
	@Encode()
	static Future<UserQuestLog> getQuestLog(String email) async {
		PostgreSql dbConn = await dbManager.getConnection();
		UserQuestLog questLog = null;

		String query = "SELECT q.* from user_quests q JOIN users u ON u.id = user_id where u.email = @email";
		List<UserQuestLog> questLogs = await dbConn.query(query, UserQuestLog, {'email':email});
		if (questLogs.length > 0) {
			questLog = questLogs.first;
		} else {
			questLog = await createQuestLog(email);
		}

		await dbManager.closeConnection(dbConn);
		return questLog;
	}

	@app.Route("/updateQuestLog", methods: const[app.POST])
	static Future<bool> updateQuestLog(@Decode() UserQuestLog questLog) async {
		PostgreSql dbConn = await dbManager.getConnection();
		String query = "UPDATE user_quests SET completed_list = @completed_list, in_progress_list = @in_progress_list where id = @id";
		int numUpdated = await dbConn.execute(query, questLog);
		await dbManager.closeConnection(dbConn);

		if(numUpdated < 1) {
			return false;
		} else {
			return true;
		}
	}

	static Future<UserQuestLog> createQuestLog(String email) async {
		PostgreSql dbConn = await dbManager.getConnection();
		String query = "SELECT * FROM users where email = @email";
		List<User> users = await dbConn.query(query, User, {'email':email});
		if(users.length > 0) {
			int userId = users.first.id;
			query = "INSERT INTO user_quests(user_id) VALUES(@id)";
			await dbConn.execute(query,{'id':userId});
		}
		await dbManager.closeConnection(dbConn);

		return await getQuestLog(email);
	}

	static Future<List<Quest>> _getQuestList(String email, String listType) async {
		String query = "SELECT q.* FROM user_quests q JOIN users u ON u.id = user_id WHERE u.email = @email";
		List<UserQuestLog> results = await dbConn.query(query, UserQuestLog, {'email':email});
		if (results.length <= 0) {
			return [];
		}

		if (listType == 'completed_list') {
			return results.first.completedQuests;
		} else if (listType == 'in_progress_list') {
			return results.first.inProgressQuests;
		} else {
			return [];
		}
	}

	static loadQuests() async {
		try {
			String directory = Platform.script.toFilePath();
			directory = directory.substring(0, directory.lastIndexOf('/'));
			Directory questsDirectory = new Directory('$directory/gameServer/quests/json');
			await for(FileSystemEntity entity in questsDirectory.list(recursive: true)) {
				if (entity is File) {
					// load quests
					List<Quest> qList = decode(JSON.decode(await entity.readAsString()), Quest);
					qList.forEach((Quest q) => quests[q.id] = q);
				}
			}
		}
		catch (e) {
			log("Problem loading quests: $e");
		}
	}
}