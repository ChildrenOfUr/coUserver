part of coUserver;

abstract class NPC extends Entity
{
	/**
	 * The actions map key string should be equivalent to the name of a function
	 * as it will be dynamically called in street_update_handler when the client
	 * attempts to perform one of the available actions;
	 * */

	Random rand;
	String id,type;
	int x,y, speed, actionTime = 2500;
	DateTime respawn;
	bool facingRight = true;
	List<Map> actions = [];
	Map<String,Spritesheet> states;
	Spritesheet currentState;

	NPC(this.id,this.x,this.y)
	{
		respawn = new DateTime.now();
		rand = new Random();
	}

	void update();

	Map getMap()
	{
		Map map = super.getMap();
		map["id"] = id;
		map["url"] = currentState.url;
		map["type"] = type;
		map["numRows"] = currentState.numRows;
		map["numColumns"] = currentState.numColumns;
		map["numFrames"] = currentState.numFrames;
		map["x"] = x;
		map["y"] = y;
		map["width"] = currentState.frameWidth;
        map["height"] = currentState.frameHeight;
        map["facingRight"] = facingRight;
        map["actions"] = actions;
        return map;
	}
}