part of coUserver;

class GasPlant extends Tree
{
	GasPlant(String id, int x, int y) : super(id,x,y)
	{
		type = "Gas Plant";
		
		states = 
			{
				"maturity_1" : new Spritesheet("maturity_1","http://c2.glitch.bz/items/2012-12-06/trant_gas__f_cap_10_f_num_10_h_10_m_1_seed_0_19191191_png_1354830873.png",828,1032,276,258,10,false),
				"maturity_2" : new Spritesheet("maturity_2","http://c2.glitch.bz/items/2012-12-06/trant_gas__f_cap_10_f_num_10_h_10_m_2_seed_0_19191191_png_1354830875.png",828,1032,276,258,10,false),
				"maturity_3" : new Spritesheet("maturity_3","http://c2.glitch.bz/items/2012-12-06/trant_gas__f_cap_10_f_num_10_h_10_m_3_seed_0_19191191_png_1354830877.png",828,1032,276,258,10,false),
				"maturity_4" : new Spritesheet("maturity_4","http://c2.glitch.bz/items/2012-12-06/trant_gas__f_cap_10_f_num_10_h_10_m_4_seed_0_19191191_png_1354830880.png",828,1806,276,258,19,false),
				"maturity_5" : new Spritesheet("maturity_5","http://c2.glitch.bz/items/2012-12-06/trant_gas__f_cap_10_f_num_10_h_10_m_5_seed_0_19191191_png_1354830883.png",828,2064,276,258,24,false),
				"maturity_6" : new Spritesheet("maturity_6","http://c2.glitch.bz/items/2012-12-06/trant_gas__f_cap_10_f_num_10_h_10_m_6_seed_0_19191191_png_1354830888.png",828,2838,276,258,31,false),
				"maturity_7" : new Spritesheet("maturity_7","http://c2.glitch.bz/items/2012-12-06/trant_gas__f_cap_10_f_num_10_h_10_m_7_seed_0_19191191_png_1354830895.png",828,3870,276,258,45,false),
				"maturity_8" : new Spritesheet("maturity_8","http://c2.glitch.bz/items/2012-12-06/trant_gas__f_cap_10_f_num_10_h_10_m_8_seed_0_19191191_png_1354830902.png",3312,1032,276,258,47,false),
				"maturity_9" : new Spritesheet("maturity_9","http://c2.glitch.bz/items/2012-12-06/trant_gas__f_cap_10_f_num_10_h_10_m_9_seed_0_19191191_png_1354830910.png",3312,1032,276,258,47,false),
				"maturity_10" : new Spritesheet("maturity_10","http://c2.glitch.bz/items/2012-12-06/trant_gas__f_cap_10_f_num_10_h_10_m_10_seed_0_19191191_png_1354830919.png",3864,1032,276,258,53,false)
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
		map['item'] = new GeneralVapour().getMap();
		map['num'] = 1;
		map['fromObject'] = id;
		userSocket.add(JSON.encode(map));
	}
}