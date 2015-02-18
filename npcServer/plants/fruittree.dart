part of coUserver;

class FruitTree extends Tree
{
	FruitTree(String id, int x, int y) : super(id,x,y)
	{
		type = "Fruit Tree";

		responses =
		{
        	"harvest": [
        		"Fruity!",
        		"Ta-daaaaaaa…",
        		"Yaaaaaay!",
        		"Frooooot!",
        		"C'est la!",
        	],
        	"pet": [
        		"Huh?",
        		"Oh.",
        		"Whu?",
        		"Ah.",
        		"Pff.",
        	],
        	"water": [
        		"Hm?",
        		"Ahh.",
        		"Glug.",
        		"Mm?",
        		"Shhhlrp.",
        	]
        };

		states =
			{
				"maturity_1" : new Spritesheet("maturity_1","http://c2.glitch.bz/items/2012-12-06/trant_fruit__f_cap_10_f_num_10_h_10_m_1_seed_0_111119119_png_1354830639.png",813,996,271,249,10,false),
				"maturity_2" : new Spritesheet("maturity_2","http://c2.glitch.bz/items/2012-12-06/trant_fruit__f_cap_10_f_num_10_h_10_m_2_seed_0_111119119_png_1354830641.png",813,996,271,249,10,false),
				"maturity_3" : new Spritesheet("maturity_3","http://c2.glitch.bz/items/2012-12-06/trant_fruit__f_cap_10_f_num_10_h_10_m_3_seed_0_111119119_png_1354830644.png",813,996,217,249,10,false),
				"maturity_4" : new Spritesheet("maturity_4","http://c2.glitch.bz/items/2012-12-06/trant_fruit__f_cap_10_f_num_10_h_10_m_4_seed_0_111119119_png_1354830647.png",813,1992,271,249,22,false),
				"maturity_5" : new Spritesheet("maturity_5","http://c2.glitch.bz/items/2012-12-06/trant_fruit__f_cap_10_f_num_10_h_10_m_5_seed_0_111119119_png_1354830651.png",813,2739,271,249,33,false),
				"maturity_6" : new Spritesheet("maturity_6","http://c2.glitch.bz/items/2012-12-06/trant_fruit__f_cap_10_f_num_10_h_10_m_6_seed_0_111119119_png_1354830658.png",813,3735,271,249,43,false),
				"maturity_7" : new Spritesheet("maturity_7","http://c2.glitch.bz/items/2012-12-06/trant_fruit__f_cap_10_f_num_10_h_10_m_7_seed_0_111119119_png_1354830664.png",3523,996,271,249,50,false),
				"maturity_8" : new Spritesheet("maturity_8","http://c2.glitch.bz/items/2012-12-06/trant_fruit__f_cap_10_f_num_10_h_10_m_8_seed_0_111119119_png_1354830670.png",3794,996,271,249,53,false),
				"maturity_9" : new Spritesheet("maturity_9","http://c2.glitch.bz/items/2012-12-06/trant_fruit__f_cap_10_f_num_10_h_10_m_9_seed_0_111119119_png_1354830677.png",4065,996,271,249,57,false),
				"maturity_10" : new Spritesheet("maturity_10","http://c2.glitch.bz/items/2012-12-06/trant_fruit__f_cap_10_f_num_10_h_10_m_10_seed_0_111119119_png_1354830686.png",4065,996,271,249,60,false)
			};
		maturity = new Random().nextInt(states.length)+1;
     	currentState = states['maturity_$maturity'];
     	state = new Random().nextInt(currentState.numFrames);
     	maxState = currentState.numFrames-1;
	}

	void harvest({WebSocket userSocket, String email})
	{
		super.harvest(userSocket:userSocket);

		//give the player the 'fruits' of their labor
		addItemToUser(userSocket,email,new Cherry().getMap(),1,id);
	}
}