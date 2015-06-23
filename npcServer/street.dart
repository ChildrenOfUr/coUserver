part of coUserver;

class Street
{
	static Random rand = new Random();
	Map<String,Quoin> quoins;
	Map<String,Plant> plants;
	Map<String,NPC> npcs;
	Map<String,Map> entityMaps;
	Map<String,Item> groundItems;
	List<WebSocket> occupants;
	String label;

	Street(this.label,String tsid)
	{
		quoins = new Map<String,Quoin>();
		plants = new Map<String,Plant>();
		npcs = new Map<String,NPC>();
		groundItems = new Map<String,Item>();
		entityMaps = {"quoin":quoins,"plant":plants,"npc":npcs,"groundItem":groundItems};
		occupants = new List<WebSocket>();

		//attempt to load street occupants from streetEntities folder
		Map entities = getStreetEntities(tsid);
		if(entities['entities'] == null)
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
				String id = createId(x,y,type,tsid);

				if(type == "Img" || type == "Mood" || type == "Energy" || type == "Currant"
					|| type == "Mystery" || type == "Favor" || type == "Time" || type == "Quarazy")
				{
					id = "q" + id;
					quoins[id] = new Quoin(id,x,y,type.toLowerCase());
				}
				else
				{
					try
					{
						ClassMirror classMirror = findClassMirror(type.replaceAll(" ", ""));
						if(classMirror.isSubclassOf(findClassMirror("NPC")))
						{
							id = "n" + id;
                            npcs[id] = classMirror.newInstance(new Symbol(""), [id,x,y]).reflectee;
						}
						if(classMirror.isSubclassOf(findClassMirror("Plant")))
						{
							id = "p" + id;
                        	plants[id] = classMirror.newInstance(new Symbol(""), [id,x,y]).reflectee;
						}
					}
					catch(e){log("Unable to instantiate a class for $type: $e");}
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