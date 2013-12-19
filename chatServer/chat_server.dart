import 'dart:io';
import 'dart:async';
import 'dart:convert';

void main() 
{
	WebSocketHandler webSocketHandler = new WebSocketHandler();

	HttpServer.bind('0.0.0.0', int.parse(Platform.environment['PORT'])).then((HttpServer server) 
	{
		server.listen((HttpRequest request)
		{
			WebSocketTransformer.upgrade(request).then((WebSocket websocket)
			{
     			webSocketHandler.wsHandler(websocket);
			});
	    });
			
		print('${new DateTime.now().toString()} - Serving Chat on ${'0.0.0.0'}:${Platform.environment['PORT']}.');
	});
}

class KeepAlive
{		
	start(WebSocket websocket)
	{
		Timer timer;
		timer = new Timer.periodic(new Duration(seconds:50), (_)
		{
			if(websocket.readyState != 1) //not yet ready, closing or closed
				timer.cancel();
			else
			{
				Map pingMap = new Map();
				pingMap["message"] = "ping";
				print("sending ping: " + JSON.encode(pingMap));
				websocket.add(JSON.encode(pingMap));
			}
		});
	}
}


// handle WebSocket events
class WebSocketHandler 
{
	Map<String, WebSocket> users = new Map<String,WebSocket>(); // Map of current users
	
	wsHandler(WebSocket ws) 
	{
		new KeepAlive().start(ws); //if a heroku app does not send any information for more than 55 seconds, the connection will be terminated
	    ws.listen((message) 
		{
			print("message from client: " + message);
			processMessage(ws, message);
	    });
	}

	processMessage(WebSocket ws, String receivedMessage) 
	{
		try 
		{
			String userName = getUserName(ws);
			Map map = JSON.decode(receivedMessage);
			
			if(map["username"] == null) 
			{
				//combine the username with the channel name to keep track of the same user in multiple channels
				userName = map["message"].substring(9)+"_"+map["channel"];
				if(users[userName] != null) 
				{
			    	users[userName].close();  //  close the previous connection
        		}
    			users[userName] = ws;
				map["username"] = map["message"].substring(9);
    			map["message"] = ' joined.';
  			}
			else if(map["statusMessage"] == "changeName")
			{
				users[map["username"]] = users[map["newUername"]];
				users.remove(map["username"]);
			}
			
      		sendAll(JSON.encode(map));
    	} 
		catch(err, st) 
		{
      		print('${new DateTime.now().toString()} - Exception - ${err.toString()}');
      		print(st);
    	}
	}

	String getUserName(WebSocket ws) 
	{
	    String userName;
	    users.forEach((key, value) 
		{
	    	if(value == ws)
				userName = key;
		});
	    return userName;
	}

  	void sendAll(String sendMessage) 
	{
	    users.forEach((key, value) 
		{
			value.add(sendMessage);
	    });
  	}
}
