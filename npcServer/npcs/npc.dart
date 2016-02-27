part of coUserver;

abstract class NPC extends Entity {
	/**
	 * The actions map key string should be equivalent to the name of a function
	 * as it will be dynamically called in street_update_handler when the client
	 * attempts to perform one of the available actions;
	 * */

	Random rand;
	String id, type;
	int x, y, speed = 0, ySpeed = 0;
	DateTime respawn;
	bool facingRight = true;
	Map<String, Spritesheet> states;
	Spritesheet currentState;

	NPC(this.id, this.x, this.y) {
		respawn = new DateTime.now();
		rand = new Random();
	}

	void update();

	Map getMap() {
		Map map = super.getMap();
		map["id"] = id;
		map["url"] = currentState.url;
		map["type"] = type;
		map["numRows"] = currentState.numRows;
		map["numColumns"] = currentState.numColumns;
		map["numFrames"] = currentState.numFrames;
		map["x"] = x;
		map["y"] = y;
		map['speed'] = speed;
		map['ySpeed'] = ySpeed;
		map['animation_name'] = currentState.stateName;
		map["width"] = currentState.frameWidth;
		map["height"] = currentState.frameHeight;
		map['loops'] = currentState.loops;
		map['loopDelay'] = currentState.loopDelay;
		map["facingRight"] = facingRight;
		map["actions"] = actions;
		return map;
	}

	void setState(String state, {int repeat: 1}) {
		//set their state and then set the respawn time that it needs
		currentState = states[state];

		//if we want the animation to play more than once before respawn,
		//then multiply the length by the repeat
		int length = (currentState.numFrames / 30 * 1000).toInt() * repeat;
		respawn = new DateTime.now().add(new Duration(milliseconds: length));
	}
}