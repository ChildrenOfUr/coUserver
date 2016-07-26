library achievements;

import 'dart:async';
import 'dart:io';
import 'dart:convert';

import 'package:coUserver/achievements/stats.dart';
import 'package:coUserver/common/mapdata/mapdata.dart';
import 'package:coUserver/common/user.dart';
import 'package:coUserver/common/util.dart';
import 'package:coUserver/skills/skillsmanager.dart';
import 'package:coUserver/streets/street_update_handler.dart';

import 'package:path/path.dart' as path;
import 'package:redstone_mapper_pg/manager.dart';
import 'package:redstone_mapper/mapper.dart';
import 'package:redstone/redstone.dart' as app;

part 'achievement_checkers.dart';
part 'statsbased.dart';

class AchievementAward {
	String email;
	Map achieveMap;

	AchievementAward(this.email, this.achieveMap);
}

class Achievement {
	static Map<String, Achievement> _ACHIEVEMENTS = new Map();

	static Future<int> load() async {
		Directory json = new Directory(path.join(serverDir.path, 'lib', 'achievements', 'json'));
		List<FileSystemEntity> categories = json.listSync();

		await Future.forEach(categories, (File category) async {
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

		Log.verbose('[Achievement] Loaded ${_ACHIEVEMENTS.length} achievements');
		return _ACHIEVEMENTS.length;
	}

	static Achievement find(String id) =>  _ACHIEVEMENTS[id];

	@Field() String id;
	@Field() String name;
	@Field() String description;
	@Field() String category;
	@Field() String imageUrl;

	String toString() {
		return "<Achievement id=$id name=$name description=$description category=$category imageUrl=$imageUrl>";
	}

	Map<String, dynamic> toMap() => {
		"id": id,
		"name": name,
		"description": description,
		"category": category,
		"imageUrl": imageUrl
	};

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
		} catch (e, st) {
			Log.error('Error getting achievements for <email=$email>', e, st);
			return false;
		} finally {
			dbManager.closeConnection(dbConn);
		}
	}

	Future<bool> awardTo(String email) async {
		if (!isSetUp || await awardedTo(email)) {
			return false;
		}

		bool result = false;

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
				StreetUpdateHandler.userSockets[email]?.add(JSON.encode({
					"achv_id": id,
					"achv_name": name,
					"achv_description": description,
					"achv_imageUrl": imageUrl
				}));

				result = true;
			} else {
				result = false;
			}
		} catch (e, st) {
			Log.error('Error setting achievements for <email=$email>', e, st);
			result = false;
		} finally {
			dbManager.closeConnection(dbConn);
		}

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
		} catch (e, st) {
			Log.error('Error getting achievements for <email=${email ?? username}>', e, st);
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
