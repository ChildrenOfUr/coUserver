part of coUserver;

class QuestEndpoint {
	static Map<String, WebSocket> userSockets = {};
	static Map<String, UserQuestLog> questLogCache = {};

	static void handle(WebSocket ws) {
		ws.listen((message) => processMessage(ws, message),
		          onError: (error) => cleanupList(ws),
		          onDone: () => cleanupList(ws));
	}

	static void cleanupList(WebSocket ws) {
		String leavingUser;

		userSockets.forEach((String email, WebSocket socket) {
			if (ws == socket) {
				socket = null;
				leavingUser = email;
			}
		});

		questLogCache[leavingUser].stopTracking();
		questLogCache.remove(leavingUser);
		userSockets.remove(leavingUser);
	}

	static Future processMessage(WebSocket ws, String message) async {
		Map map = JSON.decode(message);
		if(map['connect'] != null) {
			String email = map['email'];

			//setup our associative data structures
			userSockets[email] = ws;
			questLogCache[email] = await QuestService.getQuestLog(email);

			//give this user the tree petter quest (debug purposes)
			await questLogCache[email].addInProgressQuest('Q2');

			//start tracking this user's quest log
			questLogCache[email].startTracking(email);

			//pass back a message that says we're good to go (debug)
			ws.add(JSON.encode({'data':'got it'}));
		}
	}
}