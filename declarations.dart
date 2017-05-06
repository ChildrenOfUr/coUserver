library coUserver;

import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:logging/logging.dart' as rsLog;
import 'package:redstone_mapper/plugin.dart';
import 'package:redstone/redstone.dart' as app;
import 'package:path/path.dart';
import 'package:args/args.dart';

import 'package:coUserver/achievements/achievements.dart';
import 'package:coUserver/API_KEYS.dart';
import 'package:coUserver/auctions/auctions_service.dart';
import 'package:coUserver/buffs/buffmanager.dart';
import 'package:coUserver/common/api_helper.dart';
import 'package:coUserver/common/console.dart';
import 'package:coUserver/common/identifier.dart';
import 'package:coUserver/common/keep_alive.dart';
import 'package:coUserver/common/mapdata/mapdata.dart';
import 'package:coUserver/common/slack.dart';
import 'package:coUserver/common/user.dart';
import 'package:coUserver/common/util.dart';
import 'package:coUserver/endpoints/chat_handler.dart';
import 'package:coUserver/endpoints/metabolics/metabolics.dart';
import 'package:coUserver/endpoints/status.dart';
import 'package:coUserver/endpoints/weather/weather.dart';
import 'package:coUserver/entities/items/actions/recipes/recipe.dart';
import 'package:coUserver/entities/items/item.dart';
import 'package:coUserver/quests/quest.dart';
import 'package:coUserver/skills/skillsmanager.dart';
import 'package:coUserver/streets/player_update_handler.dart';
import 'package:coUserver/streets/street_update_handler.dart';

part 'package:coUserver/endpoints/elevation.dart';
part 'package:coUserver/endpoints/friends.dart';
part 'package:coUserver/endpoints/getitems.dart';
part 'package:coUserver/endpoints/report.dart';
part 'package:coUserver/endpoints/slack.dart';
part 'package:coUserver/endpoints/usernamecolors.dart';
part 'package:coUserver/endpoints/users.dart';
part 'package:coUserver/prerender_hack.dart';

// Port for app (redstone routing)
final int REDSTONE_PORT = 8181;

// Port for websocket listeners/handlers
final int WEBSOCKET_PORT = 8282;

bool loadCert = true;

// Start the server
Future main(List<String> arguments) async {
	final parser = new ArgParser()
	//use --no-load-cert to ignore certification loading
		..addFlag("load-cert", defaultsTo: true, help: "Enables certificate loading for certificate");
	ArgResults argResults = parser.parse(arguments);
	loadCert = argResults['load-cert'];

	try {
		// Start logging
		Log.init();

		// Keep track of when the server was started
		ServerStatus.serverStart = new DateTime.now();
		Log.verbose('[Init] Server starting up');

		// Start listening on REDSTONE_PORT
		await _initRedstone();

		// Start listening on WEBSOCKET_PORT
		_initWebSockets();

		// Refill energy on new day
		MetabolicsEndpoint.trackNewDays();

		// Run all of the loading functions at the same time for faster startup!
		// This function will not return until all calls have finished, or an error is thrown.
		await Future.wait([
			// Load streets & hubs from JSON
			MapData.load(),

			// Load image caches
			FileCache.loadCaches(),

			// Load items, consume values, and vendor types from JSON
			StreetUpdateHandler.loadItems(),

			// Load quests from JSON
			QuestService.loadQuests(),

			// Load achievements from JSON
			Achievement.load(),

			// Load buffs from JSON
			BuffManager.loadBuffs(),

			// Load recipes from JSON
			Recipe.load(),

			// Load skills from JSON
			SkillManager.loadSkills()
		], eagerError: true);

		// Enable interactive console
		Console.init();

//		String query = "SELECT * from users";
//		String apiKeyQuery = "INSERT INTO api_access (api_token, user_id) values (@apiKey, @user_id)";
//		PostgreSql dbConn = await dbManager.getConnection();
//		List<User> users = await dbConn.query(query, User);
//		await Future.forEach(users, (User user) async {
//			Uuid uuid = new Uuid();
//			String apiKey = uuid.v1();
//			await dbConn.execute(apiKeyQuery, {'apiKey': apiKey, 'user_id': user.id});
//		});

		//load api access cache from the db
		await API.loadApiAccess();

		Log.info('[Init] Server started successfully, took ${ServerStatus.uptime}');
	} catch (e, st) {
		Log.error('[Init] Server startup failed', e, st);
		cleanup(1);
	}
}

// Add a CORS header to every request
@app.Interceptor(r'/.*', chainIdx: 0)
Future crossOriginInterceptor() async {
	Map<String, String> header = {
		'Access-Control-Allow-Origin': '*',
		'Access-Control-Allow-Headers': 'Origin, X-Requested-With, Content-Type, Accept'
	};

	if (app.request.method != 'OPTIONS') {
		await app.chain.next();
	}

	return app.response.change(headers: header);
}

Future _initRedstone() async {
	// Find port to bind
	int port;
	try {
		port = int.parse(Platform.environment['PORT']);
	} catch (error) {
		port = REDSTONE_PORT;
	}

	// Initialize redstone
	app.showErrorPage = false;
	app.addPlugin(getMapperPlugin(dbManager));
	app.setupConsoleLog(rsLog.Level.OFF);

	if (loadCert) {
		SecurityContext context = new SecurityContext()
			..useCertificateChain('$certPath/fullchain.pem')
			..usePrivateKey('$certPath/privkey.pem');
		await app.start(port: port, autoCompress: true, secureOptions: {#context: context});
	} else {
		await app.start(port: port, autoCompress: true);
	}

	Log.verbose('[Init Redstone] Redstone initialized. REDSTONE LOGGING IS OFF.');
}

///This will serve up the needed files to animate the player characters
@app.Route('/getSpine')
Future<File> getSpine(@app.QueryParam() email, @app.QueryParam() filename) async {
	File file = new File('./spineSkins/$email/$filename');
	if (await file.exists()) {
		return file;
	} else {
		return null;
	}
}

/// redstone.dart does not support websockets so we have to listen on a separate port for those connections :(
Future _initWebSockets() async {
	final Map<String, Function> _HANDLERS = {
		'chat': ChatHandler.handle,
		'metabolics': MetabolicsEndpoint.handle,
		'playerUpdate': PlayerUpdateHandler.handle,
		'quest': QuestEndpoint.handle,
		'streetUpdate': StreetUpdateHandler.handle,
		'weather': WeatherEndpoint.handle
	};

	HttpServer server;
	if (loadCert) {
		SecurityContext context = new SecurityContext()
			..useCertificateChain('$certPath/fullchain.pem')
			..usePrivateKey('$certPath/privkey.pem');
		server = await HttpServer.bindSecure('0.0.0.0', WEBSOCKET_PORT, context);
	} else {
		Log.debug('[Init Websockets] Not loading cert');
		server = await HttpServer.bind('0.0.0.0', WEBSOCKET_PORT);
	}

	server.listen((HttpRequest request) {
		addToConnectionHistory(request.connectionInfo.remoteAddress);

		WebSocketTransformer.upgrade(request).then((WebSocket websocket) {
			String handlerName = request.uri.path.replaceFirst('/', '');
			_HANDLERS[handlerName](websocket);
		}).catchError((error) {
			Log.warning('Socket error', error);
		}, test: (Exception e) => e is! WebSocketException)
			.catchError((error) {}, test: (Exception e) => e is WebSocketException);
	});

	KeepAlive.start();

	Log.verbose('[Init Websockets] WebSockets initialized');
}
