part of coUserver;

class HeliKitty extends NPC {
	int age;

	HeliKitty(String id, int x, int y) : super(id, x, y) {
		type = "Heli Kitty";
		actions
			..add({
				      "action": "pet",
				      "timeRequired": actionTime,
				      "enabled": true,
				      "actionWord": "petting",
				      "requires":[
					      {
						      'num':5,
						      'of':['energy']
					      }
				      ]
			      });
		speed = 10; //pixels per second
		age = 3; //TODO: make them get older
		states = {
			// newborn (variation 1)
			"1blink": new Spritesheet("1blink",
			                          "http://childrenofur.com/assets/entityImages/npc_kitty_chicken__x1_1blink_png_1354840541.png",
			                          680, 115, 136, 115, 5, false),
			"1jumpAntic": new Spritesheet("1jumpAntic",
			                              "http://childrenofur.com/assets/entityImages/npc_kitty_chicken__x1_1jumpAntic_png_1354840542.png",
			                              544, 230, 136, 115, 8, false),
			"1jump": new Spritesheet("1jump",
			                         "http://childrenofur.com/assets/entityImages/npc_kitty_chicken__x1_1jump_png_1354840543.png",
			                         816, 345, 136, 115, 16, true),
			"1rollStart": new Spritesheet("1rollStart",
			                              "http://childrenofur.com/assets/entityImages/npc_kitty_chicken__x1_1rollStart_png_1354840544.png",
			                              272, 115, 136, 115, 2, false),
			"1roll": new Spritesheet("1roll",
			                         "http://childrenofur.com/assets/entityImages/npc_kitty_chicken__x1_1roll_png_1354840544.png",
			                         816, 230, 136, 115, 12, true),
			"1sleepStart": new Spritesheet("1sleepStart",
			                               "http://childrenofur.com/assets/entityImages/npc_kitty_chicken__x1_1sleepStart_png_1354840546.png",
			                               952, 460, 136, 115, 26, false),
			"1sleep": new Spritesheet("1sleep",
			                          "http://childrenofur.com/assets/entityImages/npc_kitty_chicken__x1_1sleep_png_1354840547.pngg",
			                          952, 1035, 136, 115, 57, true),
			// kitten (variation 2)
			"2blink": new Spritesheet("2blink",
			                          "http://childrenofur.com/assets/entityImages/npc_kitty_chicken__x1_2blink_png_1354840549.png",
			                          680, 115, 136, 115, 20, true),
			"2fly": new Spritesheet("2fly",
			                        "http://childrenofur.com/assets/entityImages/npc_kitty_chicken__x1_3fly_png_1354840558.png",
			                        952, 345, 136, 115, 20, true),
			"2hitBall": new Spritesheet("2hitBall",
			                            "http://childrenofur.com/assets/entityImages/npc_kitty_chicken__x1_2hitBall_png_1354840552.png",
			                            680, 230, 136, 115, 9, false),
			"2jumpAntic": new Spritesheet("2jumpAntic",
			                              "http://childrenofur.com/assets/entityImages/npc_kitty_chicken__x1_2jumpAntic_png_1354840549.png",
			                              544, 230, 136, 115, 8, false),
			"2jump": new Spritesheet("2jump",
			                         "http://childrenofur.com/assets/entityImages/npc_kitty_chicken__x1_2jump_png_1354840550.png",
			                         816, 345, 136, 115, 16, true),
			"2sleepStart": new Spritesheet("2sleepStart",
			                               "http://childrenofur.com/assets/entityImages/npc_kitty_chicken__x1_2sleepStart_png_1354840553.png",
			                               952, 460, 136, 115, 26, false),
			"2sleep": new Spritesheet("2sleep",
			                          "http://childrenofur.com/assets/entityImages/npc_kitty_chicken__x1_2sleep_png_1354840554.png",
			                          952, 1035, 136, 115, 26, true),
			// adult (variation 3)
			"3appear": new Spritesheet("3appear",
			                           "http://childrenofur.com/assets/entityImages/npc_kitty_chicken__x1_3appear_png_1354840565.png",
			                           952, 805, 136, 115, 47, false),
			"3blink": new Spritesheet("3blink",
			                          "http://childrenofur.com/assets/entityImages/npc_kitty_chicken__x1_3blink_png_1354840555.png",
			                          680, 115, 136, 115, 5, false),
			"3chew": new Spritesheet("3chew",
			                         "http://childrenofur.com/assets/entityImages/npc_kitty_chicken__x1_3chew_png_1354840562.png",
			                         680, 345, 136, 115, 15, true),
			"3disappear": new Spritesheet("3disappear",
			                              "http://childrenofur.com/assets/entityImages/npc_kitty_chicken__x1_3disappear_png_1354840566.png",
			                              952, 460, 136, 115, 27, false),
			"3fly": new Spritesheet("3fly",
			                        "http://childrenofur.com/assets/entityImages/npc_kitty_chicken__x1_3fly_png_1354840558.png",
			                        952, 345, 136, 115, 20, true),
			"3happy": new Spritesheet("3happy",
			                          "http://childrenofur.com/assets/entityImages/npc_kitty_chicken__x1_3happy_png_1354840564.png",
			                          952, 690, 136, 115, 38, false),
			"3hitBall": new Spritesheet("3hitBall",
			                            "http://childrenofur.com/assets/entityImages/npc_kitty_chicken__x1_3hitBall_png_1354840558.png",
			                            680, 230, 136, 115, 9, false),
			"3jumpAntic": new Spritesheet("3jumpAntic",
			                              "http://childrenofur.com/assets/entityImages/npc_kitty_chicken__x1_3jumpAntic_png_1354840556.png",
			                              544, 230, 136, 115, 8, false),
			"3jump": new Spritesheet("3jump",
			                         "http://childrenofur.com/assets/entityImages/npc_kitty_chicken__x1_3jump_png_1354840557.png",
			                         816, 345, 136, 115, 16, true),
			"3sad": new Spritesheet("3sad",
			                        "http://childrenofur.com/assets/entityImages/npc_kitty_chicken__x1_3sad_png_1354840563.png",
			                        816, 345, 136, 115, 17, false),
			"3sleepStart": new Spritesheet("3sleepStart",
			                               "http://childrenofur.com/assets/entityImages/npc_kitty_chicken__x1_3sleepStart_png_1354840559.png",
			                               952, 460, 136, 115, 26, false),
			"3sleep": new Spritesheet("3sleep",
			                          "http://childrenofur.com/assets/entityImages/npc_kitty_chicken__x1_3sleep_png_1354840561.png",
			                          952, 1035, 136, 115, 57, true)
		};
		currentState = states[sheetName("fly")];
		responses = {
			"pet": ["...purring noises..."]
		};
	}

	Future<bool> pet({WebSocket userSocket, String email}) async {
		bool success = await super.trySetMetabolics(email, energy:-5, mood:20, imgMin:10, imgRange:4);
		if(!success) {
			return false;
		}
		currentState = states[sheetName("hitBall")];
		respawn = new DateTime.now().add(new Duration(milliseconds: (currentState.numFrames / 30 * 1000).toInt()));
		StatBuffer.incrementStat("helikittiesPetted", 1);
		say(responses['pet'].elementAt(rand.nextInt(responses['pet'].length)));
		return true;
	}

	update() {
		if(currentState.stateName == sheetName("fly")) {
			//we need to update x to hopefully stay in sync with clients
			if(facingRight) {
				x += speed;
			} else {
				x -= speed;
			}

			if(x < 0) {
				x = 0;
			} else if(x > 4000) {
				//TODO temporary
				x = 4000;
			}
		}

		// If respawn is in the past, it is time to choose a new animation
		if(respawn != null && new DateTime.now().compareTo(respawn) > 0) {
			currentState = states[sheetName("fly")];
			respawn = null;
			// 50% chance to change direction
			if(rand.nextInt(2) == 1) {
				facingRight = !facingRight;
			}
		}
	}

	String sheetName(String sheet) {
		// Returns the correct sprite sheet for the heli kitty's age
		// Use only for sheets that exist in all three ages
		return age.toString() + sheet;
	}
}