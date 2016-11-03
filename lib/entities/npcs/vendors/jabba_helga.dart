part of entity;

class Helga extends Vendor {
	int openCount = 0;

	Helga(String id, String streetName, String tsid, num x, num y, num z, num rotation, bool h_flip) : super(id, streetName, tsid, x, y, z, rotation, h_flip) {
		type = "Helga";
		itemsPredefined = true;
		itemsForSale = [
			items["still"].getMap(),
			items["beer"].getMap(),
			items["carrot_margarita"].getMap(),
			items["coffee"].getMap(),
			items["creamy_martini"].getMap(),
			items["exotic_juice"].getMap(),
			items["mabbish_coffee"].getMap(),
			items["mega_healthy_veggie_juice"].getMap(),
			items["savory_smoothie"].getMap(),
			items["slow_gin_fizz"].getMap(),
			items["spicy_grog"].getMap(),
			items["tooberry_shake"].getMap()
		];
		speed = 40;

		states = {
			"idle_stand": new Spritesheet(
				"idle_stand",
				"http://childrenofur.com/assets/entityImages/npc_jabba2__x1_idle_stand_part1_png_1354831705.png",
				3942,
				4074,
				438,
				194,
				189,
				true),
			"idle_stand_2": new Spritesheet(
				"idle_stand",
				"http://childrenofur.com/assets/entityImages/npc_jabba2__x1_idle_stand_part2_png_1354831715.png",
				3942,
				2910,
				438,
				194,
				131,
				true),
			"impatient": new Spritesheet(
				"impatient",
				"http://childrenofur.com/assets/entityImages/npc_jabba2__x1_impatient_png_1354831691.png",
				3942,
				2134,
				438,
				194,
				98,
				true),
			"talk": new Spritesheet(
				"talk",
				"http://childrenofur.com/assets/entityImages/npc_jabba2__x1_talk_png_1354831682.png",
				3942,
				1552,
				438,
				194,
				72,
				true),
			"turn_left": new Spritesheet(
				"turn",
				"http://childrenofur.com/assets/entityImages/npc_jabba2__x1_turn_png_1354831675.png",
				876,
				1746,
				438,
				194,
				18,
				false),
			"turn_right": new Spritesheet(
				"turn_right",
				"http://childrenofur.com/assets/entityImages/npc_jabba2__x1_turn_right_png_1354831667.png",
				876,
				1552,
				438,
				194,
				16,
				false),
			"walk_end": new Spritesheet(
				"walk_end",
				"http://childrenofur.com/assets/entityImages/npc_jabba2__x1_walk_end_png_1354831672.png",
				876,
				1552,
				438,
				194,
				15,
				false),
			"walk_left_end": new Spritesheet(
				"walk_left_end",
				"http://childrenofur.com/assets/entityImages/npc_jabba2__x1_walk_left_end_png_1354831665.png",
				876,
				1552,
				438,
				194,
				15,
				false),
			"walk_left": new Spritesheet(
				"walk_left",
				"http://childrenofur.com/assets/entityImages/npc_jabba2__x1_walk_left_png_1354831662.png",
				876,
				1552,
				438,
				194,
				16,
				true),
			"walk": new Spritesheet(
				"walk",
				"http://childrenofur.com/assets/entityImages/npc_jabba2__x1_walk_png_1354831670.png",
				876,
				1552,
				438,
				194,
				16,
				true),
		};
		setState('idle_stand');
	}

	void update({bool simulateTick: false}) {
		super.update();

		//update x and y
		if (currentState.stateName == "walk") {
			moveXY(wallAction: (Wall wall) {
				if(facingRight) {
					setState('turn_left');
				} else {
					setState('turn_right');
				}
				facingRight = !facingRight;
			});
		}

		if (respawn.compareTo(new DateTime.now()) <= 0) {
			// if we just turned, we should say we're facing the other way, then we should start moving (that's why we turned around after all)
			if (currentState.stateName == 'turn_left') {
				// if we turned left, we are no longer facing right
				facingRight = false;
				// start walking left
				setState('walk', repeat: 3);
			} else if (currentState.stateName == 'turn_right') {
				// if we turned right, we are now facing right
				facingRight = true;
				// start walking right
				setState('walk');
			} else {
				// if we haven't just turned
				//1 in 10 that we turn around and start walking
				if(rand.nextInt(10) == 8) {
					if(facingRight) {
						setState('turn_left');
					} else {
						setState('turn_right');
					}
				} else if(rand.nextInt(2) == 1) {
					setState('walk', repeat: 5);
				} else {
					if (rand.nextInt(4) > 2) {
						// 50% chance of trying to attract buyers
						setState('impatient');
					} else if (rand.nextInt(2) == 1){
						// wait
						setState('idle_stand');
					}
				}
			}
		}
	}

	void close({WebSocket userSocket, String email}) {
		openCount -= 1;
		//if no one else has them open
		if (openCount <= 0) {
			openCount = 0;
			setState('idle_stand');
		}
	}
}