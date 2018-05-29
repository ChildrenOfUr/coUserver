library changeusername;

import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:redstone_mapper_pg/manager.dart';
import 'package:coUserver/common/util.dart';

// Returns 'OK', 'TAKEN', or 'ERR'
Future<String> changeUsername({
	String oldUsername, String newUsername, WebSocket userSocket, bool free: false})
async {
	final String OK = 'OK', TAKEN = 'TAKEN', ERR = 'ERR';

	// Verify data

	assert(oldUsername != null);
	assert(newUsername != null);

	oldUsername = oldUsername.trim();
	newUsername = newUsername.trim();

	if (oldUsername.length == 0 || newUsername.length == 0) {
		return ERR;
	}

	// Edit database

	PostgreSql dbConn = await dbManager.getConnection();

	final String takenQuery = 'SELECT id'
		' FROM users'
		' WHERE LOWER(username) = LOWER(@new)';

	final String usernameQuery = 'UPDATE users'
		' SET username = @new'
		' WHERE username = @old';

	final String currantsQuery = 'UPDATE metabolics'
		' SET currants = currants - 1000'
		' FROM users'
		' WHERE users.id = user_id'
		' AND username = @new';

	int takenRows, usernameRows, currantsRows;

	String result;

	try {
		// Check if taken

		takenRows = (await dbConn.query(
			takenQuery, int, {'new': newUsername})).length;

		if (takenRows > 0) {
			result = TAKEN;
			throw "Username $newUsername is already in use";
		}

		// Change username

		usernameRows = await dbConn.execute(
			usernameQuery, {'old': oldUsername, 'new': newUsername});

		if (usernameRows != 1) {
			result = ERR;
			throw "Incorrect number of rows ($usernameRows) updated";
		}

		// Charge currants

		if (!free) {
			currantsRows = await dbConn.execute(
				currantsQuery, {'new': newUsername});

			if (currantsRows != 1) {
				result = ERR;
				throw "Incorrect number of rows ($currantsRows) updated";
			}
		}

		result = OK;
	} catch (e, st) {
		Log.error('Could not change username from $oldUsername to $newUsername', e, st);
	} finally {
		dbManager.closeConnection(dbConn);

		// Send to client (if any)
		userSocket?.add(jsonEncode({
			'username_changed': result
		}));

		return result;
	}
}
