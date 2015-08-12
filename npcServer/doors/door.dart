part of coUserver;

abstract class Door extends Entity {
	String id, type, toLocation, streetName;
	bool outside;
	Spritesheet currentState;
	int x,y;

	Door(this.id, this.streetName, this.x, this.y) {
		type = "Door";
	}

	Map getMap() {
		Map map = super.getMap();
		map['url'] = currentState.url;
		map['id'] = id;
		map['type'] = type;
		map["numRows"] = currentState.numRows;
		map["numColumns"] = currentState.numColumns;
		map["numFrames"] = currentState.numFrames;
		map["actions"] = actions;
		map['x'] = x;
		map['y'] = y;
		return map;
	}

	void enter({WebSocket userSocket, String email}) {
		useDoor(userSocket:userSocket, email:email);
	}

	void exit({WebSocket userSocket, String email}) {
		useDoor(userSocket:userSocket, email:email);
	}

	void useDoor({WebSocket userSocket, String email}) {
		Map map = {}
			..["gotoStreet"] = "true"
			..["tsid"] = toLocation;
		userSocket.add(JSON.encode(map));
	}
}