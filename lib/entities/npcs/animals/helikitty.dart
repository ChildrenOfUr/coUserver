part of entity;

class HeliKitty extends NPC {
	int age;
    static final String SKILL = 'animal_kinship';

	HeliKitty(String id, num x, num y, num z, num rotation, bool h_flip, String streetName) : super(id, x, y, z, rotation, h_flip, streetName) {
		type = "Heli Kitty";
		actions.add(
			new Action.withName('pet')
				..timeRequired = actionTime
				..actionWord = 'petting'
				..energyRequirements = new EnergyRequirements(energyAmount: 5)
		);
		speed = 75; //pixels per second
		renameable = true;
		age = 3; //TODO: make them get older
		states = {
			// newborn (variation 1)
			"1blink": new Spritesheet("1blink",
			                          "https://childrenofur.com/assets/entityImages/npc_kitty_chicken__x1_1blink_png_1354840541.png",
			                          680, 115, 136, 115, 5, false),
			"1jumpAntic": new Spritesheet("1jumpAntic",
			                              "https://childrenofur.com/assets/entityImages/npc_kitty_chicken__x1_1jumpAntic_png_1354840542.png",
			                              544, 230, 136, 115, 8, false),
			"1jump": new Spritesheet("1jump",
			                         "https://childrenofur.com/assets/entityImages/npc_kitty_chicken__x1_1jump_png_1354840543.png",
			                         816, 345, 136, 115, 16, true),
			"1rollStart": new Spritesheet("1rollStart",
			                              "https://childrenofur.com/assets/entityImages/npc_kitty_chicken__x1_1rollStart_png_1354840544.png",
			                              272, 115, 136, 115, 2, false),
			"1roll": new Spritesheet("1roll",
			                         "https://childrenofur.com/assets/entityImages/npc_kitty_chicken__x1_1roll_png_1354840544.png",
			                         816, 230, 136, 115, 12, true),
			"1sleepStart": new Spritesheet("1sleepStart",
			                               "https://childrenofur.com/assets/entityImages/npc_kitty_chicken__x1_1sleepStart_png_1354840546.png",
			                               952, 460, 136, 115, 26, false),
			"1sleep": new Spritesheet("1sleep",
			                          "https://childrenofur.com/assets/entityImages/npc_kitty_chicken__x1_1sleep_png_1354840547.pngg",
			                          952, 1035, 136, 115, 57, true),
			// kitten (variation 2)
			"2blink": new Spritesheet("2blink",
			                          "https://childrenofur.com/assets/entityImages/npc_kitty_chicken__x1_2blink_png_1354840549.png",
			                          680, 115, 136, 115, 20, true),
			"2fly": new Spritesheet("2fly",
			                        "https://childrenofur.com/assets/entityImages/npc_kitty_chicken__x1_3fly_png_1354840558.png",
			                        952, 345, 136, 115, 20, true),
			"2hitBall": new Spritesheet("2hitBall",
			                            "https://childrenofur.com/assets/entityImages/npc_kitty_chicken__x1_2hitBall_png_1354840552.png",
			                            680, 230, 136, 115, 9, false),
			"2jumpAntic": new Spritesheet("2jumpAntic",
			                              "https://childrenofur.com/assets/entityImages/npc_kitty_chicken__x1_2jumpAntic_png_1354840549.png",
			                              544, 230, 136, 115, 8, false),
			"2jump": new Spritesheet("2jump",
			                         "https://childrenofur.com/assets/entityImages/npc_kitty_chicken__x1_2jump_png_1354840550.png",
			                         816, 345, 136, 115, 16, true),
			"2sleepStart": new Spritesheet("2sleepStart",
			                               "https://childrenofur.com/assets/entityImages/npc_kitty_chicken__x1_2sleepStart_png_1354840553.png",
			                               952, 460, 136, 115, 26, false),
			"2sleep": new Spritesheet("2sleep",
			                          "https://childrenofur.com/assets/entityImages/npc_kitty_chicken__x1_2sleep_png_1354840554.png",
			                          952, 1035, 136, 115, 26, true),
			// adult (variation 3)
			"3appear": new Spritesheet("3appear",
			                           "https://childrenofur.com/assets/entityImages/npc_kitty_chicken__x1_3appear_png_1354840565.png",
			                           952, 805, 136, 115, 47, false),
			"3blink": new Spritesheet("3blink",
			                          "https://childrenofur.com/assets/entityImages/npc_kitty_chicken__x1_3blink_png_1354840555.png",
			                          680, 115, 136, 115, 5, false),
			"3chew": new Spritesheet("3chew",
			                         "https://childrenofur.com/assets/entityImages/npc_kitty_chicken__x1_3chew_png_1354840562.png",
			                         680, 345, 136, 115, 15, true),
			"3disappear": new Spritesheet("3disappear",
			                              "https://childrenofur.com/assets/entityImages/npc_kitty_chicken__x1_3disappear_png_1354840566.png",
			                              952, 460, 136, 115, 27, false),
			"3fly": new Spritesheet("3fly",
			                        "https://childrenofur.com/assets/entityImages/npc_kitty_chicken__x1_3fly_png_1354840558.png",
			                        952, 345, 136, 115, 20, true),
			"3happy": new Spritesheet("3happy",
			                          "https://childrenofur.com/assets/entityImages/npc_kitty_chicken__x1_3happy_png_1354840564.png",
			                          952, 690, 136, 115, 38, false),
			"3hitBall": new Spritesheet("3hitBall",
			                            "https://childrenofur.com/assets/entityImages/npc_kitty_chicken__x1_3hitBall_png_1354840558.png",
			                            680, 230, 136, 115, 9, false),
			"3jumpAntic": new Spritesheet("3jumpAntic",
			                              "https://childrenofur.com/assets/entityImages/npc_kitty_chicken__x1_3jumpAntic_png_1354840556.png",
			                              544, 230, 136, 115, 8, false),
			"3jump": new Spritesheet("3jump",
			                         "https://childrenofur.com/assets/entityImages/npc_kitty_chicken__x1_3jump_png_1354840557.png",
			                         816, 345, 136, 115, 16, true),
			"3sad": new Spritesheet("3sad",
			                        "https://childrenofur.com/assets/entityImages/npc_kitty_chicken__x1_3sad_png_1354840563.png",
			                        816, 345, 136, 115, 17, false),
			"3sleepStart": new Spritesheet("3sleepStart",
			                               "https://childrenofur.com/assets/entityImages/npc_kitty_chicken__x1_3sleepStart_png_1354840559.png",
			                               952, 460, 136, 115, 26, false),
			"3sleep": new Spritesheet("3sleep",
			                          "https://childrenofur.com/assets/entityImages/npc_kitty_chicken__x1_3sleep_png_1354840561.png",
			                          952, 1035, 136, 115, 57, true)
		};
		setState(sheetName("fly"));
		responses = {
			"pet": [":3"]
		};
	}

	Future<bool> pet({WebSocket userSocket, String email}) async {
		MetabolicsChange mc = new MetabolicsChange();
		bool success = await mc.trySetMetabolics(email, energy:-5, mood:20, imgMin:10, imgRange:4);
		if(!success) {
			return false;
		}
		setState(sheetName("hitBall"));
		StatManager.add(email, Stat.heli_kitties_petted);
        SkillManager.learn(SKILL, email);
		playSound('purr', userSocket);
		say(responses['pet'].elementAt(rand.nextInt(responses['pet'].length)));
		return true;
	}

	update({bool simulateTick: false}) {
		super.update();

		if (currentState.stateName.contains("fly")) {
			moveXY(yAction: () {}, ledgeAction: () {});
		}

		// If respawn is in the past, it is time to choose a new animation
		if(respawn != null && new DateTime.now().compareTo(respawn) > 0) {
			setState(sheetName("fly"));
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
