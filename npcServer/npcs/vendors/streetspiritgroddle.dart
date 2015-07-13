part of coUserver;

class StreetSpiritGroddle extends Vendor {
	int openCount = 0;
	Clock clock = new Clock();

	StreetSpiritGroddle(String id, String streetName, int x, int y) : super(id, streetName, x, y) {
		speed = -75;
		itemsPredefined = false;

		Map <String, Map<String, Spritesheet>> AllStates = {
			"alph": {
				"day": {

				},
				"night": {

				}
			},
			"cosma": {
				"day": {
					"close": new Spritesheet("close", "http://c2.glitch.bz/items/2012-12-06/street_spirit_groddle_base_base_L0dirt_bottom_none_eyes_eyes_L0eyes2_skull_skull_L0dirt_top_none_x1_close_png_1354834586.png", 882, 300, 98, 150, 17, false),
					"idle_hold": new Spritesheet("idle_hold", "http://c2.glitch.bz/items/2012-12-06/street_spirit_groddle_base_base_L0dirt_bottom_none_eyes_eyes_L0eyes2_skull_skull_L0dirt_top_none_x1_idle_hold_png_1354834580.png", 980, 1350, 98, 150, 85, true),
					"idle_move": new Spritesheet("idle_move", "http://c2.glitch.bz/items/2012-12-06/street_spirit_groddle_base_base_L0dirt_bottom_none_eyes_eyes_L0eyes2_skull_skull_L0dirt_top_none_x1_idle_move_png_1354834588.png", 980, 1800, 98, 150, 119, true),
					"open": new Spritesheet("open", "http://c2.glitch.bz/items/2012-12-06/street_spirit_groddle_base_base_L0dirt_bottom_none_eyes_eyes_L0eyes2_skull_skull_L0dirt_top_none_x1_open_png_1354834585.png", 980, 300, 98, 150, 19, false),
					"still": new Spritesheet("open", "http://c2.glitch.bz/items/2012-12-06/street_spirit_groddle_base_base_L0dirt_bottom_none_eyes_eyes_L0eyes2_skull_skull_L0dirt_top_none_x1_open_png_1354834585.png", 980, 300, 98, 150, 1, false),
					"talk": new Spritesheet("talk", "http://c2.glitch.bz/items/2012-12-06/street_spirit_groddle_base_base_L0dirt_bottom_none_eyes_eyes_L0eyes2_skull_skull_L0dirt_top_none_x1_talk_png_1354834582.png", 980, 1200, 98, 150, 73, false),
					"turn": new Spritesheet("turn", "http://c2.glitch.bz/items/2012-12-06/street_spirit_groddle_base_base_L0dirt_bottom_none_eyes_eyes_L0eyes2_skull_skull_L0dirt_top_none_x1_turn_png_1354834584.png", 980, 600, 98, 150, 37, false)
				},
				"night": {
					"close": new Spritesheet("close", "http://c2.glitch.bz/items/2012-12-06/street_spirit_groddle_base_base_L0dirt_bottom_none_eyes_eyes_L0eyes3_skull_skull_L0dirt_top_none_x1_close_png_1354834609.png", 882, 300, 98, 150, 17, false),
					"idle_hold": new Spritesheet("idle_hold", "http://c2.glitch.bz/items/2012-12-06/street_spirit_groddle_base_base_L0dirt_bottom_none_eyes_eyes_L0eyes3_skull_skull_L0dirt_top_none_x1_idle_hold_png_1354834601.png", 980, 1350, 98, 150, 85, true),
					"idle_move": new Spritesheet("idle_move", "http://c2.glitch.bz/items/2012-12-06/street_spirit_groddle_base_base_L0dirt_bottom_none_eyes_eyes_L0eyes3_skull_skull_L0dirt_top_none_x1_idle_move_png_1354834611.png", 980, 1800, 98, 150, 119, true),
					"open": new Spritesheet("open", "http://c2.glitch.bz/items/2012-12-06/street_spirit_groddle_base_base_L0dirt_bottom_none_eyes_eyes_L0eyes3_skull_skull_L0dirt_top_none_x1_open_png_1354834608.png", 980, 300, 98, 150, 19, false),
					"still": new Spritesheet("open", "http://c2.glitch.bz/items/2012-12-06/street_spirit_groddle_base_base_L0dirt_bottom_none_eyes_eyes_L0eyes3_skull_skull_L0dirt_top_none_x1_open_png_1354834608.png", 980, 300, 98, 150, 1, false),
					"talk": new Spritesheet("talk", "http://c2.glitch.bz/items/2012-12-06/street_spirit_groddle_base_base_L0dirt_bottom_none_eyes_eyes_L0eyes3_skull_skull_L0dirt_top_none_x1_talk_png_1354834604.png", 980, 1200, 98, 150, 73, false),
					"turn": new Spritesheet("turn", "http://c2.glitch.bz/items/2012-12-06/street_spirit_groddle_base_base_L0dirt_bottom_none_eyes_eyes_L0eyes3_skull_skull_L0dirt_top_none_x1_turn_png_1354834606.png", 980, 600, 98, 150, 37, false)
				}
			},
			"friendly": {
				"day": {

				},
				"night": {

				}
			},
			"grendaline": {
				"day": {

				},
				"night": {

				}
			},
			"humbaba": {
				"day": {

				},
				"night": {

				}
			},
			"lem": {
				"day": {

				},
				"night": {

				}
			},
			"mab": {
				"day": {

				},
				"night": {

				}
			},
			"pot": {
				"day": {

				},
				"night": {

				}
			},
			"spriggan": {
				"day": {
					"close": new Spritesheet("close", "http://c2.glitch.bz/items/2012-12-06/street_spirit_groddle_base_base_L1dirt_bottom_bottom_L1Branches_eyes_eyes_L1eyes2_skull_skull_L1dirt_top_top_L1dirtSpikey_x1_close_png_1354835264.png", 930, 582, 155, 194, 17, false),
					"idle_hold": new Spritesheet("idle_hold", "http://c2.glitch.bz/items/2012-12-06/street_spirit_groddle_base_base_L1dirt_bottom_bottom_L1Branches_eyes_eyes_L1eyes2_skull_skull_L1dirt_top_top_L1dirtSpikey_x1_idle_hold_png_1354835252.png", 930, 960, 191, 192, 21, false),
					"idle_move": new Spritesheet("idle_move", "http://c2.glitch.bz/items/2012-12-06/street_spirit_groddle_base_base_L1dirt_bottom_bottom_L1Branches_eyes_eyes_L1eyes2_skull_skull_L1dirt_top_top_L1dirtSpikey_x1_idle_move_png_1354835269.png", 930, 3880, 155, 194, 119, true),
					"open": new Spritesheet("open", "http://c2.glitch.bz/items/2012-12-06/street_spirit_groddle_base_base_L1dirt_bottom_bottom_L1Branches_eyes_eyes_L1eyes2_skull_skull_L1dirt_top_top_L1dirtSpikey_x1_open_png_1354835263.png", 775, 776, 155, 194, 19, false),
					"still": new Spritesheet("still", "http://c2.glitch.bz/items/2012-12-06/street_spirit_groddle_base_base_L1dirt_bottom_bottom_L1Branches_eyes_eyes_L1eyes2_skull_skull_L1dirt_top_top_L1dirtSpikey_x1_open_png_1354835263.png", 775, 776, 155, 194, 1, false),
					"talk": new Spritesheet("talk", "http://c2.glitch.bz/items/2012-12-06/street_spirit_groddle_base_base_L1dirt_bottom_bottom_L1Branches_eyes_eyes_L1eyes2_skull_skull_L1dirt_top_top_L1dirtSpikey_x1_talk_png_1354835257.png", 930, 2522, 155, 194, 73, false),
					"turn": new Spritesheet("turn", "http://c2.glitch.bz/items/2012-12-06/street_spirit_groddle_base_base_L1dirt_bottom_bottom_L1Branches_eyes_eyes_L1eyes2_skull_skull_L1dirt_top_top_L1dirtSpikey_x1_turn_png_1354835260.png", 930, 1358, 155, 194, 37, false)
				},
				"night": {
					"close": new Spritesheet("close", "http://c2.glitch.bz/items/2012-12-06/street_spirit_groddle_base_base_L1dirt_bottom_bottom_L1Branches_eyes_eyes_L1eyes3_skull_skull_L1dirt_top_top_L1dirtSpikey_x1_close_png_1354835298.png", 930, 582, 155, 194, 17, false),
					"idle_hold": new Spritesheet("idle_hold", "http://c2.glitch.bz/items/2012-12-06/street_spirit_groddle_base_base_L1dirt_bottom_bottom_L1Branches_eyes_eyes_L1eyes3_skull_skull_L1dirt_top_top_L1dirtSpikey_x1_idle_hold_png_1354835285.png", 930, 2910, 155, 194, 85, true),
					"idle_move": new Spritesheet("idle_move", "http://c2.glitch.bz/items/2012-12-06/street_spirit_groddle_base_base_L1dirt_bottom_bottom_L1Branches_eyes_eyes_L1eyes3_skull_skull_L1dirt_top_top_L1dirtSpikey_x1_idle_move_png_1354835302.png", 930, 3880, 155, 194, 119, true),
					"open": new Spritesheet("open", "http://c2.glitch.bz/items/2012-12-06/street_spirit_groddle_base_base_L1dirt_bottom_bottom_L1Branches_eyes_eyes_L1eyes3_skull_skull_L1dirt_top_top_L1dirtSpikey_x1_open_png_1354835296.png", 775, 776, 155, 194, 19, false),
					"still": new Spritesheet("still", "http://c2.glitch.bz/items/2012-12-06/street_spirit_groddle_base_base_L1dirt_bottom_bottom_L1Branches_eyes_eyes_L1eyes3_skull_skull_L1dirt_top_top_L1dirtSpikey_x1_open_png_1354835296.png", 775, 776, 155, 194, 1, false),
					"talk": new Spritesheet("talk", "http://c2.glitch.bz/items/2012-12-06/street_spirit_groddle_base_base_L1dirt_bottom_bottom_L1Branches_eyes_eyes_L1eyes3_skull_skull_L1dirt_top_top_L1dirtSpikey_x1_talk_png_1354835291.png", 930, 2522, 155, 194, 73, false),
					"turn": new Spritesheet("turn", "http://c2.glitch.bz/items/2012-12-06/street_spirit_groddle_base_base_L1dirt_bottom_bottom_L1Branches_eyes_eyes_L1eyes3_skull_skull_L1dirt_top_top_L1dirtSpikey_x1_turn_png_1354835294.png", 930, 1358, 155, 194, 37, false)
				}
			},
			"tii": {
				"day": {

				},
				"night": {

				}
			},
			"zille": {
				"day": {

				},
				"night": {

				}
			},
		};

		// which "skin" to use

		String giantName; // TODO: get this, either by looking at street shrines dynamically on the server or by collecting it in JSON
		String time;

		// night or day

		bool am = clock.time.contains('am');
		List<String> hourmin = clock.time.substring(0, clock.time.length - 2).split(':');
		int hour = int.parse(hourmin[0]);
		if(!am) {
			if(hour >= 5 && hour < 7) {
				// daylight to sunset
				time = 'day';
			} else if(hour >= 7 && hour < 12) {
				// sunset to night
				time = 'night';
			} else {
				time = 'day';
			}
		} else if (am) {
			if(hour < 5 || hour == 12) {
				time = 'night';
			} else if(hour >= 5 && hour < 7) {
				// night to sunrise
				time = 'night';
			} else if(hour >= 7 && hour < 9) {
				// sunrise to daylight
				time = 'day';
			} else {
				time = 'day';
			}
		}

		// assign
		//states = AllStates[giantName][time];
		states = AllStates['spriggan']['night'];

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