part of coUserver;

IRCRelay relay;

void main() 
{
	int port = 8181;
	try	{port = int.parse(Platform.environment['PORT']);}
	catch (error){port = 8181;}
	
	var dbManager = new PostgreSqlManager(databaseUri, min: 1, max: 3);

	app.addPlugin(getMapperPlugin(dbManager));
      
	app.setupConsoleLog();
	app.start(port:port);
	
	//redstone.dart does not support websockets so we have to listen on a 
	//seperate port for those connections :(
	HttpServer.bind('0.0.0.0', 8282).then((HttpServer server) 
	{
        relay = new IRCRelay();
        
		server.listen((HttpRequest request)
		{
			WebSocketTransformer.upgrade(request).then((WebSocket websocket) 
			{
				if(request.uri.path == "/chat")
					ChatHandler.handle(websocket);
				else if(request.uri.path == "/playerUpdate")
					PlayerUpdateHandler.handle(websocket);
				else if(request.uri.path == "/streetUpdate")
					StreetUpdateHandler.handle(websocket);
			})
			.catchError((error)
			{
				log("error: $error");
			},
			test: (Exception e) => e is! WebSocketException)
			.catchError((error){},test: (Exception e) => e is WebSocketException);
		});
		
		log('\nServing Chat on ${'0.0.0.0'}:8282');
	});
}

PostgreSql get postgreSql => app.request.attributes.dbConn;

//add a CORS header to every request
@app.Interceptor(r'/.*')
crossOriginInterceptor() 
{
	if (app.request.method == "OPTIONS") 
	{
		//overwrite the current response and interrupt the chain.
		app.response = new shelf.Response.ok(null, headers: _createCorsHeader());
		app.chain.interrupt();
	}
	else 
	{
    	//process the chain and wrap the response
		app.chain.next(() => app.response.change(headers: _createCorsHeader()));
	}
}

_createCorsHeader() => {"Access-Control-Allow-Origin": "*","Access-Control-Allow-Headers": "Origin, X-Requested-With, Content-Type, Accept"};

@app.Route('/ah/list')
@Encode()
Future<List<Auction>> getAllAuctions() => 
		postgreSql.query("select * from auctions", Auction);

@app.Route('/ah/post', methods: const[app.POST])
Future addAuction(@Decode() Auction auction) => 
		postgreSql.execute("insert into auctions (item_name,total_cost,username) "
						   "values (@item_name, @total_cost, @username)",auction);

@app.Route('/serverStatus')
Map getServerStatus()
{
	Map statusMap = {};
	try
	{
		List<String> users = [];
		ChatHandler.users.forEach((Identifier user)
		{
			if(!users.contains(user.username))
				users.add(user.username);
		});
		statusMap['playerList'] = users;
		statusMap['numStreetsLoaded'] = StreetUpdateHandler.streets.length;
		ProcessResult result = Process.runSync("/bin/sh",["getMemoryUsage.sh"]);
		statusMap['bytesUsed'] = int.parse(result.stdout)*1024;
		result = Process.runSync("/bin/sh",["getCpuUsage.sh"]);
		statusMap['cpuUsed'] = double.parse(result.stdout.trim());
		result = Process.runSync("/bin/sh",["getUptime.sh"]);
        statusMap['uptime'] = result.stdout.trim();
	}
	catch(e){log("Error getting server status: $e");}
	return statusMap;
}

@app.Route('/serverLog')
Map getServerLog()
{
	Map statusMap = {};
	try
	{
		DateTime date = new DateTime.now();
		DateFormat format = new DateFormat("MM_dd_yy");
		statusMap['serverLog'] = new File('serverLogs/${format.format(date)}-server.log').readAsStringSync();
	}
	catch(exception, stacktrace)
	{
		statusMap['serverLog'] = exception.toString();
	}
	return statusMap;
}
	
@app.Route('/restartServer')
String restartServer(@app.QueryParam('secret') String secret)
{
	if(secret == restartSecret)
	{
		Process.runSync("/bin/sh",["restart_server.sh"]);
		return "OK";
	}
	else
		return "NOT AUTHORIZED";
}

@app.Route('/slack', methods: const[app.POST])
String parseMessageFromSlack(@app.QueryParam('user_name') String username,
                             @app.QueryParam('text') String text)
{
	if(username != "slackbot" && text != null && text.isNotEmpty)
		ChatHandler.sendAll(
				JSON.encode({'username':'dev_$username','channel':'Global Chat'}));
	
	return "OK";
}

@app.Route('/entityUpload', methods: const[app.POST])
String uploadEntities(@app.Body(app.JSON) Map params)
{
	if(params['tsid'] == null)
		return "FAIL";
	
	saveStreetData(params);
	return "OK";
}

@app.Route('/getEntities')
Map getEntities(@app.QueryParam('tsid') String tsid)
{
	return getStreetEntities(tsid);
}

@app.Route('/getRandomStreet')
String getRandomStreet() => getTsidOfUnfilledStreet();

@app.Route('/reportStreet')
String reportStreet(@app.QueryParam('tsid') String tsid, 
                    @app.QueryParam('reason') String reason,
                    @app.QueryParam('details') String details)
{
	reportBrokenStreet(tsid,reason);
    				
	//post a message to map-filler-reports
	slack.token = mapFillerReportsToken;
    slack.team = slackTeam;
    		
    String text = "$tsid: $reason\n$details";
	slack.Message message = new slack.Message(text,username:"doesn't apply");	
	slack.send(message);
    		
	return "OK";
}