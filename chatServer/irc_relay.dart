part of coUserver;

class IRCRelay
{
	String HOST = "irc.foonetic.net", SLACK_HOST = "cou.irc.slack.com";
	int PORT = 6667;
	String channel = "couchatserver", slackChannel = "game-global-chat";
	bool connected = false, slackConnected = false;
	Socket socket;
	SecureSocket slackSocket;
	
	IRCRelay()
	{
		Socket.connect(HOST, PORT).then((Socket socket)
		{
			this.socket = socket;
			
			//irc expects \r\n to end command lines
			socket.write("NICK CoUBot\r\n");
			socket.write("USER CoUBot 8 * : CoU Bot\r\n");

			socket.listen((data) 
			{
				String dataString = new String.fromCharCodes(data).trim();
				
				if(dataString.contains("PING :"))
				{
					//we must respond with PONG + :<random-string> to stay active
					String response = "PONG" + dataString.substring(4) + "\r\n";
					socket.write(response);
				}
				else if(dataString.contains("001"))
				{
					//connection was successful
					socket.write("JOIN #$channel\r\n");
				}
				else if(dataString.contains("366"))
				{
					//we successfully joined the channel and received a list of connected users
					connected = true;
				}
				else if(dataString.contains("PRIVMSG #$channel :"))
				{
					//normal message directed at the channel
					int offset = channel.length+11;
					String message = dataString.substring(dataString.indexOf("PRIVMSG #$channel :")+offset);
					
					//send message out to clients
					//ensure correct formatting
					try
					{
						Map map = JSON.decode(message); //if this doesn't throw an error, it must be a valid JSON Map
						ChatHandler.sendAll(JSON.encode(map));
					}
					catch(error)
					{
						if(message.contains("username:") && message.contains("channel:") && message.contains("message:"))
						{
							//send message
							int usernameStart = message.indexOf("username:")+9;
							int usernameEnd = message.indexOf(":", usernameStart);
							int channelStart = message.indexOf("channel:")+8;
							int channelEnd = message.indexOf(":", channelStart);
							int messageStart = message.indexOf("message:")+8;
							int messageEnd = message.indexOf(":", messageStart);
							if(usernameStart < 0 || usernameEnd < 0 || channelStart < 0 || channelEnd < 0 || messageStart < 0 || messageEnd < 0)
								sendMessage("Message must be in the form 'username:<username>:channel:<channel>:message:<message>:");
							else
							{
								Map map = new Map();
								map['username'] = message.substring(usernameStart, usernameEnd);
								map['channel'] = message.substring(channelStart, channelEnd);
								map['message'] = message.substring(messageStart, messageEnd);
								ChatHandler.sendAll(JSON.encode(map));
							}
						}
						else
							sendMessage("Message must be in the form 'username:<username>:channel:<channel>:message:<message>:");
					}
				}
			},
			onError: (error) => print(error),
			onDone: () 
			{
				try
				{
					print("Foonetic IRC hung up on us");
					connected = false;
					socket.destroy();
				}
				catch(error){}
			});
		});
          
		/*SecureSocket.connect(SLACK_HOST, PORT).then((SecureSocket socket) 
		{
			try
			{
				slackSocket = socket;
                			
    			//irc expects \r\n to end command lines
    			socket.write("PASS ${Platform.environment['irc_pass']}\r\n");
    			socket.write("NICK robertmcdermot\r\n");
    			socket.write("USER CoUBot 8 * : CoU Bot\r\n");

    			socket.listen((data)
    			{
    				String dataString = new String.fromCharCodes(data).trim();
    				
    				if(dataString.contains("PING :"))
    				{
    					//we must respond with PONG + :<random-string> to stay active
    					String response = "PONG" + dataString.substring(4) + "\r\n";
    					socket.write(response);
    				}
    				else if(dataString.contains("001"))
    				{
    					//connection was successful
    					socket.write("JOIN #$slackChannel\r\n");
    				}
    				else if(dataString.contains("366"))
    				{
    					//we successfully joined the channel and received a list of connected users
    					slackConnected = true;
    				}
    			},
    			onError: (error) => print(error),
    			onDone: () 
    			{
    				print("Slack IRC hung up on us");
    				slackConnected = false;
    				socket.destroy();
    			});
			}
			catch(error){print(error);}//if run locally this connect won't work unless Platform.environment['irc_pass'] is set
		});*/
	}
	
	sendMessage(String message)
	{
		if(!connected)
			return;
		
		socket.write("PRIVMSG #$channel :$message\r\n");
	}
	
	slackSend(String username, String text)
	{
		//if(!slackConnected)
			//return;
		
		slack.token = globalChatToken;
        slack.team = slackTeam;
        		
        String icon_url = "http://s21.postimg.org/czibb690j/head.png";
		slack.Message message = new slack.Message(text,username:username,icon_url:icon_url);		
		slack.send(message);
		
		//slackSocket.write("PRIVMSG #$slackChannel :$message\r\n");
	}
}