part of coUserver;

class StreetSpiritFirebog extends Vendor {
	int openCount = 0;

	StreetSpiritFirebog(String id, String streetName, String tsid, int x, int y) : super(id, streetName, tsid, x, y) {
		speed = 10;
		itemsPredefined = false;
		states = {
			"idle_cry":new Spritesheet("idle_cry", 'http://childrenofur.com/assets/entityImages/street_spirit_firebog_size_large_x1_idle_cry_png_1354832895.png', 856, 732, 107, 244, 24, false),
			"idle_move":new Spritesheet("idle_move", 'http://childrenofur.com/assets/entityImages/street_spirit_firebog_size_large_x1_idle_move_png_1354832884.png', 856, 732, 107, 244, 24, false),
			"open":new Spritesheet("open", 'http://childrenofur.com/assets/entityImages/street_spirit_firebog_size_large_x1_open_png_1354832888.png', 749, 732, 107, 244, 19, false),
			"close":new Spritesheet("close", 'http://childrenofur.com/assets/entityImages/street_spirit_firebog_size_large_x1_close_png_1354832889.png', 963, 488, 107, 244, 17, false),
			"talk":new Spritesheet("talk", 'http://childrenofur.com/assets/entityImages/street_spirit_firebog_size_large_x1_talk_png_1354832886.png', 963, 1708, 107, 244, 17, false)
		};
		currentState = states['idle_move'];
	}

	void update() {
		if(respawn != null && respawn.compareTo(new DateTime.now()) <= 0) {
			//if we just cried, we should say we're facing the other way
			//then we should start moving (that's why we turned around after all)
			if(currentState.stateName == 'idle_cry') {
				if (rand.nextInt(5) == 1) {
					facingRight = !facingRight;
					currentState = states['idle_move'];
					int length = (currentState.numFrames / 30 * 1000).toInt();
					respawn = new DateTime.now().add(new Duration(milliseconds:length));
					return;
				}
			} else {
				//sometimes use talk so that the blinking isn't predictable
				int roll = rand.nextInt(3);
				if(roll == 1) {
					currentState = states['talk'];
				} else {
					currentState = states['idle_move'];
					respawn = null;
				}
				return;
			}
		}
		if(respawn == null) {
			//sometimes move around
			int roll = rand.nextInt(20);
			if(roll == 3) {
				currentState = states['idle_cry'];
				int length = (currentState.numFrames / 30 * 1000).toInt();
				respawn = new DateTime.now().add(new Duration(milliseconds:length));
			}
		}
	}

	@override
	void buy({WebSocket userSocket, String email}) {
		currentState = states['open'];
		//don't go to another state until closed
		respawn = new DateTime.now().add(new Duration(days:50));
		openCount++;

		super.buy(userSocket:userSocket, email:email);
	}

	void sell({WebSocket userSocket, String email}) {
		currentState = states['open'];
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
			currentState = states['close'];
			int length = (currentState.numFrames / 30 * 1000).toInt();
			respawn = new DateTime.now().add(new Duration(milliseconds:length));
		}
	}
}