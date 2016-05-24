library util;

import 'dart:async';
import 'dart:io';
import 'dart:convert';
import 'dart:mirrors';
import 'dart:math' hide log;

import 'package:coUserver/entities/items/item.dart';
import 'package:coUserver/API_KEYS.dart';

import 'package:redstone/redstone.dart' as app;
import 'package:image/image.dart';
import 'package:http/http.dart' as http;
import 'package:crypto/crypto.dart';
import 'package:redstone_mapper_pg/manager.dart';
import 'package:redstone_mapper/mapper.dart';
import 'package:harvest/harvest.dart' as harvest;

part 'package:coUserver/common/streetEntities.dart';

Map<String, int> heightsCache = null;
Map<String, String> headsCache = null;
Map<String, Item> items = {};
PostgreSqlManager dbManager = new PostgreSqlManager(databaseUri);

PostgreSql get dbConn => app.request.attributes.dbConn;
harvest.MessageBus messageBus = new harvest.MessageBus.async();
double minClientVersion = 0.15;
DateTime startDate;
Map<String, String> vendorTypes = {};
Random rand = new Random();

Future migrateEntities() async {
	Directory streetEntities = new Directory("./streetEntities");
	List<FileSystemEntity> files = streetEntities.listSync();

	int count = 0;

	Future.forEach(files, (FileSystemEntity file) async {
		if (file is File) {
			String tsid = file.uri.pathSegments.last;
			String json = await file.readAsString();
			try {
				log("Migrating $tsid...");
				Map<String, dynamic> map = JSON.decode(json);
				Future.forEach(map["entities"], (Map<String, dynamic> entity) async {
					await StreetEntities.setEntity(new StreetEntity(
						id: "migrate$count",
						type: entity["type"],
						tsid: tsid,
						x: entity["x"],
						y: entity["y"]
					));
					count++;
				});
			} catch(e) {
				log("    Error migrating $tsid: $e");
			}
		}
	});
}

String tsidG(String tsid) => tsid.startsWith("L") ? tsid.replaceFirst("L", "G") : tsid;

String tsidL(String tsid) => tsidG(tsid).replaceFirst("G", "L");

saveStreetData(Map params) {
	String tsid = params['tsid'];
	tsid = tsidL(tsid);

	List entities = JSON.decode(params['entities']);
	File file = new File('./streetEntities/$tsid');
	if (file.existsSync()) {
		Map oldFile = JSON.decode(file.readAsStringSync());
		//backup the older file and replace it with this new file
		File backup = new File('./streetEntities/$tsid.bak');
		if (backup.existsSync()) {
			Map oldData = JSON.decode(backup.readAsStringSync());
			List backups = oldData['backups'];
			backups.add({new DateTime.now().toIso8601String():oldFile});
			backup.writeAsStringSync(JSON.encode({'backups':backups}));
		}
		else {
			backup.createSync(recursive: true);
			Map oldData = {'backups':[{new DateTime.now().toIso8601String():oldFile}]};
			backup.writeAsStringSync(JSON.encode(oldData));
		}
	}
	else
		file.createSync(recursive: true);

	file.writeAsStringSync(JSON.encode({'entities':entities}));


	//save a list of finished and partially finished streets
	File finished = _getFinishedFile();
	Map finishedMap = JSON.decode(finished.readAsStringSync());
	int required = int.parse(params['required']);
	int complete = int.parse(params['complete']);
	bool streetFinished = (required - complete == 0) ? true : false;
	finishedMap[tsid] = {"entitiesRequired":params['required'],
		"entitiesComplete":params['complete'],
		"streetFinished":streetFinished};
	finished.writeAsStringSync(JSON.encode(finishedMap));
}

void reportBrokenStreet(String tsid, String reason) {
	if (tsid == null)
		return;

	tsid = tsidL(tsid);

	File finished = _getFinishedFile();
	Map finishedMap = JSON.decode(finished.readAsStringSync());
	Map street = {};
	if (finishedMap[tsid] != null) {
		street = finishedMap[tsid];
		street['reported$reason'] = true;
		finishedMap[tsid] = street;
	}
	else {
		finishedMap[tsid] = {"entitiesRequired":-1,
			"entitiesComplete":-1,
			"streetFinished":false,
			"reported$reason":true};
	}
	finished.writeAsStringSync(JSON.encode(finishedMap));
}

File _getFinishedFile() {
	File finished = new File('./streetEntities/finished.json');
	if (!finished.existsSync())
		_createFinishedFile();

	return finished;
}

void _createFinishedFile() {
	File finished = new File('./streetEntities/finished.json');
	finished.createSync(recursive: true);
	//insert any streets that were finished before this file was created
	Directory streetEntities = new Directory('./streetEntities');
	Map finishedMap = {};
	for (FileSystemEntity entity in streetEntities.listSync(recursive: true)) {
		String filename = entity.path.substring(entity.path.lastIndexOf(Platform.pathSeparator) + 1);
		if (!filename.contains('.')) {
			//we'll assume it's incomplete
			finishedMap[filename] = {"entitiesRequired":0,
				"entitiesComplete":0,
				"streetFinished":false};
		}
	}
	finished.writeAsStringSync(JSON.encode(finishedMap));
}

String getTsidOfUnfilledStreet() {
	String tsid = null;

	File file = new File('./streetEntities/streets.json');
	File finished = new File('./streetEntities/finished.json');

	if (!finished.existsSync())
		_createFinishedFile();

	if (!file.existsSync())
		return tsid;

	Map streets = JSON.decode(file.readAsStringSync());
	Map finishedMap = JSON.decode(finished.readAsStringSync());

	//loop through streets to find one that is not finished
	//if they are all finished, take one that is not complete
	String incomplete = null;
	List<String> streetsList = streets.keys.toList();
	streetsList.shuffle();
	for (String t in streetsList) {
		if (!finishedMap.containsKey(t)) {
			tsid = t;
			break;
		}
		else if (!finishedMap[t]['streetFinished'] && !finishedMap[t]['reportedBroken']
		         && !finishedMap[t]['reportedVandalized'] && !finishedMap[t]['reportedFinished'])
			incomplete = t;
	}

	//tsid may still be null after this
	if (tsid == null)
		tsid = incomplete;

	return tsid;
}

/**
 * Taken from https://stackoverflow.com/questions/20207855/in-dart-given-a-type-name-how-do-you-get-the-type-class-itself/20450672#20450672
 *
 * This method will return a ClassMirror for a class whose name
 * exactly matches the string provided.
 *
 * In the event that a class matching that name does not exist, it will throw
 * an ArgumentError
 **/
ClassMirror findClassMirror(String name) {
	for (LibraryMirror lib in currentMirrorSystem().libraries.values) {
		DeclarationMirror mirror = lib.declarations[MirrorSystem.getSymbol(name)];
		if (mirror != null)
			return mirror;
	}
	throw new ArgumentError("Class $name does not exist");
}

String createId(num x, num y, String type, String tsid) {
	return (type + x.toString() + y.toString() + tsid).hashCode.toString();
}

/**
 *
 * Log a message out to the console (and possibly a log file through redirection)
 *
 **/
void log(String message) {
	print("(${new DateTime.now().toString()}) $message");
}

@app.Route('/getSpritesheets')
Future<Map> getSpritesheets(@app.QueryParam('username') String username) async
{
	if (username == null) {
		return {};
	}

	Map<String, String> spritesheets = {};
	File cache = new File('./playerSpritesheets/${username.toLowerCase()}.json');
	if (!(await cache.exists())) {
		try {
			await cache.create(recursive: true);
			spritesheets = await _getSpritesheetsFromWeb(username);
			await cache.writeAsString(JSON.encode(spritesheets));
			return spritesheets;
		}
		catch (e) {
			return {};
		}
	}
	else {
		try {
			return JSON.decode(cache.readAsStringSync());
		}
		catch (err) {
			return {};
		}
	}
}

Future<Map> _getSpritesheetsFromWeb(String username) async
{
	Map spritesheets = {};

	String url = 'http://www.glitchthegame.com/friends/search/?q=${Uri.encodeComponent(username)}';
	String response = await http.read(url);

	RegExp regex = new RegExp('\/profiles\/(.+)\/" class="friend-name">$username', caseSensitive: false);
	if (regex.hasMatch(response)) {
		String tsid = regex.firstMatch(response).group(1);

		response = await http.read('http://www.glitchthegame.com/profiles/$tsid');

		List<String> sheets = [
			'base', 'angry', 'climb', 'happy', 'idle1', 'idle2', 'idle3', 'idleSleepy', 'jump', 'surprise'];
		sheets.forEach((String sheet) {
			RegExp regex = new RegExp('"(.+$sheet\.png)"');
			spritesheets[sheet] = regex.firstMatch(response).group(1);
		});

		return spritesheets;
	}
	else
		return _getSpritesheetsFromWeb('Hectaku');
}

@app.Route('/getItemByName')
Map getItemByName(@app.QueryParam('name') String name) {
	try {
		return items.values.singleWhere((Item i) => i.name == name).getMap();
	}
	catch (err) {
		return {'status':'FAIL', 'reason':'Could not find item: $name'};
	}
}

@app.Route('/getStreetFillerStats')
Future<Map> getStreetFillerStats() {
	Completer c = new Completer();
	File finished = _getFinishedFile();
	finished.readAsString().then((String str) {
		try {
			File file = new File('./streetEntities/streets.json');
			Map streets = JSON.decode(file.readAsStringSync());

//			int trulyFinished = 0;
			int reportedBroken = 0;
			int reportedFinished = 0;
			int reportedVandalized = 0;
			int entitiesRequired = 0;
			int entitiesComplete = 0;
			Map<String, int> typeTotals = {};

			Map finishedMap = JSON.decode(str);
			finishedMap.forEach((String key, Map value) {
//				if(value['streetFinished'] == true) {
//					trulyFinished++;
//				}
				if (value['reportedBroken'] == true) {
					reportedBroken++;
				}
				if (value['reportedFinished'] == true) {
					reportedFinished++;
				}
				if (value['reportedVandalized'] == true) {
					reportedVandalized++;
				}
				if (value['entitiesRequired'] != null && value['entitiesRequired'] != -1) {
					entitiesRequired += num.parse(value['entitiesRequired'].toString());
				}
				if (value['entitiesComplete'] != null && value['entitiesComplete'] != -1) {
					entitiesComplete += num.parse(value['entitiesComplete'].toString());
				}
			});

			Directory dir = new Directory('./streetEntities');
			for (File f in dir.listSync()) {
				if (f.path.contains('.bak') || f.path.contains('streets.json')
				    || f.path.contains('finished.json'))
					continue;

				Map entityData = JSON.decode(f.readAsStringSync());
				List<Map> entities = entityData['entities'];
				entities.forEach((Map entity) {
					if (typeTotals.containsKey(entity['type']))
						typeTotals[entity['type']]++;
					else
						typeTotals[entity['type']] = 1;
				});
			}
			Map data = {'totalStreets':streets.length, 'totalReports':finishedMap.length,
				'entitiesRequired':entitiesRequired, 'entitiesComplete':entitiesComplete,
				'reportedBroken':reportedBroken, 'reportedComplete':reportedFinished,
				'reportedVandalized':reportedVandalized, 'typeTotals':typeTotals};
			c.complete(data);
		}
		catch (err) {
			log("Unable to read street stats: $err");
			c.complete({});
		}
	});

	return c.future;
}

@app.Route('/getActualImageHeight')
Future<int> getActualImageHeight(@app.QueryParam('url') String imageUrl,
	@app.QueryParam('numRows') int numRows,
	@app.QueryParam('numColumns') int numColumns) async {
	if (heightsCache[imageUrl] != null) {
		return heightsCache[imageUrl];
	}
	else {
		http.Response response = await http.get(imageUrl);

		Image image = decodeImage(response.bodyBytes);
		Image singleFrame = copyCrop(image, 0, 0, image.width ~/ numColumns, image.height ~/ numRows);
		int actualHeight = findTrim(singleFrame, mode: TRIM_TRANSPARENT)[3];
		heightsCache[imageUrl] = actualHeight;
		return actualHeight;
	}
}

@app.Route('/trimImage')
Future<String> trimImage(@app.QueryParam('username') String username) async {
	if (headsCache[username] != null) {
		return headsCache[username];
	} else {
		Map<String, String> spritesheet = await getSpritesheets(username);
		String imageUrl = spritesheet['base'];
		if (imageUrl == null) {
			return '';
		}

		http.Response response = await http.get(imageUrl);

		Image image = decodeImage(response.bodyBytes);
		int frameWidth = image.width ~/ 15;
		image = copyCrop(image, image.width - frameWidth, 0, frameWidth, image.height ~/ 1.5);
		List<int> trimRect = findTrim(image, mode: TRIM_TRANSPARENT);
		Image trimmed = copyCrop(image, trimRect[0], trimRect[1], trimRect[2], trimRect[3]);

		String str = CryptoUtils.bytesToBase64(encodePng(trimmed));
		headsCache[username] = str;
		return str;
	}
}

Future<Map> loadCacheFromDisk(String filename) async {
	File file = new File(filename);
	if (!(await file.exists())) {
		return {};
	}

	try {
		return JSON.decode(await file.readAsString());
	} catch (e) {
		//in case the file was corrupted
		return {};
	}
}

saveCacheToDisk(String filename, Map cache) async {
	File file = new File(filename);
	if (!(await file.exists())) {
		await file.create(recursive: true);
	}
	await file.writeAsString(JSON.encode(cache), flush: true);
}

toast(String message, WebSocket userSocket, {bool skipChat, String onClick}) {
	userSocket.add(JSON.encode({
		                           "toast": true,
		                           "message": message,
		                           "skipChat": skipChat,
		                           "onClick": onClick
	                           }));
}

/// "ClassName" -> "Class Name"
String splitCamelCase(String camelCase) {
	String spaceCase = "";
	for (int c = 0; c < camelCase.length; c++) {
		spaceCase += camelCase[c];
		if (
			c < camelCase.length - 1 &&
			camelCase[c + 1].toUpperCase() == camelCase[c + 1]
		) {
			spaceCase += " ";
		}
	}
	return spaceCase;
}