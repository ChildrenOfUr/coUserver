library coUserver;

import 'dart:io';
import 'dart:async';
import 'dart:convert';

part 'chatServer/irc_relay.dart';
part 'chatServer/keep_alive.dart';
part 'common/identifier.dart';
part 'chatServer/chat_handler.dart';

part 'multiplayerServer/player_update_handler.dart';

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
			if(request.uri.path == "/stressTest")
				new StressTest(request);
			else
			{
				WebSocketTransformer.upgrade(request).then((WebSocket websocket) 
				{
					if(request.uri.path == "/")
						new ChatHandler(websocket);
					if(request.uri.path == "/playerUpdate")
						new PlayerUpdateHandler(websocket);
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