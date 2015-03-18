part of coUserver;

class Identifier
{
	String username, currentStreet, tsid;
	num currentX = 1.0, currentY = 0.0;
	WebSocket webSocket;
	Identifier(this.username,this.currentStreet,this.tsid,this.webSocket);
}