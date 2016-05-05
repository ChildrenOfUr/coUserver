library achievements;

import 'dart:async';
import 'dart:io';
import 'dart:convert';

import 'package:coUserver/common/util.dart';
import 'package:coUserver/common/user.dart';
import 'package:coUserver/endpoints/stats.dart';
import 'package:coUserver/common/mapdata/mapdata.dart';
import 'package:coUserver/street_update_handler.dart';
import 'package:coUserver/skills/skillsmanager.dart';

import 'package:path/path.dart' as path;
import 'package:redstone_mapper/mapper.dart';
import 'package:redstone/redstone.dart' as app;
import 'package:redstone_mapper_pg/manager.dart';
import 'package:harvest/harvest.dart' as harvest;

part 'achievement_checkers.dart';
part 'statsbased.dart';

class AchievementAward extends harvest.Message {
	String email;
	Map achieveMap;

	AchievementAward(this.email, this.achieveMap);
}

class Achievement {
	static Map<String, Achievement> _ACHIEVEMENTS = {};

	static Future load() async {
		String directory;
		//this happens when running unit tests
		if(Platform.script.data != null) {
			directory = Directory.current.path;
		} else {
			directory = Platform.script.toFilePath();
			directory = directory.substring(0, directory.lastIndexOf(Platform.pathSeparator));
		}

		directory = directory.replaceAll('coUserver/test','coUserver');

		await new Directory(path.join(directory, 'lib', 'achievements', 'json')).list().forEach((File category) async {
			await JSON.decode(await category.readAsString()).forEach((String id, Map data) async {
				Achievement achievement = new Achievement(
					id: id,
					name: data["name"],
					description: data["description"],
					category: data["category"],
					imageUrl: data["imageUrl"]
					);
				_ACHIEVEMENTS[id] = achievement;
			});
		});
	}

	static Achievement find(String id) {
		return _ACHIEVEMENTS[id];
	}

	static Map<String, int> queuedWrites = {};

	@Field() String id;
	@Field() String name;
	@Field() String description;
	@Field() String category;
	@Field() String imageUrl;

	String toString() {
		return "<Achievement id=$id name=$name description=$description category=$category imageUrl=$imageUrl>";
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

	bool get isSetUp {
		return (
			id != null && name != null && description != null && category != null && imageUrl != null
		);
	}

	Future<bool> awardedTo(String email) async {
		if (!isSetUp) {
			return false;
		}

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
		if (!isSetUp || await awardedTo(email)) {
			return false;
		}

		queuedWrites[email] = ((queuedWrites[email] ?? 0) + 1).clamp(0, 60);

		bool result = false;

		await new Timer(new Duration(seconds: queuedWrites[email].abs()), () async {
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
					// Send to client
					StreetUpdateHandler.userSockets[email]?.add(JSON.encode(
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

				queuedWrites[email] = ((queuedWrites[email] ?? 0) - 1).clamp(0, 60);
			} catch (e) {
				log("Error setting achievements for email $email: $e");
				result = false;
			} finally {
				dbManager.closeConnection(dbConn);
			}
		});

		return result;
	}

	static String cachedAchvListJson;
}

@app.Route("/listAchievements")
Future<String> listAchievements(
	@app.QueryParam("email") String email,
	@app.QueryParam("category") String category,
	@app.QueryParam("username") String username,
	@app.QueryParam("excludeNonMatches") bool excludeNonMatches) async {
	bool generic = false;

	if (email == null && category == null && username == null && excludeNonMatches == null) {
		generic = true;
		// Generic request
		if (Achievement.cachedAchvListJson != null) {
			return Achievement.cachedAchvListJson;
		}
	}

	List<String> ids = [];
	List<String> awardedIds = [];
	Map<String, Map<String, dynamic>> maps = {};

	ids = Achievement._ACHIEVEMENTS.keys.toList();

	if ((email != null || username != null) || !(excludeNonMatches ?? true)) {
		// Email or username provided, find their awarded achievements
		// OR
		// Including non matches, need something to match against
		PostgreSql dbConn = await dbManager.getConnection();
		try {
			String query = "SELECT achievements FROM users WHERE ";
			Map data = new Map();
			if (email != null) {
				query += "email = @email";
				data = {"email": email};
			} else if (username != null) {
				query += "username = @username";
				data = {"username": username};
			} else {
				return '{}';
			}
			awardedIds = JSON.decode((await dbConn.query(query, User, data)).first.achievements);
		} catch (e) {
			log("Error getting achievements for email ${email ?? username}: $e");
			return '{}';
		} finally {
			dbManager.closeConnection(dbConn);
		}
	}

	if (email == null && username == null) {
		// List ALL achievements
		for(String id in ids) {
			Achievement achv = Achievement.find(id);
			if(category != null) {
				if(achv.category != category) {
					continue;
				}
			}
			maps.addAll({achv.id: achv.toMap()});
		}
	} else {
		// List AWARDED achievements (or all with marked matches)
		if (!(excludeNonMatches ?? true)) {
			// Include all, but mark matches
			for(String id in ids) {
				Achievement achv = Achievement.find(id);
				if(category != null) {
					if(achv.category != category) {
						continue;
					}
				}
				Map achvMap = achv.toMap();
				achvMap.addAll({"awarded": (awardedIds.contains(id).toString())});
				maps.addAll({achv.id: achvMap});
			}
		} else {
			// Include only awarded
			for(String id in awardedIds) {
				Achievement achv = Achievement.find(id);
				if(category != null) {
					if(achv.category != category) {
						continue;
					}
				}
				maps[id] = {id:achv.toMap()};
			}
		}
	}

	String result = JSON.encode(maps);

	if (generic && Achievement.cachedAchvListJson == null) {
		Achievement.cachedAchvListJson = result;
	}

	return result;
}