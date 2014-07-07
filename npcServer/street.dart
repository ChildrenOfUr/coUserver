part of coUserver;

class Street
{
	static Random rand = new Random();
	Map<String,Quoin> quoins;
	Map<String,Plant> plants;
	Map<String,NPC> npcs;
	List<WebSocket> occupants;
	String label;
	
	Street(this.label)
	{
		quoins = new Map<String,Quoin>();
		plants = new Map<String,Plant>();
		npcs = new Map<String,NPC>();
		occupants = new List<WebSocket>();
		
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
			npcs[id] = new NPC(id,i*200,"Piggy");
		}
		
		//generate some fruit trees
		num = rand.nextInt(3) + 1;
		for(int i=1; i<=num; i++)
		{
			//1 billion numbers a unique string makes?
			String id = "p"+rand.nextInt(1000000000).toString();
			plants[id] = new Plant(id,"Fruit Tree",rand.nextInt(60),400*i,100);
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

class Plant
{
	/**
	 * Will check for plant growth/decay and send updates to clients if needed
	 */

	String url = "http://c2.glitch.bz/items/2012-12-06/trant_fruit__f_cap_10_f_num_10_h_10_m_10_seed_0_111119119_png_1354830686.png";
	String id, type;
	int state, maxState = 59, x, y, numRows = 4, numColumns = 15, numFrames = 60;
	DateTime respawn;
	Map<String,String> actions = {"harvest":"harvesting","water":"watering"};
	
	Plant(this.id, this.type, this.state,this.x,this.y);
	
	update()
	{
		if(respawn != null && new DateTime.now().compareTo(respawn) >= 0)
		{
			state++;
			respawn = new DateTime.now().add(new Duration(seconds:30));
		}
		
		if(state > maxState)
			state = maxState;
	}
	
	harvest(WebSocket userSocket)
	{
		if(state == 0)
			return;
		
		respawn = new DateTime.now().add(new Duration(seconds:30));
		state--;
		
		//give the player the 'fruits' of their labor
		Map map = {};
		map['giveItem'] = "true";
		map['url'] = 'https://raw.githubusercontent.com/RobertMcDermot/coUspritesheets/master/spritesheets/cherry/cherry__x1_1_x1_2_x1_3_x1_4_png_1354829757.png';
		map['num'] = 1;
		map['name'] = 'cherry';
		userSocket.add(JSON.encode(map));
		
		if(state < 0)
			state = 0;
	}
	
	water()
	{
		if(state == maxState)
			return;
		
		respawn = new DateTime.now().add(new Duration(seconds:30));
		state++;
		
		if(state > maxState)
			state = maxState;
	}
	
	Map getMap()
	{
		Map map = new Map();
		map['url'] = url;
		map['id'] = id;
		map['type'] = type;
		map['state'] = state;
		map["numRows"] = numRows;
		map["numColumns"] = numColumns;
		map["numFrames"] = numFrames;
		map["actions"] = actions;
		map['x'] = x;
		map['y'] = y;
        return map;
	}
}

class NPC
{
	static Random rand = new Random();
	String url;
	String id,type;
	int x,y,width, height, numRows, numColumns, numFrames, speed;
	DateTime respawn;
	bool collected = false, facingRight = true;
	Map<String,String> actions = {"nibble":"nibbling","pet":"petting"};
	
	NPC(this.id,this.x,this.type)
	{
		respawn = new DateTime.now();
		
		if(type == "Piggy")
		{
			width = 88;
			height = 62;
			speed = 75; //pixels per second
		}
	}
	
	/**
	 * Will simulate npc movement and send updates to clients if needed
	 */
	update()
	{
		if(url != null && url.contains("walk")) //we need to update x to hopefully stay in sync with clients
		{
			if(facingRight)
				x += speed; //75 pixels/sec is the speed set on the client atm
			else
				x -= speed;
			
			if(x < 0)
				x = 0;
			if(x > 4000) //TODO temporary
				x = 4000;
			
			//hard to check right bounds without actually loading the street
			//which we aren't doing right now.  we're just making everything up in the constructor
			//but at some point, TODO we should get real street info
			//if(x > street.width-width)
				//x = street.width-width;
		}
		
		if(respawn != null && new DateTime.now().compareTo(respawn) > 0)
		{
			//1 in 4 chance to change direction
			if(rand.nextInt(4) == 1)
            	facingRight = !facingRight;
			
			int num = rand.nextInt(10);
    		if(num == 6)
    		{
    			url = "https://raw.github.com/RobertMcDermot/coUspritesheets/master/spritesheets/npc_piggy/npc_piggy__x1_look_screen_png_1354829434.png";
    			numRows = 5;
    			numColumns = 10;
    			numFrames = 48;
    			
				//pick new animation in 1.6 seconds (after this one completes)
    			respawn = new DateTime.now().add(new Duration(milliseconds:1600));
    		}
    		else
    		{
    			url = "https://raw.github.com/RobertMcDermot/coUspritesheets/master/spritesheets/npc_piggy/npc_piggy__x1_walk_png_1354829432.png";
    			numRows = 3;
    			numColumns = 8;
    			numFrames = 24;
    			
				//pick new animation in .8 seconds (after this one completes)
  				respawn = new DateTime.now().add(new Duration(milliseconds:800));
    		}
		}
	}
	
	Map getMap()
	{
		Map map = new Map();
		map["id"] = id;
		map["url"] = url;
		map["type"] = type;
		map["numRows"] = numRows;
		map["numColumns"] = numColumns;
		map["numFrames"] = numFrames;
		map["x"] = x;
		map["width"] = width;
        map["height"] = height;
        map["facingRight"] = facingRight;
        map["actions"] = actions;
        return map;
	}
}