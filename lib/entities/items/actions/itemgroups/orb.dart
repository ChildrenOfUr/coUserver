part of item;

abstract class Item_Orb {
	static Future<bool> levitate(WebSocket userSocket) async {
		toast("Levitating is not implemented yet. Sorry!", userSocket);
		return false;
	}

	static Future<bool> focusEnergy(WebSocket userSocket, String username) async {
		toast("+10 energy focused", userSocket);
		return await ItemUser.trySetMetabolics(username, energy:10);
	}

	static Future<bool> focusMood(WebSocket userSocket, String username) async {
		toast("+10 mood focused", userSocket);
		return await ItemUser.trySetMetabolics(username, mood:10);
	}

	static Future<bool> radiate(String streetName, String radiator) async {
		List<String> users = [];
		List<Identifier> ids = ChatHandler.users.values.where((Identifier id) => id.channelList.contains(streetName)).toList();
		ids.forEach((Identifier id) => users.add(id.username));
		int numUsersOnStreet = users.length;
		if (numUsersOnStreet == 1) {
			return false;
		} else {
			int amt;
			if (numUsersOnStreet < 10) {
				amt = 20;
			} else if (numUsersOnStreet > 10 && numUsersOnStreet < 20) {
				amt = 40;
			} else {
				amt = 60;
			}

			amt = (amt / numUsersOnStreet).ceil();
			users.forEach((String username) => ItemUser.trySetMetabolics(username, mood: amt, energy: amt, img: amt));
			StreetUpdateHandler.streets[streetName].occupants.forEach((String username, WebSocket ws) => toast("$radiator is radiating. Everyone here got $amt energy, mood, and iMG", ws));
			return true;
		}
	}

	static Future<bool> meditate(WebSocket userSocket, String username) async {
		toast("+5 energy, mood, and iMG", userSocket);
		return await ItemUser.trySetMetabolics(username, energy:5, mood:5, img: 5);
	}
}