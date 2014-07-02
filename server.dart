library coUserver;

import 'dart:io';
import 'dart:async';
import 'dart:convert';
import 'dart:math';

//common to all server parts
part 'common/identifier.dart';

//chat server parts
part 'chatServer/irc_relay.dart';
part 'chatServer/keep_alive.dart';
part 'chatServer/chat_handler.dart';

//multiplayer server parts
part 'multiplayerServer/player_update_handler.dart';

//npc server (street simulation) parts
part 'npcServer/street_update_handler.dart';
part 'npcServer/street.dart';

//various http parts (as opposed to the previous websocket parts)
part 'web/stress_test.dart';

IRCRelay relay;

void main() 
{
	int port = 8080;
	try	{port = int.parse(Platform.environment['PORT']);} //Platform.environment['PORT'] is for Heroku, 8080 is for localhost
	catch (error){port = 8080;}
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
				statusMap['numPlayersOnline'] = ChatHandler.users.length;
				statusMap['numStreetsLoaded'] = StreetUpdateHandler.streets.length;
				try
				{
					statusMap['serverLog'] = new File('server.log').readAsStringSync();
				}
				catch(exception, stacktrace)
				{
					statusMap['serverLog'] = exception.toString();
				}
				Process.run("/bin/sh",["getMemoryUsage.sh"])
				.then((ProcessResult result)
				{
					statusMap['bytesUsed'] = int.parse(result.stdout)*1024;
					request.response
						..headers.add('Access-Control-Allow-Origin', '*')
						..headers.add('Content-Type', 'application/json')
						..write(JSON.encode(statusMap))
						..close();
				});
			}
			else
			{
				WebSocketTransformer.upgrade(request).then((WebSocket websocket) 
				{
					if(request.uri.path == "/")
						new ChatHandler(websocket);
					else if(request.uri.path == "/playerUpdate")
						new PlayerUpdateHandler(websocket);
					else if(request.uri.path == "/streetUpdate")
						new StreetUpdateHandler(websocket);
				})
				.catchError((error)
				{
					print("error: $error");
				},
				test: (Exception e) => e is! WebSocketException)
				.catchError((error){},test: (Exception e) => e is WebSocketException);
			}
		});
			
		print('${new DateTime.now().toString()}\n - Serving Chat on ${'0.0.0.0'}:$port.');
	});
}