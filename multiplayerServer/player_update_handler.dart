part of coUserver;

//handle player update events
class PlayerUpdateHandler
{
	static Map<String,Identifier> users;
	static Map<String,WebSocket> userSockets;
	
	PlayerUpdateHandler(WebSocket ws)
	{
		users = new Map();
		userSockets = new Map();
		
		ws.listen((message)
		{
			processMessage(ws, message);
	    }, 
		onError: (error)
		{
			cleanupList(ws);
		}, 
		onDone: ()
		{
			cleanupList(ws);
		});
	}
	
	cleanupList(WebSocket ws)
	{
		String leavingUser;
		
		userSockets.forEach((String username, WebSocket socket)
		{
			if(ws == socket)
			{
				socket = null;
				leavingUser = username;
			}
		});
		
		users.remove(leavingUser);
	}
	
	processMessage(WebSocket ws, String message)
	{
		try
		{
			Map map = JSON.decode(message);
			String username = map["username"];
			if(users[username] != null) //we've had an update for this user before
			{
				if(users[username].currentStreet != map["street"]) //the user must have switched streets
				{
					map["changeStreet"] = map["street"];					
					users[username].currentStreet = map["street"];
				}
			}
			else //this user must have just connected
			{
				userSockets[username] = ws;
				users[username] = new Identifier(username,"",map["street"]);
			}
			
			sendAll(map);
		}
		catch(error)
		{
			print("Error processing message: $error");
		}
	}
	
	sendAll(Map map)
	{
		String data = JSON.encode(map);
		userSockets.forEach((String username, WebSocket socket)
		{
			if(users[username] == null || socket == null)
				1 == 1; //do nothing
			else if(username != map["username"] && (map["street"] == users[username].currentStreet || map["changeStreet"] == users[username].currentStreet))
				socket.add(data);
		});
	}
}