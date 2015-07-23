part of coUserver;

class Identifier
{
	List<String> channelList = [];
	String username, currentStreet, tsid;
	num currentX = 1.0, currentY = 0.0;
	WebSocket webSocket;
	bool dead;
	Identifier (this.username,this.currentStreet,this.tsid,this.webSocket) {
		dead = false;
	}
}