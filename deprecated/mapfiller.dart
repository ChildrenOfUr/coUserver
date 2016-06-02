// Used by the mapfiller to report broken streets
/*
@app.Route('/reportStreet')
String reportStreet(@app.QueryParam('tsid') String tsid,
                   @app.QueryParam('reason') String reason,
                   @app.QueryParam('details') String details) {
	reportBrokenStreet(tsid, reason);

	// Post a message to map-filler-reports
	slack.token = mapFillerReportsToken;
	slack.team = slackTeam;

	String text = "$tsid: $reason\n$details";
	slack.Message message = new slack.Message(text, username:"doesn't apply");
	slack.send(message);

	return "OK";
}
*/
/*
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
*/

// Used by the mapfiller to find a street to edit
/*
@app.Route('/getRandomStreet')
String getRandomStreet() => getTsidOfUnfilledStreet();
*/
/*
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
*/

// Used by the mapfiller to save entities
/*
@app.Route('/entityUpload', methods: const[app.POST])
String uploadEntities(@app.Body(app.JSON) Map params) {
	if (params['tsid'] == null) {
		return "FAIL";
	} else {
		saveStreetData(params);
		return "OK";
	}
}
*/
/*
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
*/
/*
File _getFinishedFile() {
	File finished = new File('./streetEntities/finished.json');
	if (!finished.existsSync())
		_createFinishedFile();

	return finished;
}
*/
/*
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
*/

/// Used by humans to monitor the mapfiller community process
/*
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
*/
