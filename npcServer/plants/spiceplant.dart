part of coUserver;

class SpicePlant extends Tree
{
	SpicePlant(String id, int x, int y) : super(id,x,y)
	{
		type = "Spice Plant";
		
		states = 
			{
				"maturity_1" : new Spritesheet("maturity_1","http://c2.glitch.bz/items/2012-12-06/trant_spice__f_cap_10_f_num_10_h_10_m_1_seed_0_191119119_png_1354830923.png",954,1000,318,250,10,false),
				"maturity_2" : new Spritesheet("maturity_2","http://c2.glitch.bz/items/2012-12-06/trant_spice__f_cap_10_f_num_10_h_10_m_2_seed_0_191119119_png_1354830925.png",954,1000,318,250,10,false),
				"maturity_3" : new Spritesheet("maturity_3","http://c2.glitch.bz/items/2012-12-06/trant_spice__f_cap_10_f_num_10_h_10_m_3_seed_0_191119119_png_1354830927.png",954,1000,318,250,10,false),
				"maturity_4" : new Spritesheet("maturity_4","http://c2.glitch.bz/items/2012-12-06/trant_spice__f_cap_10_f_num_10_h_10_m_4_seed_0_191119119_png_1354830932.png",954,3000,318,250,35,false),
				"maturity_5" : new Spritesheet("maturity_5","http://c2.glitch.bz/items/2012-12-06/trant_spice__f_cap_10_f_num_10_h_10_m_5_seed_0_191119119_png_1354830937.png",954,3750,318,250,45,false),
				"maturity_6" : new Spritesheet("maturity_6","http://c2.glitch.bz/items/2012-12-06/trant_spice__f_cap_10_f_num_10_h_10_m_6_seed_0_191119119_png_1354830942.png",3498,1250,318,250,54,false),
				"maturity_7" : new Spritesheet("maturity_7","http://c2.glitch.bz/items/2012-12-06/trant_spice__f_cap_10_f_num_10_h_10_m_7_seed_0_191119119_png_1354830948.png",3816,1250,318,250,57,false),
				"maturity_8" : new Spritesheet("maturity_8","http://c2.glitch.bz/items/2012-12-06/trant_spice__f_cap_10_f_num_10_h_10_m_8_seed_0_191119119_png_1354830955.png",3498,1500,318,250,66,false),
				"maturity_9" : new Spritesheet("maturity_9","http://c2.glitch.bz/items/2012-12-06/trant_spice__f_cap_10_f_num_10_h_10_m_9_seed_0_191119119_png_1354830962.png",3498,1500,318,250,66,false),
				"maturity_10" : new Spritesheet("maturity_10","http://c2.glitch.bz/items/2012-12-06/trant_spice__f_cap_10_f_num_10_h_10_m_10_seed_0_191119119_png_1354830969.png",3498,1500,318,250,66,false)
			};
		maturity = new Random().nextInt(states.length)+1;
     	currentState = states['maturity_$maturity'];
     	state = new Random().nextInt(currentState.numFrames);
     	maxState = currentState.numFrames-1;
	}
	
	void harvest({WebSocket userSocket})
	{
		super.harvest(userSocket:userSocket);
		
		//give the player the 'fruits' of their labor
		Map map = {};
		map['giveItem'] = "true";
		map['item'] = new Allspice().getMap();
		map['num'] = 1;
		map['fromObject'] = id;
		userSocket.add(JSON.encode(map));
	}
}