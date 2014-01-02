import 'dart:io';
import 'dart:async';
import 'dart:convert';

void main() 
{
	WebSocketHandler webSocketHandler = new WebSocketHandler();
	int port = int.parse(Platform.environment['PORT'], onError: (_) => 8080); //Platform.environment['PORT'] is for Heroku, 8080 is for localhost
	HttpServer.bind('0.0.0.0', port).then((HttpServer server) 
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
				websocket.add(JSON.encode(pingMap));
			}
		});
	}
}

class Identifier
{
	String username, channelName;
	Identifier(this.username,this.channelName);
}

// handle WebSocket events
class WebSocketHandler 
{
	Map<String, WebSocket> userSockets = new Map<String,WebSocket>(); // Map of current users
	List<Identifier> users = new List();
	
	wsHandler(WebSocket ws) 
	{
		new KeepAlive().start(ws); //if a heroku app does not send any information for more than 55 seconds, the connection will be terminated
	    ws.listen((message) 
		{
			print("message from client: " + message);
			processMessage(ws, message);
	    }, onError: (error)
		{
			cleanupLists(ws);
		}, onDone: ()
		{
			cleanupLists(ws);
		});
	}
	
	void cleanupLists(WebSocket ws)
	{
		List<String> socketRemove = new List<String>();
		List<int> usersRemove = new List<int>();
		String leavingUser;
		userSockets.forEach((String username, WebSocket socket)
		{
			if(socket == ws)
			{
				socketRemove.add(username);
				leavingUser = username.substring(0, username.indexOf("_"));
				users.removeWhere((Identifier userId) => userId.username == leavingUser);
			}
		});
		socketRemove.forEach((String username)
		{
			userSockets.remove(username);
		});
		
		//send a message to all other clients that this user has disconnected
		Map map = new Map();
		map["message"] = " left.";
		map["username"] = leavingUser;
		sendAll(JSON.encode(map));
	}

	processMessage(WebSocket ws, String receivedMessage) 
	{
		try 
		{
			Map map = JSON.decode(receivedMessage);
			
			if(map["username"] == null) 
			{
				//combine the username with the channel name to keep track of the same user in multiple channels
				String userName = map["message"].substring(9)+"_"+map["channel"];
				if(userSockets[userName] != null) 
				{
			    	userSockets[userName].close();  //  close the previous connection
        		}
    			userSockets[userName] = ws;
				map["username"] = map["message"].substring(9);
    			map["message"] = ' joined.';
				users.add(new Identifier(map["username"],map["channel"]));
  			}
			else if(map["statusMessage"] == "changeName")
			{
				bool success = true;
				users.forEach((Identifier userId)
				{
					if(userId.username == map["newUsername"])
						success = false;
				});
				
				if(!success)
				{
					Map errorResponse = new Map();
					errorResponse["statusMessage"] = "changeName";
					errorResponse["success"] = "false";
					errorResponse["message"] = "This name is already taken.  Please choose another.";
					errorResponse["channel"] = map["channel"];
					userSockets[map["username"]+"_"+map["channel"]].add(JSON.encode(errorResponse));
					return;
				}
				else
				{
					map["success"] = "true";
					map["message"] = "is now known as";
					map["channel"] = "all"; //echo it back to all channels so we can update the connectedUsers list on the client's side
					
					users.forEach((Identifier userId)
					{
						if(userId.username == map["username"]) //update the old usernames
						{
							String usernameWithChannel = userId.username+"_"+userId.channelName;
							userSockets[map["newUsername"]+"_"+userId.channelName] = userSockets.remove(usernameWithChannel);
							userId.username = map["newUsername"];
						}
					});
				}
			}
			else if(map["statusMessage"] == "list")
			{
				List userList = new List();
				users.forEach((Identifier userId)
				{
					if(!userList.contains(userId.username) && userId.channelName == map["channel"])
						userList.add(userId.username);
				});
				map["users"] = userList;
				map["message"] = "Users in this channel: ";
				userSockets[map["username"]+"_"+map["channel"]].add(JSON.encode(map));
				return;
			}
			
      		sendAll(JSON.encode(map));
    	} 
		catch(err, st) 
		{
      		print('${new DateTime.now().toString()} - Exception - ${err.toString()}');
      		print(st);
    	}
	}

  	void sendAll(String sendMessage) 
	{
	    userSockets.forEach((String username, WebSocket socket) 
		{
			if(socket != null)
				socket.add(sendMessage);
	    });
  	}
}
