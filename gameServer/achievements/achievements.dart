part of coUserver;

class Achievement {
	static Map<String, Achievement> ACHIEVEMENTS = {};

	static Future load() async {
		String directory = Platform.script.toFilePath();
		directory = directory.substring(0, directory.lastIndexOf("/"));

		await new Directory("$directory/gameServer/achievements/json").list().forEach((
		  File category) async {
			await JSON.decode(await category.readAsString()).forEach((String id, Map data) async {
				Achievement achievement = new Achievement(
				  id: id,
				  name: data["name"],
				  description: data["description"],
				  category: data["category"],
				  imageUrl: data["imageUrl"]
				);
				ACHIEVEMENTS[id] = achievement;
			});
		});
	}

	static Achievement find(String id) {
		return ACHIEVEMENTS[id];
	}

	static int queuedWrites = 0;

	@Field() String id;
	@Field() String name;
	@Field() String description;
	@Field() String category;
	@Field() String imageUrl;

	String toString() {
		return "<Achievement id=$id name=$name description=$description category=$category imageUrl=$imageUrl related=${related
		  .length}>";
	}

	Map<String, dynamic> toMap() {
		return ({
			"id": id,
			"name": name,
			"description": description,
			"category": category,
			"imageUrl": imageUrl
		});
	}

	Achievement({
	this.id,
	this.name,
	this.description,
	this.category,
	this.imageUrl
	});

	Future<bool> awardedTo(String email) async {
		PostgreSql dbConn = await dbManager.getConnection();
		try {
			return (
			  (await dbConn.query(
				"SELECT achievements FROM users WHERE email = @email",
				User, {"email": email})
			  ).first.achievements.contains(id)
			);
		} catch (e) {
			log("Error getting achievements for email $email: $e");
			return false;
		} finally {
			dbManager.closeConnection(dbConn);
		}
	}

	Future<bool> awardTo(String email) async {
		if (await awardedTo(email)) {
			return false;
		}

		queuedWrites++;

		bool result = false;

		await new Timer(new Duration(seconds: queuedWrites), () async {
			PostgreSql dbConn = await dbManager.getConnection();
			try {
				String oldJson = (await dbConn.query(
				  "SELECT achievements FROM users WHERE email = @email",
				  User, {"email": email})).first.achievements;

				List<String> achievementIds = JSON.decode(oldJson);
				achievementIds.add(id);

				String newJson = JSON.encode(achievementIds);

				if (
				(await dbConn.execute(
				  "UPDATE users SET achievements = @json WHERE email = @email",
				  {"email": email, "json": newJson})
				) == 1
				) {
					// Send to client
					StreetUpdateHandler.userSockets[email].add(JSON.encode(
					  {
						  "achv_id": id,
						  "achv_name": name,
						  "achv_description": description,
						  "achv_imageUrl": imageUrl
					  }
					));

					result = true;
				} else {
					log("Database did not correctly save new achievements for $email");
					result = false;
				}

				queuedWrites--;
			} catch (e) {
				log("Error setting achievements for email $email: $e");
				result = false;
			} finally {
				dbManager.closeConnection(dbConn);
			}
		});

		return result;
	}
}

@app.Route("/listAchievements")
Future<String> listAchievements(@app.QueryParam("email") String email, @app.QueryParam("excludeNonMatches") bool excludeNonMatches) async {
	List<String> ids = [];
	List<String> awardedIds = [];
	Map<String, Map<String, dynamic>> maps = {};

	ids = Achievement.ACHIEVEMENTS.keys.toList();

	if (email != null || !(excludeNonMatches ?? true)) {
		// Email provided, find their awarded achievements
		// OR
		// Including non matches, need something to match against
		PostgreSql dbConn = await dbManager.getConnection();
		try {
			awardedIds = JSON.decode(
			  (await dbConn.query(
				"SELECT achievements FROM users WHERE email = @email",
				User, {"email": email})
			  ).first.achievements
			);
		} catch (e) {
			log("Error getting achievements for email $email: $e");
			return "[]";
		} finally {
			dbManager.closeConnection(dbConn);
		}
	}

	if (email == null) {
		// List ALL achievements
		ids.forEach((String id) {
			Achievement achv = Achievement.find(id);
			maps.addAll({achv.id: achv.toMap()});
		});
	} else {
		// List AWARDED achievements (or all with marked matches)
		if (!(excludeNonMatches ?? true)) {
			// Include all, but mark matches
			ids.forEach((String id) {
				Achievement achv = Achievement.find(id);
				Map achvMap = achv.toMap();
				achvMap.addAll({"awarded": (awardedIds.contains(id).toString())});
				maps.addAll({achv.id: achvMap});
			});
		} else {
			// Include only awarded
			awardedIds.forEach((String id) {
				Achievement achv = Achievement.find(id);
				maps.addAll({achv.id: achv.toMap()});
			});
		}
	}

	return JSON.encode(maps);
}