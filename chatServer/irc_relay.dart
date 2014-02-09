part of coUserver;

class IRCRelay
{
	String HOST = "irc.foonetic.net";
	int PORT = 6667;
	String channel = "couchatserver";
	bool connected = false;
	Socket socket;
	
	IRCRelay()
	{
		Socket.connect(HOST, PORT).then((Socket socket)
		{
			this.socket = socket;
			
			//irc expects \r\n to end command lines
			socket.write("NICK CoUBot2\r\n");
			socket.write("USER CoUBot2 8 * : CoU Bot\r\n");

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
				print("IRC hung up on us");
				connected = false;
				socket.destroy();
			});
		});
	}
	
	sendMessage(String message)
	{
		if(!connected)
			return;
		
		socket.write("PRIVMSG #$channel :$message\r\n");
	}
}