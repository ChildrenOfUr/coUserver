library login_date_tracker;

import 'dart:async';

import 'package:coUserver/common/util.dart';

import 'package:redstone/redstone.dart' as app;
import 'package:redstone_mapper_pg/manager.dart';

/// Login dates are in UTC!

@app.Group("/logindatetracker")
class LoginDateTracker {
	/// {username: date}
	static Map<String, DateTime> _cache = new Map();

	static Future<bool> update(String username) async {
		DateTime newDate = new DateTime.now().toUtc();
		PostgreSql dbConn = await dbManager.getConnection();

		try {
			int rows = await dbConn.execute(
				"UPDATE users SET last_login = @now WHERE username = @username",
				{"now": newDate, "username": username}
			);
			_cache[username] = newDate;
			return (rows == 1);
		} catch(e) {
			log("Error setting last login date for $username: $e");
			return false;
		} finally {
			dbManager.closeConnection(dbConn);
		}
	}

	static Future<DateTime> getDate(String username) async {
		if (_cache[username] != null) {
			// Already in cache
			return _cache[username];
		} else {
			// Check database and save to cache
			PostgreSql dbConn = await dbManager.getConnection();

			try {
				DateTime lastlogin = (await dbConn.query(
					"SELECT last_login FROM users WHERE username = @username", DateTime,
					{"username": username}
				)).first["last_login"];
				return lastlogin;
			} catch(e) {
				log("Error getting last login date for $username: $e");
				return null;
			} finally {
				dbManager.closeConnection(dbConn);
			}
		}
	}

	@app.Route("/get/:username")
	Future<String> get(String username) async => (await getDate(username) ?? "never").toString();

	@app.Route("/getSlack")
	Future<String> getSlack(@app.QueryParam("text") String text) async => await get(text.trim());
}