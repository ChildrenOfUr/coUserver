part of coUserver;

// handle chat events
class ChatHandler 
{
	static Map<String, WebSocket> userSockets = new Map<String,WebSocket>(); // Map of current users
	static List<Identifier> users = new List();
	
	ChatHandler(WebSocket ws)
	{
		/**we are no longer using heroku so this should not be necessary**/
		//if a heroku app does not send any information for more than 55 seconds, the connection will be terminated
		//new KeepAlive().start(ws); 
		
		ws.listen((message)
		{
			Map map = JSON.decode(message);
			if(relay.connected)
			{
				//don't repeat /list messages to the relay
				//or possibly any statusMessages, but we'll see
				if(map['statusMessage'] == null || map['statusMessage'] != "list")
					relay.sendMessage(message);
			}
			if(relay.slackConnected && map["channel"] == "Global Chat")
			{
				if(map["statusMessage"] == null && map["username"] != null && map["message"] != null)
					relay.slackSend(map["username"] + ":: " + map["message"]);
			}
			processMessage(ws, message);
	    }, 
		onError: (error)
		{
			cleanupLists(ws);
		}, 
		onDone: ()
		{
			cleanupLists(ws);
		});
	}
	
	void cleanupLists(WebSocket ws)
	{
		List<String> socketRemove = new List<String>();
		List<int> usersRemove = new List<int>();
		String leavingUser, channel;
		userSockets.forEach((String username, WebSocket socket)
		{
			if(socket == ws)
			{
				socketRemove.add(username);
				leavingUser = username.substring(0, username.indexOf("_"));
				channel = username.substring(username.indexOf("_")+1);
				users.removeWhere((Identifier userId) => userId.username == leavingUser);
			}
		});
		//let's set to null instead of removing to see if that solves concurrent modification exception 
		//when sending messages while a user disconnects
		socketRemove.forEach((String username)
		{
			userSockets[username] = null;
		});
		
		//send a message to all other clients that this user has disconnected
		Map map = new Map();
		map["message"] = " left.";
		map["username"] = leavingUser;
		map["channel"] = channel;
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
			    	//userSockets[userName].close();  //  close the previous connection
        		}
    			userSockets[userName] = ws;
				map["statusMessage"] = "true";
				map["username"] = map["message"].substring(9);
    			map["message"] = ' joined.';
				String street = "";
				if(map["street"] != null)
					street = map["street"];
				users.add(new Identifier(map["username"],map["channel"],street));
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
			else if(map["statusMessage"] == "changeStreet")
			{
				users.forEach((Identifier id)
				{
					if(id.username == map["username"])
						id.currentStreet = map["newStreetLabel"];
					if(id.username != map["username"] && id.currentStreet == map["oldStreet"]) //others who were on the street with you
					{
						Map leftForMessage = new Map();
						leftForMessage["statusMessage"] = "leftStreet";
						leftForMessage["username"] = map["username"];
						leftForMessage["streetName"] = map["newStreetLabel"];
						leftForMessage["tsid"] = map["newStreetTsid"];
						leftForMessage["message"] = " has left for ";
						leftForMessage["channel"] = "Local Chat";
						userSockets[id.username+"_"+"Local Chat"].add(JSON.encode(leftForMessage));
					}
					if(id.currentStreet == map["newStreet"] && id.username != map["username"]) //others who are on the new street
					{
						//display message to others that we're here?
					}
				});
				return;
			}
			else if(map["statusMessage"] == "list")
			{
				List<String> userList = new List();
				users.forEach((Identifier userId)
				{
					if(!userList.contains(userId.username) && userId.channelName == map["channel"])
					{
						if(map["channel"] == "Local Chat" && userId.currentStreet == map["street"])
							userList.add(userId.username);
						else if(map["channel"] != "Local Chat")
							userList.add(userId.username);
					}
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

  	static void sendAll(String sendMessage)
	{
		Iterator itr = userSockets.values.iterator;
		while(itr.moveNext())
		{
			WebSocket socket = itr.current;
			if(socket != null)
				socket.add(sendMessage);
		}
  	}
}