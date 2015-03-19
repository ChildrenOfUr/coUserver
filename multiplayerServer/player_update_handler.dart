part of coUserver;

//handle player update events
class PlayerUpdateHandler
{
	static Map<String,Identifier> users = {};

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

		users.forEach((String username, Identifier id)
		{
			if(ws == id.webSocket)
			{
				id.webSocket = null;
				leavingUser = username;
			}
		});

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

	static Future processMessage(WebSocket ws, String message)
	{
		try
		{
			Completer c = new Completer();
			Map map = JSON.decode(message);

			if(map['clientVersion'] != null)
			{
				if(map['clientVersion'] < minClientVersion)
					ws.add(JSON.encode({'error':'version too low'}));
				c.complete();
			}
			else
			{
				String username = map["username"];
    			if(map["statusMessage"] == "changeName")
    			{
    				//don't accept this message from anyone else
    				//(fixes the /setname other players stop moving bug)
    				if(ws != users[username].webSocket)
    					c.complete();

    				String newUsername = map['newUsername'];
    				//the user used /setname to change their name and it was successful
    				//tell the other clients that the old guy disconnected
    				String street = map['street'];
    				String tsid = map['tsid'];
    				users[newUsername] = new Identifier(newUsername,street,tsid,ws);

					users.remove(username);

    				//change the username on the metabolics socket
    				MetabolicsEndpoint.userSockets[newUsername] = MetabolicsEndpoint.userSockets[username];
    				MetabolicsEndpoint.userSockets.remove(username);

    				map = new Map();
    				map["disconnect"] = "true";
    				map["username"] = username;
    				map["street"] = street;
    				sendAll(map);
    			}
    			if(users[username] != null) //we've had an update for this user before
    			{
    				if(users[username].currentStreet != map["street"]) //the user must have switched streets
    				{
    					map["changeStreet"] = map["street"];
    					users[username].currentStreet = map["street"];
    				}
    				try
    				{
	    				num prevX = users[username].currentX;
	    				num prevY = users[username].currentY;
	    				num currentX = num.parse(map['xy'].split(',')[0]);
	    				num currentY = num.parse(map['xy'].split(',')[1]);
	    				num xDiff = (currentX-prevX).abs();
	    				num yDiff = (currentY-prevY).abs();
	    				StatBuffer.incrementStat("stepsTaken", (xDiff+yDiff)/22);
	    				users[username].currentX = currentX;
	    				users[username].currentY = currentY;
    				}
    				catch(e,st){log("(player_update_handler/processMessage): $e\n$st");}
    			}
    			else //this user must have just connected
    			{
    				users[username] = new Identifier(username,map["street"],map['tsid'],ws);
    				try
					{
						num currentX = num.parse(map['xy'].split(',')[0]);
                        num currentY = num.parse(map['xy'].split(',')[1]);
        				users[username].currentX = currentX;
                        users[username].currentY = currentY;
					}
    				catch(e,st){log("(player_update_handler/processMessage): $e\n$st");}
    			}

    			sendAll(map);
			}

			return c.future;
		}
		catch(error, st)
		{
			log("Error processing message (player_update_handler): $error\n$st");
		}
	}

	static void sendAll(Map map)
	{
		String data = JSON.encode(map);
		users.forEach((String username, Identifier id)
		{
			if(username != map["username"] && (map["street"] == id.currentStreet || map['changeStreet'] != null))
			{
				id.webSocket.add(data);
			}
		});
	}
}