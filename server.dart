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
			//else
			{
				WebSocketTransformer.upgrade(request).then((WebSocket websocket) 
				{
					if(request.uri.path == "/")
						new ChatHandler(websocket);
					if(request.uri.path == "/playerUpdate")
						new PlayerUpdateHandler(websocket);
					if(request.uri.path == "/streetUpdate")
						new StreetUpdateHandler(websocket);
				},
				onError: (error) 
				{
					print("error: $error");
				});
			}
		});
			
		print('${new DateTime.now().toString()} - Serving Chat on ${'0.0.0.0'}:$port.');
	});
}