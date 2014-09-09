part of coUserver;

class Quoin
{
	String url = "https://raw.github.com/robertmcdermot/couspritesheets/master/spritesheets/quoin/quoin__x1_1_x1_2_x1_3_x1_4_x1_5_x1_6_x1_7_x1_8_png_1354829599.png";
	String id, type;
	int x,y;
	DateTime respawn;
	bool collected = false;

	Quoin(this.id,this.x,this.y,this.type);

	/**
	 * Will check for quoin collection/spawn and send updates to clients if needed
	 */
	update()
	{
		if(respawn != null && new DateTime.now().compareTo(respawn) >= 0)
			collected = false;
	}

	setCollected()
	{
		collected = true;
		StatBuffer.incrementStat("quoionsCollected", 1);
		respawn = new DateTime.now().add(new Duration(seconds:30));
	}

	Map getMap()
	{
		Map map = new Map();
		map["id"] = id;
		map["url"] = url;
		map["type"] = type;
		map["remove"] = collected.toString();
		map["x"] = x;
		map["y"] = y;
		return map;
	}
}