part of coUserver;

class Identifier
{
	String username, channelName;
	Identifier(this.username,this.channelName);
	
	String pairString()
	{
		return "username: $username, channelName: $channelName";
	}
}