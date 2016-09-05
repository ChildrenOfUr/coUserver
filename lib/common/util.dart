library util;

import 'dart:async';
import 'dart:io';
import 'dart:convert';
import 'dart:mirrors';
import 'dart:math';

import 'package:message_bus/message_bus.dart';
import 'package:http/http.dart' as http;
import 'package:image/image.dart';
import 'package:redstone/redstone.dart' as app;
import 'package:redstone_mapper_pg/manager.dart';

import 'package:coUserver/API_KEYS.dart';
import 'package:coUserver/common/log/log.dart';
import 'package:coUserver/common/user.dart';
import 'package:coUserver/streets/street_update_handler.dart';

export 'package:coUserver/common/log/log.dart';
export 'package:coUserver/entities/street_entities/street_entities.dart';

part 'filecaching.dart';
part '../endpoints/images.dart';

/// Global PSQL manager
PostgreSqlManager dbManager = new PostgreSqlManager(databaseUri);

/// Database connection for redstone requests
PostgreSql get dbConn => app.request.attributes.dbConn;

/// Global message bus
MessageBus messageBus = new MessageBus();

/// Minimum client version to allow connections from
final int MIN_CLIENT_VER = 145;

/// Global random object
Random rand = new Random();

/// Get a TSID in 'G...' (CAT422) form
String tsidG(String tsid) {
	return tsidL(tsid).replaceFirst('L', 'G');
}

/// Get a TSID in 'L...' (TS) form
String tsidL(String tsid) {
	if (tsid == null) {
		return tsid;
	}

	if (tsid.startsWith('G')) {
		// In CAT422 form
		return tsid.replaceFirst('G', 'L');
	} else {
		// Assume in TS form
		return tsid;
	}
}

/// Capitalize the first letter of a string
String ucfirst(String str) {
	return str.substring(0, 1).toUpperCase() + str.substring(1);
}

/// "ClassName" -> "Class Name"
String splitCamelCase(String camelCase) {
	String spaceCase = "";
	for (int c = 0; c < camelCase.length; c++) {
		spaceCase += camelCase[c];
		if (
			// not at end
			c < camelCase.length - 1 &&
			// next letter is uppercase
			camelCase[c + 1].toUpperCase() == camelCase[c + 1]
		) {
			spaceCase += ' ';
		}
	}
	return spaceCase;
}

/**
	Taken from https://stackoverflow.com/questions/20207855/in-dart-given-a-type-name-how-do-you-get-the-type-class-itself/20450672#20450672

	This method will return a ClassMirror for a class whose name exactly matches the string provided.

	In the event that a class matching that name does not exist, it will throw an ArgumentError
*/
ClassMirror findClassMirror(String name) {
	for (LibraryMirror lib in currentMirrorSystem().libraries.values) {
		DeclarationMirror mirror = lib.declarations[MirrorSystem.getSymbol(name)];
		if (mirror != null)
			return mirror;
	}
	throw new ArgumentError('Class $name does not exist');
}

/// Tell a client to display a toast
void toast(String message, WebSocket userSocket, {bool skipChat, String onClick}) {
	userSocket.add(JSON.encode({
       'toast': true,
       'message': message,
       'skipChat': skipChat,
       'onClick': onClick
	}));
}

/// Tell a client to play a sound
void playSound(String sound, WebSocket userSocket) {
	userSocket.add(JSON.encode({
		'playSound': true,
		'sound': sound
	}));
}

Map<String, Function> promptCallbacks = {};

/// Ask a user for a string
/// Pass a unique value for `reference` so that the response is routed correctly.
/// `callback` will be called with the following positional args:
///     1. reference
///     2. user's response
void promptString(String prompt, WebSocket userSocket, String reference, Function callback) {
	promptCallbacks[reference] = callback;

	userSocket.add(JSON.encode({
		'promptString': true,
		'promptText': prompt,
		'promptRef': reference
	}));
}

/**
	Anything that should run here as cleanup before exit
	This will also shut down the server unless exitCode is negative
	Doesn't seem to work with webstorm's stop process button (must send SIGKILL)
*/
Future cleanup([int exitCode = 0]) async {
	// Persist the state of each loaded street to the database
	await Future.forEach(StreetUpdateHandler.streets.keys, (String label) async {
		Log.info('[Cleanup] Persisting $label before shutdown');
		await StreetUpdateHandler.streets[label]?.persistState();
	});

	if (exitCode >= 0) {
		exit(exitCode);
	}
}

/// Get a reference to the coUserver directory
Directory get serverDir {
	String directory;

	if (Platform.script.data != null) {
		directory = Directory.current.path;
	} else {
		directory = Platform.script.toFilePath();
		directory = directory.substring(0, directory.lastIndexOf(Platform.pathSeparator));
	}

	// Run tests in server directory
	directory = directory.replaceAll('coUserver/test','coUserver');

	return new Directory(directory);
}
