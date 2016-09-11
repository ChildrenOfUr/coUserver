library harvest_messages;

class PlayerPosition {
	String email, streetName;
	num x,y;

	PlayerPosition(this.streetName, this.email, this.x, this.y);
}

class ChatEvent {
	String username;
	String message;
	String channel;
	String streetName;

	ChatEvent({this.username, this.message, this.channel, this.streetName});

	ChatEvent.fromMap(Map map) {
		username = map['username'];
		message = map['message'];
		channel = map['channel'];
		streetName = map['street'];
	}
}