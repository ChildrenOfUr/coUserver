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

		if (leavingUser != null) {
			questLogCache[leavingUser].stopTracking();
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

			//offer the tree petter quest
			questLogCache[email].offerQuest(email,'Q2');
		}
		if (map['acceptQuest'] != null) {
			messageBus.publish(new AcceptQuest(map['email'],map['id']));
		}
		if (map['rejectQuest'] != null) {
			messageBus.publish(new RejectQuest(map['email'],map['id']));
		}
	}
}