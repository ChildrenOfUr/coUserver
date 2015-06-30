part of coUserver;

class StreetSpiritGroddle extends NPC {
	int openCount = 0;
	StreetSpiritGroddle(String id, int x, int y) : super(id, x, y) {
		actionTime = 0;
		actions
			..add({"action":"buy",
				      "timeRequired":actionTime,
				      "enabled":true,
				      "actionWord":""})
			..add({"action":"sell",
				      "timeRequired":actionTime,
				      "enabled":true,
				      "actionWord":""});

		type = "Street Spirit Groddle";
		speed = -75;

		states = {
			"still":new Spritesheet("still", 'http://c2.glitch.bz/items/2012-12-06/street_spirit_groddle_base_base_L0dirt_bottom_none_eyes_eyes_L0eyes1_skull_skull_L0dirt_top_none_x1_open_png_1354834564.png', 980, 300, 98, 150, 1, false),
			"idle_hold":new Spritesheet("idle_hold", 'http://c2.glitch.bz/items/2012-12-06/street_spirit_groddle_base_base_L0dirt_bottom_none_eyes_eyes_L0eyes1_skull_skull_L0dirt_top_none_x1_idle_hold_png_1354834558.png', 980, 1350, 98, 150, 85, true),
			"idle_move":new Spritesheet("idle_move", 'http://c2.glitch.bz/items/2012-12-06/street_spirit_groddle_base_base_L0dirt_bottom_none_eyes_eyes_L0eyes1_skull_skull_L0dirt_top_none_x1_idle_move_png_1354834567.png', 980, 1800, 98, 150, 119, true),
			"turn":new Spritesheet("turn", 'http://c2.glitch.bz/items/2012-12-06/street_spirit_groddle_base_base_L0dirt_bottom_none_eyes_eyes_L0eyes1_skull_skull_L0dirt_top_none_x1_turn_png_1354834563.png', 980, 600, 98, 150, 37, false),
			"open":new Spritesheet("open", 'http://c2.glitch.bz/items/2012-12-06/street_spirit_groddle_base_base_L0dirt_bottom_none_eyes_eyes_L0eyes1_skull_skull_L0dirt_top_none_x1_open_png_1354834564.png', 980, 300, 98, 150, 19, false),
			"close":new Spritesheet("close", 'http://c2.glitch.bz/items/2012-12-06/street_spirit_groddle_base_base_L0dirt_bottom_none_eyes_eyes_L0eyes1_skull_skull_L0dirt_top_none_x1_close_png_1354834565.png', 882, 300, 98, 150, 17, false),
			"talk":new Spritesheet("talk", 'http://c2.glitch.bz/items/2012-12-06/street_spirit_groddle_base_base_L0dirt_bottom_none_eyes_eyes_L0eyes1_skull_skull_L0dirt_top_none_x1_talk_png_1354834561.png', 882, 300, 98, 150, 17, false)
		};
		currentState = states['idle_hold'];
	}

	void update() {
		if(respawn != null && respawn.compareTo(new DateTime.now()) <= 0) {
			//if we just turned, we should say we're facing the other way
			//then we should start moving (that's why we turned around after all)
			if(currentState.stateName == 'turn') {
				facingRight = !facingRight;
				currentState = states['idle_move'];
				int length = (currentState.numFrames / 30 * 1000).toInt();
				respawn = new DateTime.now().add(new Duration(milliseconds:length));
				return;
			} else {
				//sometimes use still so that the blinking isn't predictable
				int roll = rand.nextInt(3);
				if(roll == 1) {
					currentState = states['still'];
				} else {
					currentState = states['idle_hold'];
					respawn = null;
				}
				return;
			}
		}
		if(respawn == null) {
			//sometimes move around
			int roll = rand.nextInt(20);
			if(roll == 3) {
				currentState = states['turn'];
				int length = (currentState.numFrames / 30 * 1000).toInt();
				respawn = new DateTime.now().add(new Duration(milliseconds:length));
			}
		}
	}

	void buy({WebSocket userSocket, String email}) {
		currentState = states['open'];
		//don't go to another state until closed
		respawn = new DateTime.now().add(new Duration(days:50));
		openCount++;

		Map map = {};
		map['vendorName'] = type;
		map['id'] = id;
		map['itemsForSale'] = _getItemsForSale();
		userSocket.add(JSON.encode(map));
	}

	void sell({WebSocket userSocket, String email}) {
		currentState = states['open'];
		//don't go to another state until closed
		respawn = new DateTime.now().add(new Duration(days:50));
		openCount++;

		//prepare the buy window at the same time
		Map map = {};
		map['vendorName'] = type;
		map['id'] = id;
		map['itemsForSale'] = _getItemsForSale();
		map['openWindow'] = 'vendorSell';
		userSocket.add(JSON.encode(map));
	}

	void close({WebSocket userSocket, String email}) {
		openCount -= 1;
		//if no one else has them open
		if(openCount <= 0) {
			openCount = 0;
			currentState = states['close'];
			int length = (currentState.numFrames / 30 * 1000).toInt();
			respawn = new DateTime.now().add(new Duration(milliseconds:length));
		}
	}

	buyItem({WebSocket userSocket, String itemName, int num, String email}) async {
		StatBuffer.incrementStat("itemsBoughtFromVendors", num);
		Item item = items[itemName];

		Metabolics m = await getMetabolics(email:email);
		if(m.currants >= item.price * num) {
			m.currants -= item.price * num;
			setMetabolics(m);
			addItemToUser(userSocket, email, item.getMap(), num, id);
		}
	}

	sellItem({WebSocket userSocket, String itemName, int num, String email}) async {
		bool success = await takeItemFromUser(userSocket, email, itemName, num);

		if(success) {
			Item item = items[itemName];

			Metabolics m = await getMetabolics(email:email);
			m.currants += (item.price * num * .7) ~/ 1;
			setMetabolics(m);
		}
	}

	List _getItemsForSale() {
		List<Map> saleItems = [];

    saleItems.add(items['Coffee'].getMap());
    saleItems.add(items['Spinach'].getMap());
    saleItems.add(items['Butterfly Lotion'].getMap());
    saleItems.add(items['Quill'].getMap());
    saleItems.add(items['Million Currant Trophy'].getMap());
    saleItems.add(items['Seed_Broccoli'].getMap());
    saleItems.add(items['Seed_Cabbage'].getMap());
    saleItems.add(items['Seed_Carrot'].getMap());
    saleItems.add(items['Seed_Corn'].getMap());
    saleItems.add(items['Seed_Cucumber'].getMap());
    saleItems.add(items['Seed_Onion'].getMap());
    saleItems.add(items['Seed_Parsnip'].getMap());
    saleItems.add(items['Seed_Potato'].getMap());
    saleItems.add(items['Seed_Pumpkin'].getMap());
    saleItems.add(items['Seed_Rice'].getMap());
    saleItems.add(items['Seed_Spinach'].getMap());
    saleItems.add(items['Seed_Tomato'].getMap());
    saleItems.add(items['Seed_Zucchini'].getMap());

		return saleItems;
	}
}