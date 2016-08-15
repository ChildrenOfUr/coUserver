part of item;

abstract class FocusingOrb extends Object with MetabolicsChange {
	Future<bool> levitate({WebSocket userSocket, String username, String email, Map map, String streetName}) async {
		toast('Levitating is not implemented yet. Sorry!', userSocket);
		return false;
	}

	Future<bool> focusEnergy({WebSocket userSocket, String username, String email, Map map, String streetName}) async {
		toast("+10 energy focused", userSocket);
		return await trySetMetabolics(email, energy:10);
	}

	Future<bool> focusMood({WebSocket userSocket, String username, String email, Map map, String streetName}) async {
		toast("+10 mood focused", userSocket);
		return await trySetMetabolics(email, mood:10);
	}

	Future<bool> radiate({WebSocket userSocket, String username, String email, Map map, String streetName}) async {
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
			users.forEach((String username) => trySetMetabolics(email, mood: amt, energy: amt, imgMin: amt));
			StreetUpdateHandler.streets[streetName].occupants.forEach((String username, WebSocket ws) => toast("$username is radiating. Everyone here got $amt energy, mood, and iMG", ws));
			return true;
		}
	}

	Future<bool> meditate({WebSocket userSocket, String username, String email, Map map, String streetName}) async {
		toast("+5 energy, mood, and iMG", userSocket);
		return await trySetMetabolics(email, energy:5, mood:5, imgMin: 5);
	}
}
