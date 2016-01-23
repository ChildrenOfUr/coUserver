part of coUserver;

IRCRelay relay;
double minClientVersion = 0.14;
PostgreSqlManager dbManager;
Map<String, int> heightsCache = null;
Map<String, String> headsCache = null;
DateTime startDate;
Map<String, Item> items = {};
Map<String, String> vendorTypes = {};
Random rand = new Random();

harvest.MessageBus messageBus = new harvest.MessageBus.async();

main() async {
	int port = 8181;
	try {
		port = int.parse(Platform.environment['PORT']);
	}
	catch(error) {
		port = 8181;
	}

	dbManager = new PostgreSqlManager(databaseUri, min: 1, max: 9);

	app.addPlugin(getMapperPlugin(dbManager));
	app.setupConsoleLog();
	app.start(port:port, autoCompress:true);

	//open a file for writing logs to
//	File logFile = new File('redstone_log_file');
//	if (!(await logFile.exists())) {
//		await logFile.create();
//	}
//	IOSink sink = logFile.openWrite(mode: FileMode.APPEND);
//	sink.writeln('\n=====================================');
//	sink.writeln("Server started at ${new DateTime.now()}");
//	sink.writeln('=====================================\n');
//
//	//write all messages to the iosink
//	Logger.root.level = Level.ALL;
//	Logger.root.onRecord.listen((LogRecord rec) {
//		sink.writeln(rec);
//	});

	KeepAlive.start();

	await StreetUpdateHandler.loadItems();
	await QuestService.loadQuests();

	//redstone.dart does not support websockets so we have to listen on a
	//seperate port for those connections :(
	HttpServer.bind('0.0.0.0', 8282).then((HttpServer server) {
		//relay = new IRCRelay();

		server.listen((HttpRequest request) {
			WebSocketTransformer.upgrade(request).then((WebSocket websocket) {
				if(request.uri.path == "/chat")
					ChatHandler.handle(websocket);
				else if(request.uri.path == "/playerUpdate")
					PlayerUpdateHandler.handle(websocket);
				else if(request.uri.path == "/streetUpdate")
					StreetUpdateHandler.handle(websocket);
				else if(request.uri.path == "/metabolics")
					MetabolicsEndpoint.handle(websocket);
				else if(request.uri.path == "/weather")
					WeatherEndpoint.handle(websocket);
				else if(request.uri.path == '/quest') {
					QuestEndpoint.handle(websocket);
				}
			})
			.catchError((error) {
				log("error: $error");
			},
			            test: (Exception e) => e is! WebSocketException)
			.catchError((error) {
			}, test: (Exception e) => e is WebSocketException);
		});

		log('Serving Chat on ${'0.0.0.0'}:8282');
	});

	//useful for making trees speech bubbles appear where they should
	heightsCache = await loadCacheFromDisk('heightsCache.json');
	headsCache = await loadCacheFromDisk('headsCache.json');

	//save some server state to the disk every 30 seconds
	new Timer.periodic(new Duration(seconds:30), (Timer t) {
		try {
			StatBuffer.writeStatsToFile();
			saveCacheToDisk('heightsCache.json',heightsCache);
			saveCacheToDisk('headsCache.json',headsCache);
		}
		catch(e) {
			log("Problem writing stats to file: $e");
		}
	});

	//Keep track of when the server was started
	startDate = new DateTime.now();

	//refill everyone's energy on the start of a new day
	Clock clock = new Clock();
	clock.onNewDay.listen((_) => MetabolicsEndpoint.refillAllEnergy());

	ProcessSignal.SIGINT.watch().listen((ProcessSignal sig) async => await cleanup());
	ProcessSignal.SIGTERM.watch().listen((ProcessSignal sig) async => await cleanup());

	//This was used to upgrade the inventories in place so that they had the right key/value pairs
	//Similar code could be needed in the future.
//	String query = 'SELECT * FROM inventories';
//	PostgreSql db = await dbManager.getConnection();
//	List<InventoryV2> inventories = await db.query(query, InventoryV2);
//	print('processing ${inventories.length} inventories for upgrade...');
//	List<Future> futures = [];
//	query = 'UPDATE inventories SET inventory_json = @inventory_json WHERE inventory_id = @inventory_id';
//	inventories.forEach((InventoryV2 inventory) {
//		inventory._upgradeItems();
//		futures.add(db.execute(query, inventory));
//	});
//	await Future.wait(futures);
//	print('upgading complete');
//	dbManager.closeConnection(db);
}

///anything that should run here as cleanup before exit
///doesn't seem to work with webstorm's stop process button (must send SIGKILL)
Future cleanup() async {
	//persist the state of each loaded street to the db
	await Future.forEach(StreetUpdateHandler.streets.keys, (String label) async {
		print('persisting $label before shutdown');
		await StreetUpdateHandler.streets[label].persistState();
	});

	exit(0);
}

@app.Route('/listUsers')
Future<List<String>> listUsers(@app.QueryParam('channel') String channel) async
{
	List<String> users = [];
	List<Identifier> ids = ChatHandler.users.values.where((Identifier id) =>
	id.channelList.contains(channel)).toList();

	ids.forEach((Identifier id) => users.add(id.username));

	return users;
}

@app.Route('/getItems')
@Encode()
Future<List<Item>> getItems(@app.QueryParam('category') String category,
                            @app.QueryParam('name') String name,
							@app.QueryParam('type') String type,
                            @app.QueryParam('isRegex') bool isRegex) async {
	List<Item> itemList = [];
	if(isRegex == null)
		isRegex = false;

	if(category != null) {
		if(isRegex) {
			RegExp reg = new RegExp(category.toLowerCase());
			itemList.addAll(items.values.where((Item i) => reg.hasMatch(i.category.toLowerCase())));
		}
		else
			itemList.addAll(items.values.where((Item i) => i.category.toLowerCase() == category.toLowerCase()));
	}

	if(name != null) {
		if(isRegex) {
			RegExp reg = new RegExp(name.toLowerCase());
			itemList.addAll(items.values.where((Item i) => reg.hasMatch(i.name.toLowerCase())));
		}
		else {
			itemList.addAll(items.values.where((Item i) => i.name.toLowerCase() == name.toLowerCase()));
		}
	}

	if (type != null) {
		if(isRegex) {
			RegExp reg = new RegExp(type.toLowerCase());
			itemList.addAll(items.values.where((Item i) => reg.hasMatch(i.itemType.toLowerCase())));
		} else {
			itemList.addAll(items.values.where((Item i) => i.itemType.toLowerCase() == type.toLowerCase()));
		}
	}

	if(name == null && category == null && type == null)
		return new List.from(items.values);

	return itemList;
}

PostgreSql get dbConn => app.request.attributes.dbConn;

Future<PostgreSql> get conn => dbManager.getConnection();

//add a CORS header to every request
@app.Interceptor(r'/.*')
crossOriginInterceptor() {
	if(app.request.method == "OPTIONS") {
		//overwrite the current response and interrupt the chain.
		app.response = new shelf.Response.ok(null, headers: _createCorsHeader());
		app.chain.interrupt();
	}
	else {
		//process the chain and wrap the response
		app.chain.next(() => app.response.change(headers: _createCorsHeader()));
	}
}

_createCorsHeader() => {"Access-Control-Allow-Origin": "*", "Access-Control-Allow-Headers": "Origin, X-Requested-With, Content-Type, Accept"};

@app.Route('/serverStatus')
Future<Map> getServerStatus() async
{
	Map statusMap = {};
	try {
		List<String> users = [];
		ChatHandler.users.forEach((String username, Identifier user) {
			if(!users.contains(user.username))
				users.add(user.username);
		});
		statusMap['playerList'] = users;
		statusMap['numStreetsLoaded'] = StreetUpdateHandler.streets.length;
		ProcessResult result = await Process.run("/bin/sh", ["getMemoryUsage.sh"]);
		statusMap['bytesUsed'] = int.parse(result.stdout) * 1024;
		result = await Process.run("/bin/sh", ["getCpuUsage.sh"]);
		statusMap['cpuUsed'] = double.parse(result.stdout.trim());
		result = await Process.run("/bin/sh", ["getUptime.sh"]);
		statusMap['uptime'] = result.stdout.trim();
	}
	catch(e) {
		log("Error getting server status: $e");
	}
	return statusMap;
}

@app.Route('/serverLog')
Future<Map> getServerLog() async
{
	Map statusMap = {};
	try {
		DateFormat format = new DateFormat("MM_dd_yy");
		ProcessResult result = await Process.run("tail", ['-n', '200', 'serverLogs/${format.format(startDate)}-server.log']);
		statusMap['serverLog'] = result.stdout;
		return statusMap;
	}
	catch(exception) {
		statusMap['serverLog'] = exception.toString();
		return statusMap;
	}
}

@app.Route('/slack', methods: const[app.POST])
String parseMessageFromSlack(@app.Body(app.FORM) Map form) {
	String token = form['token'];
	if(token != couKey && token != glitchForeverKey && token != devKey) {
		return "NOT AUTHORIZED";
	}

	String username = form['user_name'], text = form['text'];
	Map map = {};
	if(username != "slackbot" && text != null && text.isNotEmpty) {
		if(token == couKey) {
			map = {'username':username, 'message': text, 'channel':'Global Chat'};
		} else {
			map = {'username':'$username', 'message': text, 'channel':'Global Chat'};
		}
		ChatHandler.sendAll(JSON.encode(map));
	}

	return "OK";
}

@app.Route('/entityUpload', methods: const[app.POST])
String uploadEntities(@app.Body(app.JSON) Map params) {
	if(params['tsid'] == null)
		return "FAIL";

	saveStreetData(params);

	return "OK";
}

@app.Route('/getEntities')
Map getEntities(@app.QueryParam('tsid') String tsid) {
	return getStreetEntities(tsid);
}

@app.Route('/getRandomStreet')
String getRandomStreet() => getTsidOfUnfilledStreet();

//@app.Route('/reportStreet')
//String reportStreet(@app.QueryParam('tsid') String tsid,
//                    @app.QueryParam('reason') String reason,
//                    @app.QueryParam('details') String details) {
//	reportBrokenStreet(tsid, reason);
//
//	//post a message to map-filler-reports
//	slack.token = mapFillerReportsToken;
//	slack.team = slackTeam;
//
//	String text = "$tsid: $reason\n$details";
//	slack.Message message = new slack.Message(text, username:"doesn't apply");
//	slack.send(message);
//
//	return "OK";
//}
