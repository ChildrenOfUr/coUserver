part of coUserver;

class StreetSpiritZutto extends Vendor {
	int openCount = 0;

	StreetSpiritZutto(String id, String streetName, String tsid, int x, int y) : super(id, streetName, tsid, x, y) {
		speed = 0;
		itemsPredefined = false;
		states = {
			"hoverIdle":new Spritesheet("hoverIdle", 'http://c2.glitch.bz/items/2012-12-06/street_spirit_zutto_cap_capAqua_x1_hoverIdle_png_1354833704.png', 906, 720, 151, 180, 23, true),
			"groundIdle":new Spritesheet("groundIdle", 'http://c2.glitch.bz/items/2012-12-06/street_spirit_zutto_cap_capAqua_x1_groundIdle_png_1354833699.png', 906, 720, 151, 180, 24, true),
			"raise":new Spritesheet("raise", 'http://c2.glitch.bz/items/2012-12-06/street_spirit_zutto_cap_capAqua_x1_raise_png_1354833702.png', 906, 1080, 151, 180, 31, false),
			"lower":new Spritesheet("lower", 'http://c2.glitch.bz/items/2012-12-06/street_spirit_zutto_cap_capAqua_x1_lower_png_1354833718.png', 906, 900, 151, 180, 26, false),
			"hoverTalk":new Spritesheet("hoverTalk", 'http://c2.glitch.bz/items/2012-12-06/street_spirit_zutto_cap_capAqua_x1_hoverTalk_png_1354833709.png', 906, 1440, 151, 180, 46, true)
		};
		currentState = states['groundIdle'];
	}

	void update() {
		if(respawn != null && respawn.compareTo(new DateTime.now()) <= 0) {
			currentState = states['groundIdle'];
			respawn = null;
			return;
		}
		if (respawn == null) {
			if(rand.nextInt(4) == 4) {
				// 20% chance to stand up for 5 seconds
				currentState = states['hoverIdle'];
				int length = (5000 * (currentState.numFrames / 30 * 1000)).toInt();
				respawn = new DateTime.now().add(new Duration(milliseconds:length));
			}
		}
	}

	@override
	void buy({WebSocket userSocket, String email}) {
		currentState = states["raise"];
		//don't go to another state until closed
		respawn = new DateTime.now().add(new Duration(days:50));
		openCount++;

		super.buy(userSocket:userSocket, email:email);
	}

	void sell({WebSocket userSocket, String email}) {
		currentState = states["raise"];
		//don't go to another state until closed
		respawn = new DateTime.now().add(new Duration(days:50));
		openCount++;

		super.sell(userSocket:userSocket, email:email);
	}

	void close({WebSocket userSocket, String email}) {
		openCount -= 1;
		//if no one else has them open
		if(openCount <= 0) {
			openCount = 0;
			currentState = states["lower"];
			int length = (currentState.numFrames / 30 * 1000).toInt();
			respawn = new DateTime.now().add(new Duration(milliseconds:length));
		}
	}
}