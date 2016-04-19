library harvest_messages;

import 'package:harvest/harvest.dart';

class PlayerPosition extends Message {
	String email, streetName;
	num x,y;

	PlayerPosition(this.streetName, this.email, this.x, this.y);
}