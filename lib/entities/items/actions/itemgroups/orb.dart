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
		// Get users on this street
		List<Identifier> ids = ChatHandler.users.values.where((Identifier id) =>
			id.channelList.contains(streetName)).toList();
		List<String> users = [];
		ids.forEach((Identifier id) => users.add(id.username));

		if (users.length == 1) {
			toast("There's nobody else here!", userSocket);
			return false;
		} else {
			// Decide how much to award
			int amt = (50 / users.length).ceil().clamp(1, 10);

			// Add gains to everyone
			users.forEach((String username) async =>
				trySetMetabolics(await User.getEmailFromUsername(username), mood: amt, energy: amt, imgMin: amt));

			// Notify everyone
			StreetUpdateHandler.streets[streetName].occupants.values.forEach((WebSocket ws) =>
				toast("$username is radiating. Everyone here got $amt energy, mood, and iMG", ws));

			return true;
		}
	}

	Future<bool> meditate({WebSocket userSocket, String username, String email, Map map, String streetName}) async {
		toast("+5 energy, mood, and iMG", userSocket);
		return await trySetMetabolics(email, energy:5, mood:5, imgMin: 5);
	}
}
