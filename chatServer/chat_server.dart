library coUserver;

import 'dart:io';
import 'dart:async';
import 'dart:convert';

part "irc_relay.dart";
part "keep_alive.dart";
part "identifier.dart";
part "websocket_handler.dart";

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
		
		server.transform(new WebSocketTransformer()).listen((WebSocket websocket) => new WebSocketHandler(websocket),
		onError: (error) => print(error));
			
		print('${new DateTime.now().toString()} - Serving Chat on ${'0.0.0.0'}:$port.');
	});
}