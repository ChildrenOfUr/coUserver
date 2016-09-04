library user;

import 'dart:async';

import 'package:redstone_mapper/mapper.dart';
import 'package:redstone_mapper_pg/manager.dart';

import 'package:coUserver/common/util.dart';

class User {
	@Field() int id;
	@Field() String username;
	@Field() String email;

	/// user-written, displayed on profile
	@Field() String bio;

	/// JSON list of achv ids
	@Field() String achievements;

	/// guide, dev, ?
	@Field() String elevation;

	/// override avatar with another username
	@Field() String custom_avatar;

	/// JSON list of user ids
	@Field() String friends;

	/// true means the user cannot use global
	@Field() bool chat_disabled;

	/// last client connection
	@Field() DateTime last_login;

	static Future<int> getIdFromUsername(String username) async         => (await findByUsername(username)).id;
	static Future<int> getIdFromEmail(String email) async               => (await findByEmail(email)).id;
	static Future<String> getUsernameFromId(int id) async               => (await findById(id)).username;
	static Future<String> getUsernameFromEmail(String email) async      => (await findByEmail(email)).username;
	static Future<String> getEmailFromUsername(String username) async   => (await findByUsername(username)).email;
	static Future<String> getEmailFromId(int id) async                  => (await findById(id)).email;

	static Future<User> findById(int id, [bool cacheOnly = false]) async {
		try {
			return _cache.singleWhere((User u) => u.id != null && u.id == id);
		} catch (_) {
			if (cacheOnly) {
				return null;
			}

			PostgreSql dbConn = await dbManager.getConnection();
			try {
				User user = (await dbConn.query(
					'SELECT * FROM users WHERE id = @id',
					User, {'id': id})).single;

				_addToCache(user);
				return user;
			} catch (e) {
				Log.warning('User <id=$id> not found', e);
				return new User();
			} finally {
				dbManager.closeConnection(dbConn);
			}
		}
	}

	static Future<User> findByUsername(String username, [bool cacheOnly = false, bool caseSensitive = true]) async {
		try {
			return _cache.singleWhere((User u) => u.username != null && u.username == username);
		} catch (_) {
			if (cacheOnly) {
				return null;
			}

			PostgreSql dbConn = await dbManager.getConnection();
			try {
				String usernameQuery = 'username = @username';
				if (!caseSensitive) {
					usernameQuery = 'LOWER(username) = LOWER(@username)';
				}

				User user = (await dbConn.query(
					'SELECT * FROM users WHERE $usernameQuery',
					User, {'username': username})).single;

				_addToCache(user);
				return user;
			} catch (e) {
				Log.warning('User <username=$username> not found', e);
				return new User();
			} finally {
				dbManager.closeConnection(dbConn);
			}
		}
	}

	static Future<User> findByEmail(String email, [bool cacheOnly = false]) async {
		try {
			return _cache.singleWhere((User u) => u.email != null && u.email == email);
		} catch (_) {
			if (cacheOnly) {
				return null;
			}

			PostgreSql dbConn = await dbManager.getConnection();
			try {
				User user = (await dbConn.query(
					'SELECT * FROM users WHERE email = @email',
					User, {'email': email})).single;

				_addToCache(user);
				return user;
			} catch (e) {
				Log.warning('User <email=$email> not found', e);
				return new User();
			} finally {
				dbManager.closeConnection(dbConn);
			}
		}
	}

	static void uncache({int id, String username, String email}) {
		List<User> copy = new List.from(_cache);
		_cache.forEach((User user) {
			if (id != null && user.id == id) {
				copy.remove(user);
			}

			if (username != null && user.username == username) {
				copy.remove(user);
			}

			if (email != null && user.email == email) {
				copy.remove(user);
			}
		});
		_cache = copy;
	}

	static List<User> _cache = [];

	static Future _addToCache(User user) async {
		// Find any possible duplicates
		User byId = await findById(user.id, true);
		User byUsername = await findByUsername(user.username, true);
		User byEmail = await findByEmail(user.email, true);

		// Use them to fill in any missing fields
		_cache
			..remove(byId)
			..remove(byUsername)
			..remove(byEmail);

		// Store the resulting user
		_cache.add(_mergeUsers([user, byId, byUsername, byEmail]));
	}

	/// Combine fields from all users to fill in any missing data.
	/// Users earlier in the list will have priority in the case of duplicates.
	static User _mergeUsers(List<User> users) {
		User merged = new User();

		for (User user in users) {
			if (user == null) {
				continue;
			}

			merged
				..id = merged.id ?? user.id
				..username = merged.username ?? user.username
				..email = merged.email ?? user.email
				..bio = merged.bio ?? user.bio
				..achievements = merged.achievements ?? user.achievements
				..elevation = merged.elevation ?? user.elevation
				..custom_avatar = merged.custom_avatar ?? user.custom_avatar
				..friends = merged.friends ?? user.friends
				..chat_disabled = merged.chat_disabled ?? user.chat_disabled
				..last_login = merged.last_login ?? user.last_login;
		}

		return merged;
	}
}
