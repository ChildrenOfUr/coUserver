part of street_update_handler;

class SavannaHandler {
	// TODO: quest https://github.com/tinyspeck/glitch-GameServerJS/blob/f4cf3e3ed540227b0f1fec26dd5273c03b0f9ead/quests/baqala_nostalgia.js

	// TODO: rock https://github.com/tinyspeck/glitch-GameServerJS/blob/f4cf3e3ed540227b0f1fec26dd5273c03b0f9ead/locations/savanna.js

	static Future enter(String streetName, String email, WebSocket userSocket) async {
		// Only when entering a Savanna street
		if (!MapData.isSavannaStreet(streetName)) {
			return;
		}

		if (!(await BuffManager.playerHasBuff('nostalgia_over', email))) {
			// Allow
			Log.debug('<email=$email> entered $streetName in Savanna');
			BuffManager.addToUser('nostalgia', email, userSocket);
		} else {
			// Disallow
			toast('You are still too overwhelmed by nostalgia', userSocket);
			_kick(streetName, email, userSocket);
		}
	}

	static Future exit(String streetName, String username, String email, WebSocket userSocket) async {
		// Only when exiting a Savanna street, not entering
		if (MapData.isSavannaStreet(ChatHandler.users[username].currentStreet)) {
			return;
		}

		// Prevent entering again
		Log.debug('<username=$username> left Savanna');
		_tempBan(email, userSocket);
	}

	static Future update(String streetName, String email, WebSocket userSocket) async {
		// Waiting for the street to load prevents update() being called
		// between enter() and the client loading the exit street
		await new Future.delayed(new Duration(seconds: 10));

		// Only when on a Savanna street
		if (!MapData.isSavannaStreet(streetName)) {
			return;
		}

		// Kick out players whose buffs have run out
		if (!(await BuffManager.playerHasBuff('nostalgia', email))) {
			toast('The nostalgia is overwhelming. You need to take a break', userSocket);
			_kick(streetName, email, userSocket);
		}
	}

	static Future _tempBan(String email, WebSocket userSocket) async {
		// Switch buffs to prevent reentry
		if (await BuffManager.playerHasBuff('nostalgia', email)) {
			await Future.wait([
				BuffManager.removeFromUser('nostalgia', email, userSocket),
				BuffManager.addToUser('nostalgia_over', email, userSocket)
			]);
		}
	}

	static void _kick(String currentStreetName, String email, WebSocket userSocket) {
		Log.debug('Kicking <email=$email> from $currentStreetName in Savanna');

		// Disallow entry
		_tempBan(email, userSocket);

		// Teleport to nearest non-Savanna hub
		StreetUpdateHandler.teleport(
			userSocket: userSocket,
			email: email,
			tsid: MapData.savannaEscapeTo(currentStreetName),
			energyFree: true);
	}
}

class WintryPlaceHandler {
	static Future enter(String streetName, String email, WebSocket userSocket) async {
		// Only when entering the Wintry Place
		if (streetName != 'Wintry Place') {
			return;
		}

		// Add warning buff
		Log.debug('<email=$email> entered Wintry Place');
		await BuffManager.addToUser('cold_place', email, userSocket);
	}

	static Future exit(String streetName, String username, String email, WebSocket userSocket) async {
		// Only when exiting the Wintry Place, not entering
		if (ChatHandler.users[username].currentStreet == 'Wintry Place') {
			return;
		}

		// Remove warning buff
		Log.debug('<username=$username> exited Wintry Place');
		await BuffManager.removeFromUser('cold_place', email, userSocket);
	}

	static Future update(String streetName, String email) async {
		// Only when in the Wintry Place
		if (streetName != 'Wintry Place') {
			return;
		}

		// Every 5 seconds, remove 4 energy (in addition to normal decay)
		if (new DateTime.now().second % 5 == 0) {
			Log.debug('Removing energy from <email=$email> in Wintry Place');

			// Write to database and send to client
			Metabolics metabolics = await getMetabolics(email: email);
			metabolics.energy -= 4;
			await setMetabolics(metabolics);
		}
	}
}
