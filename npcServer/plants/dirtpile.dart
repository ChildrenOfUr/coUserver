part of coUserver;

class DirtPile extends Plant
{
	DirtPile(String id, int x, int y) : super(id,x,y)
	{
		actionTime = 3000;
		type = "Dirt Pile";
		
		actions.add({"action":"dig",
					 "actionWord":"digging",
					 "timeRequired":actionTime,
					 "enabled":true,
					 "requires":[
					               {
								     "num":1,
								     "of":["Shovel","Ace of Spades"]
								   }
								]
					 });
		
		states = 
			{
				"maturity_1" : new Spritesheet("maturity_1","http://c2.glitch.bz/items/2012-12-06/dirt_pile_dirt_state_x11_1_variant_dirt1_1_png_1354833756.png",780,213,195,71,11,false),
				"maturity_2" : new Spritesheet("maturity_2","http://c2.glitch.bz/items/2012-12-06/dirt_pile_dirt_state_x11_1_variant_dirt2_1_png_1354833757.png",780,213,195,71,11,false)
			};
		int maturity = new Random().nextInt(states.length)+1;
	 	currentState = states['maturity_$maturity'];
	 	state = new Random().nextInt(currentState.numFrames);
	 	maxState = 0;
	}
	
	@override
	void update()
	{
		if(state >= currentState.numFrames)
			setActionEnabled("dig",false);
		
		if(respawn != null && new DateTime.now().compareTo(respawn) >= 0)
		{
			state--;
			setActionEnabled("dig",true);
			respawn = new DateTime.now().add(new Duration(seconds:30));
		}
		
		if(state < maxState)
			state = maxState;
	}
	
	void dig({WebSocket userSocket})
	{
		respawn = new DateTime.now().add(new Duration(seconds:30));
		state++;
		
		//give the player the 'fruits' of their labor
		Map map = {};
		map['giveItem'] = "true";
		map['item'] = new LumpofEarth().getMap();
		map['num'] = 1;
		map['fromObject'] = id;
		userSocket.add(JSON.encode(map));
		
		//1 in 10 chance to get a lump of loam as well
		if(new Random().nextInt(10) == 5)
		{
			map = {};
			map['giveItem'] = "true";
			map['item'] = new LumpofLoam().getMap();
			map['num'] = 1;
			map['fromObject'] = id;
			userSocket.add(JSON.encode(map));
		}
	}
}