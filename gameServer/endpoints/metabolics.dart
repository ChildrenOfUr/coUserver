part of coUserver;

class Metabolics {
	@Field()
	int id;

	@Field()
	int mood = 50;

	@Field()
	int max_mood = 100;

	@Field()
	int energy = 50;

	@Field()
	int max_energy = 100;

	@Field()
	int currants = 0;

	@Field()
	int img = 0;

	@Field()
	int lifetime_img = 0;

	@Field()
	String current_street = 'LA58KK7B9O522PC';

	@Field()
	String undead_street = null;

	set dead(bool value) {
		if (value) {
			// Die
			undead_street = current_street;
			energy = 0;
			mood = 0;
		} else {
			// Revive
			undead_street = null;
			energy = max_energy;
			mood = max_mood;
		}
	}

	@Field()
	num current_street_x = 1.0;

	@Field()
	num current_street_y = 0.0;

	@Field()
	int user_id = -1;

	@Field()
	int alphfavor = 0;
	@Field()
	int alphfavor_max = 1000;
	@Field()
	int cosmafavor = 0;
	@Field()
	int cosmafavor_max = 1000;
	@Field()
	int friendlyfavor = 0;
	@Field()
	int friendlyfavor_max = 1000;
	@Field()
	int grendalinefavor = 0;
	@Field()
	int grendalinefavor_max = 1000;
	@Field()
	int humbabafavor = 0;
	@Field()
	int humbabafavor_max = 1000;
	@Field()
	int lemfavor = 0;
	@Field()
	int lemfavor_max = 1000;
	@Field()
	int mabfavor = 0;
	@Field()
	int mabfavor_max = 1000;
	@Field()
	int potfavor = 0;
	@Field()
	int potfavor_max = 1000;
	@Field()
	int sprigganfavor = 0;
	@Field()
	int sprigganfavor_max = 1000;
	@Field()
	int tiifavor = 0;
	@Field()
	int tiifavor_max = 1000;
	@Field()
	int zillefavor = 0;
	@Field()
	int zillefavor_max = 1000;

	@Field()
	String location_history = '[]';

	@Field()
	int quoins_collected = 0;

	@Field()
	num quoin_multiplier = 1;
}

class MetabolicsEndpoint {
	static bool simulateMood = false, simulateEnergy = false;
	static Timer moodTimer = new Timer.periodic(new Duration(seconds: 60), (Timer timer) => simulateMood = true);
	static Timer energyTimer = new Timer.periodic(new Duration(seconds: 90), (Timer timer) => simulateEnergy = true);
	static Timer simulateTimer = new Timer.periodic(new Duration(seconds: 5), (Timer timer) => simulate());
	static Map<String, WebSocket> userSockets = {};
	static Random rand = new Random();

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
		onError: (error) => cleanupList(ws),
		onDone: () => cleanupList(ws));
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
		userSockets.forEach((String username, WebSocket ws) async
		{
			try {
				Metabolics m = await getMetabolics(username:username);

				if (simulateMood) {
					_calcAndSetMood(m);
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
			}
			catch (e, st) {
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
		} else if (m.energy >= 10 && m.undead_street != null) {
			// Not dead (at least 10 energy), but in Hell
			Map<String, String> map = {
				"gotoStreet": "true",
				"tsid": m.undead_street // Street where they died
			};
			m.dead = false;
			userIdentifier.webSocket.add(JSON.encode(map));
		}
	}

	static Future<bool> addToLocationHistory(String username, String TSID) async {
		Metabolics m = await getMetabolics(username:username);
		List<String> locations = JSON.decode(m.location_history);

		// If it's not already in the history
		if (!locations.contains(TSID)) {
			locations.add(TSID);
			m.location_history = JSON.encode(locations);
			int result = await setMetabolics(m);
			return (result > 0);
		} else {
			return false;
		}
	}

	static denyQuoin(Quoin q, String username) {
		Map map = {'collectQuoin':'true',
			'success':'false',
			'id':q.id};
		try {
			userSockets[username].add(JSON.encode(map));
		}
		catch (err) {
			log('(metabolics_endpoint_deny_quoin) Could not pass map $map to player $username: $err');
		}
	}

	static Future addQuoin(Quoin q, String username) async {
		Metabolics m = await getMetabolics(username:username);

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
		} else {
			// Chose a number 0.01 i to 0.09 i
			amt = (rand.nextInt(9) + 1) / 100;
			// Add it to the player's quoin multiplier
			m.quoin_multiplier += amt;

			// Limit QM
			if (m.quoin_multiplier > constants.quoinMultiplierLimit) {
				m.quoin_multiplier = constants.quoinMultiplierLimit;
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

		try {
			int result = await setMetabolics(m);
			if (result > 0) {
				Map map = {'collectQuoin':'true',
					'id':q.id,
					'amt':amt,
					'quoinType':q.type};

				q.setCollected();

				userSockets[username].add(JSON.encode(map));
				userSockets[username].add(JSON.encode(encode(m)));
			}
		}
		catch (err) {
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

		if (m.mood < 0)
			m.mood = 0;

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
Future<Metabolics> getMetabolics({@app.QueryParam() String username, @app.QueryParam() String email, @app.QueryParam() int userId}) async {
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
		List<Metabolics> metabolics = await dbConn.query(query, Metabolics, {'username':username, 'email':email, 'userId': userId});

		if (metabolics.length > 0) {
			metabolic = metabolics[0];
		} else {
			query = "SELECT * FROM users " + whereClause;
			var results = await dbConn.query(query, int, {'username':username, 'email':email});

			if (results.length > 0) {
				metabolic.user_id = results[0]['id'];
			}
		}

		dbManager.closeConnection(dbConn);
	} catch (e, st) {
		if (dbConn != null) {
			dbManager.closeConnection(dbConn);
		}
		log('(getMetabolics): $e\n$st');
	} finally {
		return metabolic;
	}
}

@app.Route('/setMetabolics', methods:const[app.POST])
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

		dbManager.closeConnection(dbConn);
	}
	catch (e, st) {
		if (dbConn != null) {
			dbManager.closeConnection(dbConn);
		}
		log('(setMetabolics): $e\n$st');
	} finally {
		return result;
	}
}

// LEVELS

//Map<int, int> scaleLevels([num sf = 1.37]) {
//	Map<int, num> scale = {
//		1: 0
//	};
//	int base = 100;
//	for (int i = 1; i <= 60; i++) {
//		scale.addAll(({i: base}));
//		base = (base * sf).round();
//	}
//	return scale;
//}

Map <int, int> imgLevels = {
	1: 100,
	2: 137,
	3: 188,
	4: 258,
	5: 353,
	6: 484,
	7: 663,
	8: 908,
	9: 1244,
	10: 1704,
	11: 2334,
	12: 3198,
	13: 4381,
	14: 6002,
	15: 8223,
	16: 11266,
	17: 15434,
	18: 21145,
	19: 28969,
	20: 39688,
	21: 54373,
	22: 74491,
	23: 102053,
	24: 139813,
	25: 191544,
	26: 262415,
	27: 359509,
	28: 492527,
	29: 674762,
	30: 924424,
	31: 1266461,
	32: 1735052,
	33: 2377021,
	34: 3256519,
	35: 4461431,
	36: 6112160,
	37: 8373659,
	38: 11471913,
	39: 15716521,
	40: 21531634,
	41: 29498339,
	42: 40412724,
	43: 55365432,
	44: 75850642,
	45: 103915380,
	46: 142364071,
	47: 195038777,
	48: 267203124,
	49: 366068280,
	50: 501513544,
	51: 687073555,
	52: 941290770,
	53: 1289568355,
	54: 1766708646,
	55: 2420390845,
	56: 3315935458,
	57: 4542831577,
	58: 6223679260,
	59: 8526440586,
	60: 11681223603
};

@app.Route("/getLevel")
int getLevel(@app.QueryParam("img") int img) {
	int result;

	if (img >= imgLevels[60]) {
		result = 60;
	} else {
		for (int data_lvl in imgLevels.keys) {
			int data_lvl_img = imgLevels[data_lvl];

			if (img < data_lvl_img) {
				result = data_lvl - 1;
				break;
			}
		}
	}

	return result;
}

@app.Route("/getImgForLevel")
int getImgForLevel(@app.QueryParam("level") int lvl) {
	if (lvl > 0 && lvl <= 60) {
		return imgLevels[lvl];
	} else {
		return -1;
	}
}
