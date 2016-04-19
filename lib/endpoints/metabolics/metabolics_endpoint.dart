part of metabolics;

class MetabolicsEndpoint {
	static bool simulateMood = false,
		simulateEnergy = false;
	static Timer moodTimer = new Timer.periodic(new Duration(seconds: 60), (Timer timer) => simulateMood = true);
	static Timer energyTimer = new Timer.periodic(new Duration(seconds: 90), (Timer timer) => simulateEnergy = true);
	static Timer simulateTimer = new Timer.periodic(new Duration(seconds: 5), (Timer timer) => simulate());
	static Map<String, WebSocket> userSockets = {};

	static Future refillAllEnergy() async {
		PostgreSql dbConn = await dbManager.getConnection();
		String query = "UPDATE metabolics SET energy = max_energy, quoins_collected = 0";
		dbConn.execute(query);
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

	static void simulate() {
		userSockets.forEach((String username, WebSocket ws) async {
			try {
				Metabolics m = await getMetabolics(username: username);

				if (simulateMood) {
					_calcAndSetMood(m);
				}

				if (m.mood < m.max_mood ~/ 10) {
					String email = await User.getEmailFromUsername(username);
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
					m.current_street = userIdentifier.tsid;
					m.current_street_x = userIdentifier.currentX;
					m.current_street_y = userIdentifier.currentY;

					//store the metabolics back to the database
					int result = await setMetabolics(m);
					if (result > 0) {
						//send the metabolics back to the user
						ws.add(JSON.encode(encode(m)));
					}
				}
			} catch (e, st) {
				log("(metabolics endpoint - simulate): $e\n$st");
			}
		});
	}

	/// Supply m to speed it up, and init to only check energy (in case they left the game while in Hell)
	static Future updateDeath(Identifier userIdentifier, [Metabolics m, bool init = false]) async {
		if (userIdentifier == null) {
			return;
		}
		if (m == null) {
			m = await getMetabolics(username: userIdentifier.username);
		}

		if (m.energy == 0 && (m.undead_street == null || init)) {
			// Dead, but not in Hell
			Map<String, String> map = {
				"gotoStreet": "true",
				"tsid": "LA5PPFP86NF2FOS" // Hell One
			};
			m.dead = true;
			userIdentifier.webSocket.add(JSON.encode(map));
		} else if (m.energy >= HellGrapes.ENERGY_REQ && m.undead_street != null) {
			// Not dead (at least 10 energy), but in Hell
			Map<String, String> map = {
				"gotoStreet": "true",
				"tsid": m.undead_street // Street where they died
			};
			m.dead = false;
			userIdentifier.webSocket.add(JSON.encode(map));
		}
	}

	static Future<bool> addToLocationHistory(String username, String email, String TSID) async {
		Metabolics m = await getMetabolics(username: username);
		List<String> locations = JSON.decode(m.location_history);

		try {
			bool finalResult;

			// If it's not already in the history
			if (!locations.contains(TSID)) {
				locations.add(TSID);
				m.location_history = JSON.encode(locations);
				int result = await setMetabolics(m);
				finalResult = (result > 0);
			} else {
				// Already in history
				finalResult = false;
			}

			// Award achievment?
			AchievementCheckers.hubCompletion(locations, email, TSID);

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
			} catch (e) {
				log("Error awarding location achievement to player $username: $e");
			}

			return finalResult;
		} catch (e) {
			log("Error marking location $TSID as visited for player $username: $e");
		}
	}

	static denyQuoin(Quoin q, String username) {
		Map map = {'collectQuoin': 'true', 'success': 'false', 'id': q.id};
		try {
			userSockets[username].add(JSON.encode(map));
		} catch (err) {
			log('(metabolics_endpoint_deny_quoin) Could not pass map $map to player $username: $err');
		}
	}

	static Future addQuoin(Quoin q, String username) async {
		Metabolics m = await getMetabolics(username: username);

		// Store "before" img
		int oldImg = m.lifetime_img;

		if (m.quoins_collected >= constants.quoinLimit) {
			// Daily quoin limit
			denyQuoin(q, username);
			return;
		}

		num amt;
		if (q.type != "mystery") {
			// Choose a number 1-5
			amt = rand.nextInt(4) + 1;
			// Multiply it by the player's quoin multiplier
			amt = (amt * m.quoin_multiplier).round();
			// Double if buffed
			if (await BuffManager.playerHasBuff("double_quoins", await User.getEmailFromUsername(username))) {
				amt *= 2;
			}
		} else {
			// Chose a number 0.01 i to 0.09 i
			amt = (rand.nextInt(9) + 1) / 100;
			// Add it to the player's quoin multiplier
			m.quoin_multiplier += amt;

			// Limit QM
			if (m.quoin_multiplier > constants.quoinMultiplierLimit) {
				m.quoin_multiplier = constants.quoinMultiplierLimit;
				String email = await User.getEmailFromUsername(username);
				// Add double quoins buff instead
				BuffManager.addToUser("double_quoins", email, StreetUpdateHandler.userSockets[email]);
			}
		}

		if (q.type == "quarazy") {
			amt *= 7;
		}

		if (q.type == 'currant') {
			m.currants += amt;
		}
		if (q.type == 'img' || q.type == 'quarazy') {
			m.img += amt;
			m.lifetime_img += amt;
		}
		if (q.type == 'mood') {
			if ((m.mood + amt) > m.max_mood) {
				amt = m.max_mood - m.mood;
			}
			m.mood += amt;
		}
		if (q.type == 'energy') {
			if ((m.energy + amt) > m.max_energy) {
				amt = m.max_energy - m.energy;
			}
			m.energy += amt;
		}
		if (q.type == "favor") {
			m.alphfavor += amt;
			if (m.alphfavor >= m.alphfavor_max) {
				m.alphfavor = m.alphfavor_max - 1;
			}

			m.cosmafavor += amt;
			if (m.cosmafavor >= m.cosmafavor_max) {
				m.cosmafavor = m.cosmafavor_max - 1;
			}

			m.friendlyfavor += amt;
			if (m.friendlyfavor >= m.friendlyfavor_max) {
				m.friendlyfavor = m.friendlyfavor_max - 1;
			}

			m.grendalinefavor += amt;
			if (m.grendalinefavor >= m.grendalinefavor_max) {
				m.grendalinefavor = m.grendalinefavor_max - 1;
			}

			m.humbabafavor += amt;
			if (m.humbabafavor >= m.humbabafavor_max) {
				m.humbabafavor = m.humbabafavor_max - 1;
			}

			m.lemfavor += amt;
			if (m.lemfavor >= m.lemfavor_max) {
				m.lemfavor = m.lemfavor_max - 1;
			}

			m.mabfavor += amt;
			if (m.mabfavor >= m.mabfavor_max) {
				m.mabfavor = m.mabfavor_max - 1;
			}

			m.potfavor += amt;
			if (m.potfavor >= m.potfavor_max) {
				m.potfavor = m.potfavor_max - 1;
			}

			m.sprigganfavor += amt;
			if (m.sprigganfavor >= m.sprigganfavor_max) {
				m.sprigganfavor = m.sprigganfavor_max - 1;
			}

			m.tiifavor += amt;
			if (m.tiifavor >= m.tiifavor_max) {
				m.tiifavor = m.tiifavor_max - 1;
			}

			m.zillefavor += amt;
			if (m.zillefavor >= m.zillefavor_max) {
				m.zillefavor = m.zillefavor_max - 1;
			}
		}

		if (amt > 0) {
			m.quoins_collected++;
		}

		// Compare "after" and "before" img
		if (getLevel(m.lifetime_img) > getLevel(oldImg)) {
			// Level up
			MetabolicsEndpoint.userSockets[username]?.add(JSON.encode({
				                                                          "levelUp": getLevel(m.lifetime_img)
			                                                          }));
		}

		try {
			int result = await setMetabolics(m);
			if (result > 0) {
				Map map = {'collectQuoin': 'true', 'id': q.id, 'amt': amt, 'quoinType': q.type};

				q.setCollected();

				userSockets[username].add(JSON.encode(map));
				userSockets[username].add(JSON.encode(encode(m)));
			}
		} catch (err) {
			log('(metabolics_endpoint_add_quoin) Could not set metabolics $m for player $username: $err');
		}
	}

	static void _calcAndSetMood(Metabolics m) {
		int max_mood = m.max_mood;
		num moodRatio = m.mood / max_mood;

		//determine how much mood they should lose based on current percentage of max
		//https://web.archive.org/web/20130106191352/http://www.glitch-strategy.com/wiki/Mood
		if (moodRatio < .5)
			m.mood -= (max_mood * .005).ceil();
		else if (moodRatio >= .5 && moodRatio < .81)
			m.mood -= (max_mood * .01).ceil();
		else
			m.mood -= (max_mood * .015).ceil();

		if (m.mood < 0) m.mood = 0;

		simulateMood = false;
	}

	static void _calcAndSetEnergy(Metabolics m) {
		//players lose .8% of their max energy every 90 seconds
		//https://web.archive.org/web/20120805062536/http://www.glitch-strategy.com/wiki/Energy
		m.energy -= (m.max_energy * .008).ceil();

		if (m.energy < 0) {
			m.energy = 0;
		}

		simulateEnergy = false;
	}
}


@app.Route('/getMetabolics')
@Encode()
Future<Metabolics> getMetabolics(
	{@app.QueryParam() String username, @app.QueryParam() String email, @app.QueryParam() int userId}) async {
	Metabolics metabolic = new Metabolics();

	PostgreSql dbConn = await dbManager.getConnection();
	try {
		String whereClause = "WHERE lower(users.username) = lower(@username)"; // case-insensitive
		if (email != null) {
			whereClause = "WHERE users.email = @email";
		}
		if (userId != null) {
			whereClause = "WHERE users.id = @userId";
		}
		String query = "SELECT * FROM metabolics JOIN users ON users.id = metabolics.user_id " + whereClause;
		List<Metabolics> metabolics =
		await dbConn.query(query, Metabolics, {'username': username, 'email': email, 'userId': userId});

		if (metabolics.length > 0) {
			metabolic = metabolics[0];
		} else {
			query = "SELECT * FROM users " + whereClause;
			var results = await dbConn.query(query, int, {'username': username, 'email': email, 'userId': userId});

			if (results.length > 0) {
				metabolic.user_id = results[0]['id'];
			}
		}
	} catch (e, st) {
		log('(getMetabolics): $e\n$st');
	} finally {
		dbManager.closeConnection(dbConn);
		return metabolic;
	}
}

@app.Route('/setMetabolics', methods: const [app.POST])
Future<int> setMetabolics(@Decode() Metabolics metabolics) async {
	int result = 0;

	// Check for level increase

	// Level before update
	Metabolics oldMetabolics = await getMetabolics(userId: metabolics.user_id);
	int levelStart = getLevel(oldMetabolics.lifetime_img);

	// Level after update
	int levelEnd = getLevel(metabolics.lifetime_img);

	// Compare
	if (levelEnd > levelStart) {
		// Refill energy if level increased (client handles popup checking)
		metabolics.energy = metabolics.max_energy;
	}

	// Do not overset the metabolics that have maxes

	if (metabolics.mood > metabolics.max_mood) {
		metabolics.mood = metabolics.max_mood;
	}

	if (metabolics.energy > metabolics.max_energy) {
		metabolics.energy = metabolics.max_energy;
	}

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

		result = await dbConn.execute(query, metabolics);

		//send the new metabolics to the user right away
		WebSocket ws = MetabolicsEndpoint.userSockets[await User.getUsernameFromId(metabolics.user_id)];
		ws?.add(JSON.encode(encode(metabolics)));
	} catch (e, st) {
		log('(setMetabolics): $e\n$st');
	} finally {
		dbManager.closeConnection(dbConn);
		return result;
	}
}