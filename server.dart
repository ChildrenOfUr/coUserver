part of coUserver;

IRCRelay relay;

void main() 
{
	int port = 8080;
	try	{port = int.parse(Platform.environment['PORT']);} //Platform.environment['PORT'] is for deployed, 8080 is for localhost
	catch (error){port = 8181;}
	HttpServer.bind('0.0.0.0', port).then((HttpServer server) 
	{
		//setup the IRCRelay
		relay = new IRCRelay();
		
		server.listen((HttpRequest request)
		{
			//if(request.uri.path == "/stressTest")
				//new StressTest(request);
			if(request.uri.path == "/serverStatus")
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
				request.response
					..headers.add('Access-Control-Allow-Origin', '*')
					..headers.add('Content-Type', 'application/json')
					..write(JSON.encode(statusMap))
					..close();
			}
			else if(request.uri.path == "/serverLog")
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
				request.response
					..headers.add('Access-Control-Allow-Origin', '*')
					..headers.add('Content-Type', 'application/json')
					..write(JSON.encode(statusMap))
					..close();
			}
			else if(request.uri.path == "/restartServer")
			{
				//TODO this should probably be secured - don't care right now
				Process.runSync("/bin/sh",["restart_server.sh"]);
			}
			else if(request.uri.path == "/slack")
			{
				HttpBodyHandler.processRequest(request).then((HttpBody body)
				{
					Map data = body.body;
					String username = data['user_name'];
    				String text = data['text'];
    				if(username == "robertmcdermot" && text.contains("::"))
    				{
    					request.response..write("OK")..close();
    					return;
    				}
    				
    				Map message = {'username':'dev_$username','channel':'Global Chat'};
    				if(text != null)
    				{
    					message['message'] = text;
    					ChatHandler.sendAll(JSON.encode(message));
    				}
    				
    				request.response..write("OK")..close();
				});
			}
			else if(request.uri.path == "/entityUpload")
			{
				HttpBodyHandler.processRequest(request).then((HttpBody body)
				{
					Map params = body.body;
    				String tsid = params['tsid'];
    				
    				request.response
    				        ..headers.add('Access-Control-Allow-Origin', '*')
                            ..headers.add('Content-Type', 'application/json');
    				if(tsid == null)
    				{
    					request.response..write("FAIL")..close();
    					return;
    				}
    				
    				saveStreetData(params);
    				
    				request.response..write("OK")..close();
				});
			}
			else if(request.uri.path == "/getEntities")
			{
				Map data = request.uri.queryParameters;
				String tsid = data['tsid'];
				Map entities = getStreetEntities(tsid);
				request.response
					..headers.add('Access-Control-Allow-Origin', '*')
					..headers.add('Content-Type', 'application/json')
					..write(JSON.encode(entities==null?{}:entities))
					..close();
			}
			else if(request.uri.path == "/getRandomStreet")
			{
				request.response
			        ..headers.add('Access-Control-Allow-Origin', '*')
					..headers.add('Content-Type', 'application/json')
					..write(getTsidOfUnfilledStreet())
					..close();
			}
			else if(request.uri.path == "/reportBrokenStreet")
			{
				Map data = request.uri.queryParameters;
				reportBrokenStreet(data['tsid']);
				request.response
			        ..headers.add('Access-Control-Allow-Origin', '*')
					..headers.add('Content-Type', 'text/plain')
					..write("OK")
					..close();
			}
			else
			{
				WebSocketTransformer.upgrade(request).then((WebSocket websocket) 
				{
					if(request.uri.path == "/")
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
			}
		});
		
		log('\nServing Chat on ${'0.0.0.0'}:$port.');
	});
}