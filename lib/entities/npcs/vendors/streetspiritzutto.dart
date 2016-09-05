part of entity;

class StreetSpiritZutto extends StreetSpirit {
	StreetSpiritZutto(String id, String streetName, String tsid, num x, num y, num z) : super(id, streetName, tsid, x, y, z) {
		speed = 0;
		itemsPredefined = false;
		states = {
			"hoverIdle":new Spritesheet("hoverIdle", 'http://childrenofur.com/assets/entityImages/street_spirit_zutto_cap_capAqua_x1_hoverIdle_png_1354833704.png', 906, 720, 151, 180, 23, true),
			"groundIdle":new Spritesheet("groundIdle", 'http://childrenofur.com/assets/entityImages/street_spirit_zutto_cap_capAqua_x1_groundIdle_png_1354833699.png', 906, 720, 151, 180, 24, true),
			"raise":new Spritesheet("raise", 'http://childrenofur.com/assets/entityImages/street_spirit_zutto_cap_capAqua_x1_raise_png_1354833702.png', 906, 1080, 151, 180, 31, false),
			"lower":new Spritesheet("lower", 'http://childrenofur.com/assets/entityImages/street_spirit_zutto_cap_capAqua_x1_lower_png_1354833718.png', 906, 900, 151, 180, 26, false),
			"hoverTalk":new Spritesheet("hoverTalk", 'http://childrenofur.com/assets/entityImages/street_spirit_zutto_cap_capAqua_x1_hoverTalk_png_1354833709.png', 906, 1440, 151, 180, 46, true)
		};
		setState('groundIdle');
	}

	@override
	void update({bool simulateTick: false}) {
		super.update();

		if(respawn != null && respawn.compareTo(new DateTime.now()) <= 0) {
			setState('groundIdle');
			respawn = null;
			return;
		}
		if (respawn == null) {
			if(rand.nextInt(4) == 4) {
				// 20% chance to stand up for 5 seconds
				setState('hoverIdle');
			}
		}
	}

	@override
	void buy({WebSocket userSocket, String email}) {
		setState("raise");
		super.buy(userSocket:userSocket, email:email);
	}

	@override
	void sell({WebSocket userSocket, String email}) {
		setState("raise");
		super.sell(userSocket:userSocket, email:email);
	}

	@override
	void close({WebSocket userSocket, String email}) {
		openCount -= 1;
		//if no one else has them open
		if(openCount <= 0) {
			openCount = 0;
			setState("lower");
		}
	}
}