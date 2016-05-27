library identifier;

import 'dart:io';

class Identifier
{
	List<String> channelList = [];
	String username, currentStreet, tsid;
	num currentX = 1.0, currentY = 0.0;
	WebSocket webSocket;
	Identifier (this.username,this.currentStreet,this.tsid,this.webSocket);

	@override
	String toString() => '<Identifier for $username on $tsid at ($currentX, $currentY)>';
}
