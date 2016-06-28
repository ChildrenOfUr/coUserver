part of entity;

abstract class LockedDoor extends Door {
	String requiredKey;

	LockedDoor(String id, String streetName, num x, num y) : super(id, streetName, x, y) {
		type = "Locked Door";
		actions.add(
			new Action.withName('exit')
				..actionWord = 'walking out'
		);
	}

	void enter({WebSocket userSocket, String email}) {
		bool success = InventoryV2.takeAnyItemsFromUser(email, requiredKey, 1) == 1;
		if (success) {
			useDoor(userSocket:userSocket, email:email);
		} else {
			toast("You need the correct key for this door.", userSocket);
		}
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
		map['key'] = requiredKey;
		return map;
	}
}