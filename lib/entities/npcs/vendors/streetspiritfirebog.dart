part of entity;

class StreetSpiritFirebog extends StreetSpirit {
	StreetSpiritFirebog(String id, String streetName, String tsid, num x, num y, num z) : super(id, streetName, tsid, x, y, z) {
		itemsPredefined = false;
		states = {
			"idle_cry":new Spritesheet("idle_cry", 'http://childrenofur.com/assets/entityImages/street_spirit_firebog_size_large_x1_idle_cry_png_1354832895.png', 856, 732, 107, 244, 24, false),
			"idle_move":new Spritesheet("idle_move", 'http://childrenofur.com/assets/entityImages/street_spirit_firebog_size_large_x1_idle_move_png_1354832884.png', 856, 732, 107, 244, 24, false),
			"open":new Spritesheet("open", 'http://childrenofur.com/assets/entityImages/street_spirit_firebog_size_large_x1_open_png_1354832888.png', 749, 732, 107, 244, 19, false),
			"close":new Spritesheet("close", 'http://childrenofur.com/assets/entityImages/street_spirit_firebog_size_large_x1_close_png_1354832889.png', 963, 488, 107, 244, 17, false),
			"talk":new Spritesheet("talk", 'http://childrenofur.com/assets/entityImages/street_spirit_firebog_size_large_x1_talk_png_1354832886.png', 963, 1708, 107, 244, 17, false)
		};
		setState('idle_move');
	}

	void update({bool simulateTick: false}) {
		super.update();

		if(respawn != null && respawn.compareTo(new DateTime.now()) <= 0) {
			//if we just cried, we should say we're facing the other way
			//then we should start moving (that's why we turned around after all)
			if(currentState.stateName == 'idle_cry') {
				if (rand.nextInt(5) == 1) {
					facingRight = !facingRight;
					setState('idle_move');
					return;
				}
			} else {
				//sometimes use talk so that the blinking isn't predictable
				int roll = rand.nextInt(3);
				if(roll == 1) {
					setState('talk');
				} else {
					setState('idle_move');
					respawn = null;
				}
				return;
			}
		}
		if(respawn == null) {
			//sometimes move around
			int roll = rand.nextInt(20);
			if(roll == 3) {
				setState('idle_cry');
			}
		}
	}

	@override
	void buy({WebSocket userSocket, String email}) {
		setState('open');
		super.buy(userSocket: userSocket, email: email);
	}

	void sell({WebSocket userSocket, String email}) {
		setState('open');
		super.sell(userSocket:userSocket, email:email);
	}
}