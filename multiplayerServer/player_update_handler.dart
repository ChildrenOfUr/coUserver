part of coUserver;

//handle player update events
class PlayerUpdateHandler
{
	static Map<String,Identifier> users = {};
	static Map<String,WebSocket> userSockets = {};

	static void handle(WebSocket ws)
	{
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

	static void cleanupList(WebSocket ws)
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

		userSockets.remove(leavingUser);
		Identifier leavingID = users.remove(leavingUser);
		if(leavingID != null)
		{
			Map map = new Map();
			map["disconnect"] = "true";
			map["username"] = leavingUser;
			map["street"] = leavingID.currentStreet;
			sendAll(map);
		}
	}

	static void processMessage(WebSocket ws, String message)
	{
		try
		{
			Map map = JSON.decode(message);

			if(map['clientVersion'] != null)
			{
				if(map['clientVersion'] < minClientVersion)
					ws.add(JSON.encode({'error':'version too low'}));
				return;
			}

			String username = map["username"];
			if(map["statusMessage"] == "changeName")
			{
				//don't accept this message from anyone else
				//(fixes the /setname other players stop moving bug)
				if(ws != userSockets[username])
					return;

				String newUsername = map['newUsername'];
				//the user used /setname to change their name and it was successful
				//tell the other clients that the old guy disconnected
				userSockets[newUsername] = ws;
				String street = map['street'];
				users[newUsername] = new Identifier(newUsername,"",street);

				userSockets.remove(username);
				users.remove(username);

				map = new Map();
				map["disconnect"] = "true";
				map["username"] = username;
				map["street"] = street;
				sendAll(map);
				return;
			}
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
		catch(error, st)
		{
			print("Error processing message (player_update_handler): $error");
		}
	}

	static void sendAll(Map map)
	{
		String data = JSON.encode(map);
		userSockets.forEach((String username, WebSocket socket)
		{
			if(users[username] == null || socket == null)
				1 == 1; //do nothing
			else if(username != map["username"] && ((map["street"] == users[username].currentStreet || map["changeStreet"] == users[username].currentStreet)))
				socket.add(data);
		});
	}
}