part of entity;

abstract class Plant extends Entity {
	/**
	 * Will check for plant growth/decay and send updates to clients if needed
	 *
	 * The actions map key string should be equivalent to the name of a function
	 * as it will be dynamically called in street_update_handler when the client
	 * attempts to perform one of the available actions;
	 */

	String id, type, streetName;
	int state, maxState, x, y, actionTime = 3000;
	DateTime respawn;
	List<Action> actions = [];
	Map<String, Spritesheet> states;
	Spritesheet currentState;

	Plant(this.id, this.x, this.y, this.streetName) {
		respawn = new DateTime.now();
	}

	void restoreState(Map<String, String> metadata) {
		if (metadata.containsKey('state')) {
			state = int.parse(metadata['state']);
		}

		if (metadata.containsKey('currentState')) {
			setState(metadata['currentState']);
		}
	}

	Map<String, String> getPersistMetadata() {
		return {'state': state.toString(), 'currentState': currentState.stateName};
	}

	void update() {
//		if(respawn != null && new DateTime.now().compareTo(respawn) >= 0) {
//			state++;
//			respawn = new DateTime.now().add(new Duration(seconds:30));
//		}
//
//		if(state > maxState) {
//			state = maxState;
//		}
	}

	Map<String, dynamic> getMap() {
		Map map = super.getMap();
		map['url'] = currentState.url;
		map['id'] = id;
		map['type'] = type;
		map['state'] = state;
		map["numRows"] = currentState.numRows;
		map["numColumns"] = currentState.numColumns;
		map["numFrames"] = currentState.numFrames;
		map["actions"] = encode(actions);
		map['x'] = x;
		map['y'] = y;
		return map;
	}
}