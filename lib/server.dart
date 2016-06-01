part of coUserver;

// Start the server
Future main() async {
	// Find port to bind
	int port;
	try {
		port = int.parse(Platform.environment['PORT']);
	} catch (error) {
		port = REDSTONE_PORT;
	}

	// Initialize redstone
	try {
		app.addPlugin(getMapperPlugin(dbManager));
		app.setupConsoleLog();
		await app.start(port: port, autoCompress: true);
	} catch (e) {
		log('Could not start server: $e');
		await cleanup(1);
	}
	KeepAlive.start();

	// Ignore messages about quest requirements being completed when not on the quest
	messageBus.deadMessageHandler = (harvest.Message m) {};

	// Load items from JSON
	await StreetUpdateHandler.loadItems();

	// Load quests from JSON
	await QuestService.loadQuests();

	// redstone.dart does not support websockets so we have to listen on a separate port for those connections :(
	HttpServer.bind('0.0.0.0', WEBSOCKET_PORT).then((HttpServer server) {
		server.listen((HttpRequest request) {
			WebSocketTransformer.upgrade(request).then((WebSocket websocket) {
				String handlerName = request.uri.path.replaceFirst('/', '');
				HANDLERS[handlerName].handle(websocket);
			}).catchError((error) {
				log('error: $error');
			}, test: (Exception e) => e is! WebSocketException)
				.catchError((error) {}, test: (Exception e) => e is WebSocketException);
		});

		log('Bound websockets to port $WEBSOCKET_PORT');
	});

	// Make trees speech bubbles appear where they should
	heightsCache = await loadCacheFromDisk('heightsCache.json');
	headsCache = await loadCacheFromDisk('headsCache.json');

	// Save some server state to the disk every 30 seconds
	new Timer.periodic(new Duration(seconds: 30), (Timer t) {
		try {
			StatBuffer.writeStatsToFile();
			saveCacheToDisk('heightsCache.json', heightsCache);
			saveCacheToDisk('headsCache.json', headsCache);
		} catch (e) {
			log('Problem writing stats to file: $e');
		}
	});

	// Keep track of when the server was started
	startDate = new DateTime.now();

	// Refill everyone's energy on the start of a new day
	Clock clock = new Clock();
	clock.onNewDay.listen((_) => MetabolicsEndpoint.refillAllEnergy());

	// Graceful shutdown
	ProcessSignal.SIGINT.watch().listen((ProcessSignal sig) async => await cleanup());
	ProcessSignal.SIGTERM.watch().listen((ProcessSignal sig) async => await cleanup());

//	StreetEntities.migrateEntities(); // TODO: do this on the live server

	// Enable interactive console
	Console.init();

	// Set up status access & start counting uptime
	ServerStatus.init();

	// Start counting uptime
	log('Server started successfully');

	new Command.register('cleanup', (String exitCode) async {
		await cleanup(int.parse(exitCode));
	}, ['exit code']);
}

/// Anything that should run here as cleanup before exit
/// Doesn't seem to work with webstorm's stop process button (must send SIGKILL)
Future cleanup([int exitCode = 0]) async {
	// Persist the state of each loaded street to the database
	await Future.forEach(StreetUpdateHandler.streets.keys, (String label) async {
		log('[Cleanup] Persisting $label before shutdown');
		await StreetUpdateHandler.streets[label].persistState();
	});

	exit(exitCode);
}

// Add a CORS header to every request
@app.Interceptor(r'/.*')
Future crossOriginInterceptor() async {
	Map<String, String> _createCorsHeader() => {
		'Access-Control-Allow-Origin': '*',
		'Access-Control-Allow-Headers':
			'Origin, X-Requested-With, Content-Type, Accept'
	};

	if (app.request.method != 'OPTIONS') {
		await app.chain.next();
	}
	return app.response.change(headers: _createCorsHeader());
}
