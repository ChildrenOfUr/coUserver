part of coUserver;

class BeanTree extends Tree
{
	BeanTree(String id, int x, int y) : super(id,x,y)
	{
		type = "Bean Tree";

		states =
			{
				"maturity_1" : new Spritesheet("maturity_1","http://c2.glitch.bz/items/2012-12-06/trant_bean__f_cap_10_f_num_10_h_10_m_1_seed_0_191991191_png_1354829640.png",990,540,198,270,9,false),
				"maturity_2" : new Spritesheet("maturity_2","http://c2.glitch.bz/items/2012-12-06/trant_bean__f_cap_10_f_num_10_h_10_m_2_seed_0_191991191_png_1354829642.png",990,540,198,270,9,false),
				"maturity_3" : new Spritesheet("maturity_3","http://c2.glitch.bz/items/2012-12-06/trant_bean__f_cap_10_f_num_10_h_10_m_3_seed_0_191991191_png_1354829643.png",990,540,198,270,9,false),
				"maturity_4" : new Spritesheet("maturity_4","http://c2.glitch.bz/items/2012-12-06/trant_bean__f_cap_10_f_num_10_h_10_m_4_seed_0_191991191_png_1354829645.png",990,2430,198,270,41,false),
				"maturity_5" : new Spritesheet("maturity_5","http://c2.glitch.bz/items/2012-12-06/trant_bean__f_cap_10_f_num_10_h_10_m_5_seed_0_191991191_png_1354829648.png",990,2970,198,270,51,false),
				"maturity_6" : new Spritesheet("maturity_6","http://c2.glitch.bz/items/2012-12-06/trant_bean__f_cap_10_f_num_10_h_10_m_6_seed_0_191991191_png_1354829652.png",990,3240,198,270,57,false),
				"maturity_7" : new Spritesheet("maturity_7","http://c2.glitch.bz/items/2012-12-06/trant_bean__f_cap_10_f_num_10_h_10_m_7_seed_0_191991191_png_1354829655.png",990,3240,198,270,59,false),
				"maturity_8" : new Spritesheet("maturity_8","http://c2.glitch.bz/items/2012-12-06/trant_bean__f_cap_10_f_num_10_h_10_m_8_seed_0_191991191_png_1354829659.png",990,3510,198,270,65,false),
				"maturity_9" : new Spritesheet("maturity_9","http://c2.glitch.bz/items/2012-12-06/trant_bean__f_cap_10_f_num_10_h_10_m_9_seed_0_191991191_png_1354829664.png",990,3780,198,270,66,false),
				"maturity_10" : new Spritesheet("maturity_10","http://c2.glitch.bz/items/2012-12-06/trant_bean__f_cap_10_f_num_10_h_10_m_10_seed_0_191991191_png_1354829669.png",990,3780,198,270,68,false)
			};
		maturity = new Random().nextInt(states.length)+1;
     	currentState = states['maturity_$maturity'];
     	state = new Random().nextInt(currentState.numFrames);
     	maxState = currentState.numFrames-1;
	}

	void harvest({WebSocket userSocket, String username})
	{
		super.harvest(userSocket:userSocket);

		//give the player the 'fruits' of their labor
		addItemToUser(userSocket,username,new Bean().getMap(),1,id);
	}
}