part of coUserver;

class DirtPile extends Plant {
	DirtPile(String id, int x, int y) : super(id, x, y) {
		actionTime = 3000;
		type = "Dirt Pile";

		actions.add({"action":"dig",
			            "actionWord":"digging",
			            "timeRequired":actionTime,
			            "enabled":true,
			            "requires":[
				            {
					            "num":1,
					            "of":["Shovel", "Ace of Spades"]
				            }
			            ]
		            });

		states =
		{
			"maturity_1" : new Spritesheet("maturity_1", "http://c2.glitch.bz/items/2012-12-06/dirt_pile_dirt_state_x11_1_variant_dirt1_1_png_1354833756.png", 780, 213, 195, 71, 11, false),
			"maturity_2" : new Spritesheet("maturity_2", "http://c2.glitch.bz/items/2012-12-06/dirt_pile_dirt_state_x11_1_variant_dirt2_1_png_1354833757.png", 780, 213, 195, 71, 11, false)
		};
		int maturity = new Random().nextInt(states.length) + 1;
		currentState = states['maturity_$maturity'];
		state = new Random().nextInt(currentState.numFrames);
		maxState = 0;
	}

	@override
	void update() {
		if(state >= currentState.numFrames)
			setActionEnabled("dig", false);

		if(respawn != null && new DateTime.now().compareTo(respawn) >= 0) {
			state = 0;
			setActionEnabled("dig", true);
			respawn = null;
		}

		if(state < maxState)
			state = maxState;
	}

	Future<bool> dig({WebSocket userSocket, String email}) async {
		Metabolics m = await getMetabolics(email:email);
		if(m.energy < 5) {
			return false;
		} else {
			m.energy -= 5;
			m.img = m.img + (10 * ((100 / m.max_mood) * (m.mood / 100))).round();
			int result = await setMetabolics(m);
			if(result < 1) {
				return false;
			}
		}

		StatBuffer.incrementStat("dirtDug", 1);
		state++;
		if(state >= currentState.numFrames)
			respawn = new DateTime.now().add(new Duration(minutes:2));

		//give the player the 'fruits' of their labor
		addItemToUser(userSocket, email, items['Lump of Earth'].getMap(), 1, id);

		//1 in 10 chance to get a lump of loam as well
		if(new Random().nextInt(10) == 5)
			addItemToUser(userSocket, email, items['Lump of Loam'].getMap(), 1, id);

		return true;
	}
}