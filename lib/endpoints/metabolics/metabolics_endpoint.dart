part of metabolics;

class MetabolicsEndpoint {
	static bool simulateMood = false,
		simulateEnergy = false;
	static Timer moodTimer = new Timer.periodic(new Duration(seconds: 60), (Timer timer) => simulateMood = true);
	static Timer energyTimer = new Timer.periodic(new Duration(seconds: 90), (Timer timer) => simulateEnergy = true);
	static Timer simulateTimer = new Timer.periodic(new Duration(seconds: 5), (Timer timer) => simulate());
	static Map<String, WebSocket> userSockets = {};

	static Future<int> upgradeEnergy() async {
		String query = 'SELECT * FROM metabolics';
		PostgreSql dbConn = await dbManager.getConnection();
		int upgraded = 0;
		try {
			List<Metabolics> playerMetabolics = await dbConn.query(query, Metabolics);
			await Future.forEach(playerMetabolics, (Metabolics m) async {
				if (m.lifetimeImg != null) {
					int newEnergy = energyLevels[getLevel(m.lifetimeImg)];
					m.energy = newEnergy;
					m.maxEnergy = newEnergy;
					Log.verbose('player ${m.userId} now has $newEnergy energy');
					await setMetabolics(m);
					upgraded++;
				}
			});
		} catch (e, st) {
			Log.error('Could not upgrade energy', e, st);
		} finally {
			dbManager.closeConnection(dbConn);
			return upgraded;
		}
	}

	static Future<int> convertLocationHistories() async {
		String query = 'SELECT * FROM metabolics';
		PostgreSql dbConn = await dbManager.getConnection();
		int converted = 0;

		try {
			await Future.forEach(await dbConn.query(query, Metabolics), (Metabolics m) async {
				List<String> oldTsids = JSON.decode(m.locationHistory);
				if (oldTsids.length == 0) {
					return;
				}

				List<String> newTsids = [];

				oldTsids.forEach((String tsid) {
					tsid = tsidL(tsid);
					if (!newTsids.contains(tsid)) {
						newTsids.add(tsid);
					}
				});

				m.locationHistory = JSON.encode(newTsids);
				await setMetabolics(m);
				converted++;
			});
		} catch (e, st) {
			Log.error('Could not convert location history', e, st);
		} finally {
			dbManager.closeConnection(dbConn);
			return converted;
		}
	}

	static void trackNewDays() {
		// Refill everyone's energy on the start of a new day
		Clock clock = new Clock();
		clock.onNewDay.listen((_) => MetabolicsEndpoint.refillAllEnergy());

		Log.verbose('[Init] Tracking new days');
	}

	static Future refillAllEnergy() async {
		PostgreSql dbConn = await dbManager.getConnection();
		String query = "UPDATE metabolics SET energy = max_energy, quoins_collected = 0";
		await dbConn.execute(query);
		dbManager.closeConnection(dbConn);
	}

	static void handle(WebSocket ws) {
		moodTimer.isActive;
		energyTimer.isActive;
		simulateTimer.isActive;

		ws.listen((message) => processMessage(ws, message),
			          onError: (error) => cleanupList(ws), onDone: () => cleanupList(ws));
	}

	static void cleanupList(WebSocket ws) {
		String leavingUser;

		userSockets.forEach((String username, WebSocket socket) {
			if (ws == socket) {
				socket = null;
				leavingUser = username;
			}
		});

		userSockets.remove(leavingUser);
	}

	static void processMessage(WebSocket ws, String message) {
		Map map = JSON.decode(message);
		String username = map['username'];

		if (!userSockets.containsKey(username)) {
			userSockets[username] = ws;
		}
	}

	static DateTime lastSimulation;

	static void simulate() {
		userSockets.forEach((String username, WebSocket ws) async {
			try {
				Metabolics m = await getMetabolics(username: username);
				String email = await User.getEmailFromUsername(username);

				/* Effects from smashed/hungover buffs */ {
					final int SMASHED_RATE = 3; // - energy, + mood
					final int SMASHED_TIME = 30; // seconds

					final int HUNGOVER_RATE = 17; // - mood
					final int HUNGOVER_TIME = 5; // seconds

					if (new DateTime.now().difference(lastSimulation).abs().inSeconds >= SMASHED_TIME
						&& await BuffManager.playerHasBuff('smashed', email)) {
						// Smashed converts energy into mood
						// Energy will never go below HOOCH_RATE with this buff
						m.energy = (m.energy - SMASHED_RATE).clamp(SMASHED_RATE, m.maxEnergy);
						m.mood += SMASHED_RATE;
					} else if (new DateTime.now().difference(lastSimulation).abs().inSeconds >= HUNGOVER_TIME
						&& await BuffManager.playerHasBuff('hungover', email)) {
						// Hungover is a mood killer
						m.mood -= HUNGOVER_RATE;
					}
				}

				if (simulateMood) {
					_calcAndSetMood(m);
				}

				if (m.mood < m.maxMood ~/ 10) {
					QuestEndpoint.questLogCache[email]?.offerQuest('Q10');
				}

				if (simulateEnergy) {
					_calcAndSetEnergy(m);
				}

				Identifier userIdentifier = PlayerUpdateHandler.users[username];

				if (userIdentifier != null) {
					updateDeath(userIdentifier, m);
				}

				//store current street and position
				if (userIdentifier != null) {
					m.currentStreet = userIdentifier.tsid;
					m.currentStreetX = userIdentifier.currentX;
					m.currentStreetY = userIdentifier.currentY;

					//store the metabolics back to the database
					if (await setMetabolics(m)) {
						//send the metabolics back to the user
						ws.add(JSON.encode(encode(m)));
					}
				}
			} catch (e, st) {
				Log.error('Metabolics simulation failed', e, st);
			}
		});

		lastSimulation = new DateTime.now();
	}

	/// Supply m to speed it up, and init to only check energy (in case they left the game while in Hell)
	static Future updateDeath(Identifier userIdentifier, [Metabolics m, bool init = false]) async {
		final String HELL_ONE = 'GA5PPFP86NF2FOS';
		final String CEBARKUL = 'GIF12PMQ5121D68';
		final int NARAKA = 40;

		if (userIdentifier == null) {
			return;
		}

		if (m == null) {
			m = await getMetabolics(username: userIdentifier.username);
		}

		if (
			m.energy == 0 // Dead
			&& (m.undeadStreet == null || init) // Not in Hell (or just connecting)
		) {
			// Save undead street
			m.dead = true;

			// Go to Hell One
			userIdentifier.webSocket.add(JSON.encode({
				"gotoStreet": "true",
				"tsid": HELL_ONE
			}));
		} else if (m.energy >= HellGrapes.ENERGY_REQ) {
			// Enough energy to be alive

			Map<String, dynamic> street = MapData.getStreetByTsid(m.currentStreet);
			if ((street == null) || ((street['hub_id'] ?? NARAKA) == NARAKA)) {
				// In Naraka, Return to world
				userIdentifier.webSocket.add(JSON.encode({
					"gotoStreet": "true",
					"tsid": m.undeadStreet ?? CEBARKUL
				}));

				m.dead = false;
			}
		}
	}

	static Future<bool> addToLocationHistory(String username, String email, String tsid) async {
		Metabolics m = await getMetabolics(username: username);
		List<String> locations = JSON.decode(m.locationHistory);
		tsid = tsidL(tsid);

		try {
			bool finalResult;

			// If it's not already in the history
			if (!locations.contains(tsid)) {
				locations.add(tsid);
				m.locationHistory = JSON.encode(locations);
				finalResult = await setMetabolics(m);
			} else {
				// Already in history
				finalResult = false;
			}

			// Award achievment?
			AchievementCheckers.hubCompletion(locations, email, tsid);

			try {
				if (locations.length >= 5) {
					Achievement.find("junior_ok_explorer").awardTo(email);
				}

				if (locations.length >= 23) {
					Achievement.find("senior_ok_explorer").awardTo(email);
				}

				if (locations.length >= 61) {
					Achievement.find("rambler_third_class").awardTo(email);
				}

				if (locations.length >= 127) {
					Achievement.find("rambler_second_class").awardTo(email);
				}

				if (locations.length >= 251) {
					Achievement.find("rambler_first_class").awardTo(email);
				}

				if (locations.length >= 503) {
					Achievement.find("wanderer").awardTo(email);
				}

				if (locations.length >= 757) {
					Achievement.find("world_class_traveler").awardTo(email);
				}

				if (locations.length >= 1259) {
					Achievement.find("globetrotter_extraordinaire").awardTo(email);
				}
			} catch (e, st) {
				Log.error('Error awarding location achievement to player $username', e, st);
			}

			return finalResult;
		} catch (e, st) {
			Log.error('Error marking location $tsid as visited for player $username', e, st);
		}

		return false;
	}

	static bool denyQuoin(Quoin q, String username) {
		Map<String, String> map = {'collectQuoin': 'true', 'success': 'false', 'id': q.id};
		try {
			userSockets[username].add(JSON.encode(map));
			return true;
		} catch (err, st) {
			Log.error('Could not pass map $map to player $username denying quoin', err, st);
			return false;
		}
	}

	static Future addQuoin(Quoin q, String username) async {
		String email = await User.getEmailFromUsername(username);
		Metabolics m = await getMetabolics(username: username);

		if (m.quoinsCollected >= constants.quoinLimit) {
			// Daily quoin limit
			denyQuoin(q, username);
			return;
		}

		num amt;
		if (q.type != "mystery") {
			// Choose a number 1-5
			amt = rand.nextInt(4) + 1;
			// Multiply it by the player's quoin multiplier
			amt = (amt * m.quoinMultiplier).round();
			// Double if buffed
			if (await BuffManager.playerHasBuff("double_quoins", await User.getEmailFromUsername(username))) {
				amt *= 2;
			}
		} else {
			// Chose a number 0.01 i to 0.09 i
			amt = (rand.nextInt(9) + 1) / 100;
			// Add it to the player's quoin multiplier
			m.quoinMultiplier += amt;

			// Limit QM
			if (m.quoinMultiplier > constants.quoinMultiplierLimit) {
				m.quoinMultiplier = constants.quoinMultiplierLimit;
				// Add double quoins buff instead
				BuffManager.addToUser("double_quoins", email, StreetUpdateHandler.userSockets[email]);
			}
		}

		if (q.type == 'quarazy') {
			amt *= 7;
		}

		if (q.type == 'currant') {
			m.currants += amt;
		}

		if (q.type == 'img' || q.type == 'quarazy') {
			m.img += amt;
			m.lifetimeImg += amt;
		}

		if (q.type == 'mood') {
			if ((m.mood + amt) > m.maxMood) {
				amt = m.maxMood - m.mood;
			}
			m.mood += amt;
		}

		if (q.type == 'energy') {
			if ((m.energy + amt) > m.maxEnergy) {
				amt = m.maxEnergy - m.energy;
			}
			m.energy += amt;
		}

		if (q.type == 'favor') {
			m.alphFavor += amt;
			m.alphFavor = m.alphFavor.clamp(0, m.alphFavorMax - 1);

			m.cosmaFavor += amt;
			m.cosmaFavor = m.cosmaFavor.clamp(0, m.cosmaFavorMax - 1);

			m.friendlyFavor += amt;
			m.friendlyFavor = m.friendlyFavor.clamp(0, m.friendlyFavorMax - 1);

			m.grendalineFavor += amt;
			m.grendalineFavor = m.grendalineFavor.clamp(0, m.grendalineFavorMax - 1);

			m.humbabaFavor += amt;
			m.humbabaFavor = m.humbabaFavor.clamp(0, m.humbabaFavorMax - 1);

			m.lemFavor += amt;
			m.lemFavor = m.lemFavor.clamp(0, m.lemFavorMax - 1);

			m.mabFavor += amt;
			m.mabFavor = m.mabFavor.clamp(0, m.mabFavorMax - 1);

			m.potFavor += amt;
			m.potFavor = m.potFavor.clamp(0, m.potFavorMax - 1);

			m.sprigganFavor += amt;
			m.sprigganFavor = m.sprigganFavor.clamp(0, m.sprigganFavorMax - 1);

			m.tiiFavor += amt;
			m.tiiFavor = m.tiiFavor.clamp(0, m.tiiFavorMax - 1);

			m.zilleFavor += amt;
			m.zilleFavor = m.zilleFavor.clamp(0, m.zilleFavorMax - 1);
		}

		if (q.type == 'time') {
			if (await BuffManager.playerHasBuff('nostalgia', email)) {
				PlayerBuff buff = await BuffManager.buffs['nostalgia'].getForPlayer(email);
				await buff.extend(new Duration(seconds: amt));
			}
		}

		if (amt > 0) {
			m.quoinsCollected++;
		}

		try {
			if (await setMetabolics(m)) {
				Map map = {'collectQuoin': 'true', 'id': q.id, 'amt': amt, 'quoinType': q.type};

				q.setCollected(username);

				userSockets[username].add(JSON.encode(map)); // send quoin
				userSockets[username].add(JSON.encode(encode(m))); // send metabolics
			}
		} catch (err, st) {
			Log.error('Could not set metabolics $m for player $username adding quoin', err, st);
		}
	}

	static void _calcAndSetMood(Metabolics m) {
		int max_mood = m.maxMood;
		num moodRatio = m.mood / max_mood;

		//determine how much mood they should lose based on current percentage of max
		//https://web.archive.org/web/20130106191352/http://www.glitch-strategy.com/wiki/Mood
		if (moodRatio < .5) {
			m.mood -= (max_mood * .005).ceil();
		} else if (moodRatio >= .5 && moodRatio < .81) {
			m.mood -= (max_mood * .01).ceil();
		} else {
			m.mood -= (max_mood * .015).ceil();
		}

		// Keep between 0 and max (both inclusive)<
		m.mood = m.mood.clamp(0, m.maxMood);
		simulateMood = false;
	}

	static void _calcAndSetEnergy(Metabolics m) {
		//players lose .8% of their max energy every 90 seconds
		//https://web.archive.org/web/20120805062536/http://www.glitch-strategy.com/wiki/Energy
		m.energy -= (m.maxEnergy * .008).ceil();

		// Keep between 0 and max (both inclusive)<
		m.energy = m.energy.clamp(0, m.maxEnergy);
		simulateEnergy = false;
	}
}


@app.Route('/getMetabolics')
@Encode()
Future<Metabolics> getMetabolics(
	{@app.QueryParam() String username,
	@app.QueryParam() String email,
	@app.QueryParam() int userId,
	@app.QueryParam() bool caseSensitive}) async {
	Metabolics metabolic = new Metabolics();

	PostgreSql dbConn = await dbManager.getConnection();
	try {
		String whereClause = "WHERE lower(users.username) = lower(@username)"; // case-insensitive
		if (email != null) {
			whereClause = "WHERE users.email = @email";
		}
		if (caseSensitive ?? false) {
			whereClause = "WHERE users.username = @username";
		}
		if (userId != null) {
			whereClause = "WHERE users.id = @userId";
		}
		String query = "SELECT * FROM metabolics JOIN users ON users.id = metabolics.user_id " + whereClause;
		List<Metabolics> metabolics = await dbConn.query(query, Metabolics, {'username': username, 'email': email, 'userId': userId});

		if (metabolics.length > 0) {
			metabolic = metabolics[0];
		} else {
			query = "SELECT * FROM users " + whereClause;
			var results = await dbConn.query(query, int, {'username': username, 'email': email, 'userId': userId});

			if (results.length > 0) {
				metabolic.userId = results[0]['id'];
			}
		}
	} catch (e, st) {
		Log.error('Getting metabolics failed', e, st);
	} finally {
		dbManager.closeConnection(dbConn);
		return metabolic;
	}
}

@app.Route('/setMetabolics', methods: const [app.POST])
Future<bool> setMetabolics(@Decode() Metabolics metabolics) async {
	bool result;

	// Check for level increase

	// Level before update
	Metabolics oldMetabolics = await getMetabolics(userId: metabolics.userId);
	int levelStart = getLevel(oldMetabolics.lifetimeImg);

	// Level after update
	int levelEnd = getLevel(metabolics.lifetimeImg);

	// Compare
	if (levelEnd > levelStart) {
		// Expand energy tank if level increased
		metabolics.maxEnergy = energyLevels[levelEnd];

		// Refill energy to new tank size
		metabolics.energy = metabolics.maxEnergy;

		// Send level up event to client
		String username = await User.getUsernameFromId(metabolics.userId);

		MetabolicsEndpoint.userSockets[username]?.add(JSON.encode({
			"levelUp": levelEnd
		}));
	}

	// Do not overset the metabolics that have maxes
	metabolics.mood = metabolics.mood.clamp(0, metabolics.maxMood);
	metabolics.energy = metabolics.energy.clamp(0, metabolics.maxEnergy);

	// Write to database
	PostgreSql dbConn = await dbManager.getConnection();
	try {
		//if the user already exists, update their data, otherwise insert them
		String query = "SELECT user_id FROM metabolics WHERE user_id = @user_id";
		List<int> results = await dbConn.query(query, int, metabolics);
		//user exists
		if (results.length > 0) {
			query = "UPDATE metabolics "
				"SET img = @img, "
				"currants = @currants, "
				"mood = @mood, "
				"energy = @energy, "
				"lifetime_img = @lifetime_img, "
				"current_street = @current_street, "
				"current_street_x = @current_street_x, "
				"current_street_y = @current_street_y, "
				"undead_street = @undead_street, "
				"max_energy = @max_energy, "
				"max_mood = @max_mood, "
				"alphfavor = @alphfavor, "
				"cosmafavor = @cosmafavor, "
				"friendlyfavor = @friendlyfavor, "
				"grendalinefavor = @grendalinefavor, "
				"humbabafavor = @humbabafavor, "
				"lemfavor = @lemfavor, "
				"mabfavor = @mabfavor, "
				"potfavor = @potfavor, "
				"sprigganfavor = @sprigganfavor, "
				"tiifavor = @tiifavor, "
				"zillefavor = @zillefavor, "
				"alphfavor_max = @alphfavor_max, "
				"cosmafavor_max = @cosmafavor_max, "
				"friendlyfavor_max = @friendlyfavor_max, "
				"grendalinefavor_max = @grendalinefavor_max, "
				"humbabafavor_max = @humbabafavor_max, "
				"lemfavor_max = @lemfavor_max, "
				"mabfavor_max = @mabfavor_max, "
				"potfavor_max = @potfavor_max, "
				"sprigganfavor_max = @sprigganfavor_max, "
				"tiifavor_max = @tiifavor_max, "
				"zillefavor_max = @zillefavor_max, "
				"quoin_multiplier = @quoin_multiplier, "
				"quoins_collected = @quoins_collected, "
				"location_history = @location_history "
				"WHERE user_id = @user_id";
		} else {
			query = "INSERT INTO metabolics ("
				"img, "
				"currants, "
				"mood, "
				"energy, "
				"lifetime_img, "
				"user_id, "
				"current_street, "
				"current_street_x, "
				"current_street_y, "
				"undead_street, "
				"max_energy, "
				"max_mood, "
				"alphfavor, "
				"cosmafavor, "
				"friendlyfavor, "
				"grendalinefavor, "
				"humbabafavor, "
				"lemfavor, "
				"mabfavor, "
				"potfavor, "
				"sprigganfavor, "
				"tiifavor, "
				"zillefavor, "
				"alphfavor_max, "
				"cosmafavor_max, "
				"friendlyfavor_max, "
				"grendalinefavor_max, "
				"humbabafavor_max, "
				"lemfavor_max, "
				"mabfavor_max, "
				"potfavor_max, "
				"sprigganfavor_max, "
				"tiifavor_max, "
				"zillefavor_max, "
				"location_history, "
				"quoin_multiplier, "
				"quoins_collected"
				") VALUES("
				"@img, "
				"@currants, "
				"@mood, "
				"@energy, "
				"@lifetime_img, "
				"@user_id, "
				"@current_street, "
				"@current_street_x, "
				"@current_street_y, "
				"@undead_street, "
				"@max_energy, "
				"@max_mood, "
				"@alphfavor, "
				"@cosmafavor, "
				"@friendlyfavor, "
				"@grendalinefavor, "
				"@humbabafavor, "
				"@lemfavor, "
				"@mabfavor, "
				"@potfavor, "
				"@sprigganfavor, "
				"@tiifavor, "
				"@zillefavor, "
				"@alphfavor_max, "
				"@cosmafavor_max, "
				"@friendlyfavor_max, "
				"@grendalinefavor_max, "
				"@humbabafavor_max, "
				"@lemfavor_max, "
				"@mabfavor_max, "
				"@potfavor_max, "
				"@sprigganfavor_max, "
				"@tiifavor_max, "
				"@zillefavor_max, "
				"@location_history, "
				"@quoin_multiplier, "
				"@quoins_collected)";
		}

		result = (await dbConn.execute(query, metabolics)) == 1;

		//send the new metabolics to the user right away
		WebSocket ws = MetabolicsEndpoint.userSockets[await User.getUsernameFromId(metabolics.userId)];
		ws?.add(JSON.encode(encode(metabolics)));
	} catch (e, st) {
		Log.error('Setting metabolics failed', e, st);
	} finally {
		dbManager.closeConnection(dbConn);
		return result;
	}
}
