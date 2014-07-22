part of coUserver;

class Street
{
	static Random rand = new Random();
	Map<String,Quoin> quoins;
	Map<String,Plant> plants;
	Map<String,NPC> npcs;
	Map<String,Map> entityMaps;
	List<WebSocket> occupants;
	String label;
	
	Street(this.label,String tsid)
	{
		quoins = new Map<String,Quoin>();
		plants = new Map<String,Plant>();
		npcs = new Map<String,NPC>();
		entityMaps = {"quoin":quoins,"plant":plants,"npc":npcs};
		occupants = new List<WebSocket>();
		
		//attempt to load street occupants from streetEntities folder
		Map entities = getStreetEntities(tsid);
		if(entities == null)
		{
			generateRandomOccupants();
		}
		else
		{
			for(Map entity in entities['entities'])
			{
				String type = entity['type'];
				int x = entity['x'];
				int y = entity['y'];
				
				//generate a hopefully unique code that stays the same everytime for this object
				String id = (type+x.toString()+y.toString()+tsid).hashCode.toString();
				
				if(type == "Img" || type == "Mood" || type == "Energy" || type == "Currant"
					|| type == "Mystery" || type == "Favor" || type == "Time" || type == "Quarazy")
				{
					id = "q" + id;
					quoins[id] = new Quoin(id,x,y,type.toLowerCase());
				}
				/*else if(type.contains("Spirit") || type.contains("Vendor"))
				{
					id = "n" + id;
					int numRows = entity['animationRows'], numColumns = entity['animationColumns'];
					int numFrames = entity['animationNumFrames'];
					int state = rand.nextInt(numFrames);
					String url = entity['url'];
					npcs[id] = new Vendor(id,x,y);
				}*/
				else if(type.contains("Piggy"))
				{
					id = "n" + id;
					npcs[id] = new Piggy(id,x,y);
				}
				else if(type.contains("Chicken"))
				{
					id = "n" + id;
					npcs[id] = new Chicken(id,x,y);
				}
				else if(type.contains("Fruit"))
				{
					id = "p" + id;
					plants[id] = new FruitTree(id,x,y);
				}
				else if(type.contains("Bean"))
				{
					id = "p" + id;
					plants[id] = new BeanTree(id,x,y);
				}
				else if(type.contains("Beryl"))
				{
					id = "p" + id;
					plants[id] = new BerylRock(id,x,y);
				}
				else if(type.contains("Sparkly"))
				{
					id = "p" + id;
					plants[id] = new SparklyRock(id,x,y);
				}
				else if(type.contains("Dullite"))
				{
					id = "p" + id;
					plants[id] = new DulliteRock(id,x,y);
				}
				else if(type.contains("Metal"))
				{
					id = "p" + id;
					plants[id] = new MetalRock(id,x,y);
				}
			}
		}
	}
	
	void generateRandomOccupants()
	{
		int num = rand.nextInt(30) + 1;
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
			quoins[id] = new Quoin(id,i*200,rand.nextInt(200)+200,type);
		}
		
		//generate some piggies
		num = rand.nextInt(3) + 1;
		for(int i=1; i<=num; i++)
		{
			//1 billion numbers a unique string makes?
			String id = "n"+rand.nextInt(1000000000).toString();
			npcs[id] = new Piggy(id,i*200,0);
		}
		
		//generate some fruit trees
		num = rand.nextInt(3) + 1;
		for(int i=1; i<=num; i++)
		{
			//1 billion numbers a unique string makes?
			String id = "p"+rand.nextInt(1000000000).toString();
			plants[id] = new FruitTree(id,400*i,100);
		}
	}
}

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