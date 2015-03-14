part of coUserver;

// handle chat events
class ChatHandler
{
	static Map<String, WebSocket> userSockets = new Map<String,WebSocket>(); // Map of current users
	static List<Identifier> users = new List();

	static void handle(WebSocket ws)
	{
		/**we are no longer using heroku so this should not be necessary**/
		//if a heroku app does not send any information for more than 55 seconds, the connection will be terminated

		if(!KeepAlive.pingList.contains(ws))
			KeepAlive.pingList.add(ws);

		ws.listen((message)
		{
			Map map = JSON.decode(message);
			/*if(relay.connected)
			{
				//don't repeat /list messages to the relay
				//or possibly any statusMessages, but we'll see
				if(map['statusMessage'] == null || map['statusMessage'] != "list")
					relay.sendMessage(message);
			}*/
			if(map["channel"] == "Global Chat")
			{
				if(map["statusMessage"] == null && map["username"] != null && map["message"] != null)
					slackSend(map["username"],map["message"]);
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

	static void slackSend(String username, String text)
	{
		slack.token = globalChatToken;
        slack.team = slackTeam;

        try
        {
        	String icon_url = "http://childrenofur.com/data/heads/$username.head.png";
            http.get(icon_url).then((response)
            {
            	//if the head picture doesn't already exist, try to make one
            	if(response.statusCode != 200)
            	{
            		getSpritesheets(username).then((Map spritesheets)
                    {
                    	if(spritesheets['base'] != null)
                    	{
                    		http.get(spritesheets['base']).then((response)
                    		{
                    			Image image = decodeImage(response.bodyBytes);
                    			int frameWidth = image.width~/15;
                    			int frameHeight = (image.height*.6).toInt();
                    			int xStart = 0;
                    			if(frameWidth > frameHeight)
                    				xStart = frameWidth-frameHeight;
            					image = copyCrop(image,xStart,0,frameWidth,frameHeight);
            					List<int> bytes = encodePng(image);

            					MultipartRequest request = new MultipartRequest("POST",Uri.parse("http://childrenofur.com/data/heads/uploadhead.php"));
            					request.files.add(new MultipartFile.fromBytes('file', bytes, filename:'$username.head.png'));
            					request.send().then((StreamedResponse response)
            					{
            						icon_url = 'http://childrenofur.com/data/heads/$username.head.png';
            						_sendMessage(text,username,icon_url);
            					});
                    		});
                    	}
                    	//if the username isn't found, just use the cupcake
                    	else
                    	{
                    		icon_url = 'http://s21.postimg.org/czibb690j/head.png';
                    		_sendMessage(text,username,icon_url);
                    	}
                    });
            	}
            	else
            		_sendMessage(text,username,icon_url);
            });
        }
        catch(err){log('error sending slack message: $err');}
	}

	static void _sendMessage(String text, String username, String icon_url)
	{
		slack.Message message = new slack.Message(text,username:username,icon_url:icon_url);
		slack.send(message);
	}

	static void cleanupLists(WebSocket ws, {String reason:'No reason given'})
	{
		try
		{
			KeepAlive.pingList.remove(ws);
			ws.close(4001,reason);
		}
		catch(err){log('error: $err');}

		List<String> socketRemove = new List<String>();
		List<int> usersRemove = new List<int>();
		String leavingUser;
		userSockets.forEach((String username, WebSocket socket)
		{
			if(socket == ws)
			{
				socketRemove.add(username);
				leavingUser = username;
				users.removeWhere((Identifier userId) => userId.username == leavingUser);
			}
		});
		socketRemove.forEach((String username) => userSockets.remove(username));

		//send a message to all other clients that this user has disconnected
		Map map = new Map();
		map["message"] = " left.";
		map['channel'] = "Local Chat";
		map["username"] = leavingUser;
		sendAll(JSON.encode(map));
	}

	static void processMessage(WebSocket ws, String receivedMessage) async
	{
		try
		{
			Map map = JSON.decode(receivedMessage);

			if(map['clientVersion'] != null)
			{
				if(map['clientVersion'] < minClientVersion)
					ws.add(JSON.encode({'error':'version too low'}));
				return;
			}

			if(map['statusMessage'] == 'pong')
			{
				KeepAlive.notResponded.remove(ws);
				return;
			}
			else if(map["statusMessage"] == 'join')
			{
				//combine the username with the channel name to keep track of the same user in multiple channels
				String userName = map["username"];
    			userSockets[userName] = ws;
				map["statusMessage"] = "true";
    			map["message"] = ' joined.';
				String street = map["street"];
				users.add(new Identifier(map["username"],street,map['tsid']));
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
					userSockets[map["username"]].add(JSON.encode(errorResponse));
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
							userSockets[map["newUsername"]] = userSockets.remove(map['username']);
							userId.username = map["newUsername"];
						}
					});

					//update their name in the database so they get logged in
					//this way next time as well
					String query = "UPDATE users SET username = @newUsername WHERE username = @oldUsername";
					await dbConn.execute(query,{'newUsername':map['newUsername'],'oldUsername':map['username']});
				}
			}
			else if(map["statusMessage"] == "changeStreet")
			{
				List<String> alreadySent = [];
				users.forEach((Identifier id)
				{
					if(id.username == map["username"])
						id.currentStreet = map["newStreetLabel"];
					if(!alreadySent.contains(id.username) && id.username != map["username"] && id.currentStreet == map["oldStreet"]) //others who were on the street with you
					{
						Map leftForMessage = new Map();
						leftForMessage["statusMessage"] = "leftStreet";
						leftForMessage["username"] = map["username"];
						leftForMessage["streetName"] = map["newStreetLabel"];
						leftForMessage["tsid"] = map["newStreetTsid"];
						leftForMessage["message"] = " has left for ";
						leftForMessage["channel"] = "Local Chat";
						if(userSockets[id.username] != null)
							userSockets[id.username].add(JSON.encode(leftForMessage));
						alreadySent.add(id.username);
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
					if(!userList.contains(userId.username))
					{
						if(map["channel"] == "Local Chat" && userId.currentStreet == map["street"])
							userList.add(userId.username);
						else if(map["channel"] != "Local Chat")
							userList.add(userId.username);
					}
				});
				map["users"] = userList;
				map["message"] = "Users in this channel: ";
				userSockets[map["username"]].add(JSON.encode(map));
				return;
			}

      		sendAll(JSON.encode(map));
    	}
		catch(err)
		{
      		log("Error handling chat: $err");
    	}
	}

  	static void sendAll(String sendMessage)
	{
  		Iterator<WebSocket> itr = userSockets.values.iterator;
		while(itr.moveNext())
		{
			WebSocket socket = itr.current;
			if(socket != null)
				socket.add(sendMessage);
		}
  	}
}