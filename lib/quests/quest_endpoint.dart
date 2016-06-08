part of quests;

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

		if (leavingUser != null) {
			questLogCache[leavingUser]?.stopTracking();
			questLogCache.remove(leavingUser);
			userSockets.remove(leavingUser);
		}
	}

	static Future processMessage(WebSocket ws, String message) async {
		Map map = JSON.decode(message);
		if (map['connect'] != null) {
			String email = map['email'];

			//setup our associative data structures
			userSockets[email] = ws;
			questLogCache[email] = await QuestService.getQuestLog(email);

			//start tracking this user's quest log
			questLogCache[email].startTracking(email);
		}
		if (map['acceptQuest'] != null) {
			try {
				messageBus.publish(new AcceptQuest(map['email'],map['id']));
			} catch (e, st) {
				Log.error('Accepting quest <id=${map['id']}> for <email=${map['email']}>', e, st);
			}
		}
		if (map['rejectQuest'] != null) {
			try {
				messageBus.publish(new RejectQuest(map['email'],map['id']));
			} catch (e, st) {
				Log.error('Rejecting quest <id=${map['id']}> for <email=${map['email']}>', e, st);
			}
		}
	}
}
