part of coUserver;

class Identifier
{
	List<String> channelList = [];
	String username, currentStreet, tsid, undeadTSID;
	num currentX = 1.0, currentY = 0.0;
	WebSocket webSocket;
	bool dead = false, outOfHell = true;
	Identifier (this.username,this.currentStreet,this.tsid,this.webSocket);
}