part of coUserver;

class Street
{
	static Random rand = new Random();
	Map<String,Quoin> quoins;
	List<Plant> plants;
	List<NPC> npcs;
	List<WebSocket> occupants;
	String label;
	
	Street(this.label)
	{
		quoins = new Map<String,Quoin>();
		plants = new List<Plant>();
		npcs = new List<NPC>();
		occupants = new List<WebSocket>();
		
		int num = rand.nextInt(30);
		for(int i=0; i<num; i++)
		{
			//1 billion numbers a unique string makes?
			String id = "q"+rand.nextInt(1000000000).toString();
			int typeInt = rand.nextInt(4);
			String type = "";
			if(typeInt == 0)
				type = "currant";
			if(typeInt == 1)
				type = "energy";
			if(typeInt == 2)
				type = "mood";
			if(typeInt == 3)
				type = "img";
			quoins[id] = new Quoin(id,i*200,rand.nextInt(200)+200,type,this);
		}
	}
}

class Quoin
{
	String url = "https://raw.github.com/robertmcdermot/couspritesheets/master/spritesheets/quoin/quoin__x1_1_x1_2_x1_3_x1_4_x1_5_x1_6_x1_7_x1_8_png_1354829599.png";
	String id,keyframes, animation, type;
	int x,y,width = 40,height = 45;
	Street street;
	DateTime respawn;
	bool collected = false;
	
	Quoin(this.id,this.x,this.y,this.type,this.street)
	{
		if(type == "img")
			keyframes = "@-webkit-keyframes img {from { background-position: 0px 0px;} to { background-position: 960px 0px;}}";
		else if(type == "mood")
			keyframes = "@-webkit-keyframes mood {from { background-position: 0px -45px;} to { background-position: 960px -45px;}}";
		else if(type == "energy")
			keyframes = "@-webkit-keyframes energy {from { background-position: 0px -90px;} to { background-position: 960px -90px;}}";
		else if(type == "currant")
			keyframes = "@-webkit-keyframes currant {from { background-position: 0px -135px;} to { background-position: 960px -135px;}}"; 	
		animation = type + " 1.1s steps(24) infinite";
	}
	
	/**
	 * Will check for quoin collection/spawn and send updates to clients if needed
	 */
	update()
	{
		if(respawn != null && new DateTime.now().compareTo(respawn) >= 0)
			collected = false;
		
		if(!collected)
		{
			street.occupants.forEach((WebSocket socket)
			{
				if(socket != null)
				{
					Map map = new Map();
					map["id"] = id;
					map["url"] = url;
					map["type"] = type;
					map["keyframes"] = keyframes;
					map["animation"] = animation;
					map["x"] = x;
					map["y"] = y;
					map["width"] = width;
		            map["height"] = height;
					socket.add(JSON.encode(map));
				}
			});
		}
	}
	
	setCollected()
	{
		collected = true;
		respawn = new DateTime.now().add(new Duration(seconds:30));
	}
}

class Plant
{
	/**
	 * Will check for plant growth/decay and send updates to clients if needed
	 */
	update()
	{
		
	}
}

class NPC
{
	/**
	 * Will simulate npc movement and send updates to clients if needed
	 */
	update()
	{
		
	}
}