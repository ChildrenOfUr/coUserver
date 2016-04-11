part of entity;

class UncleFriendly extends Vendor {
	int openCount = 0;
	UncleFriendly(String id, String streetName, String tsid, int x, int y) : super(id, streetName, tsid, x, y) {
		type = "Uncle Friendly";
		itemsForSale = [
			items["honey"].getMap(),
			items["mushroom"].getMap(),
			items["mustard"].getMap(),
			items["oats"].getMap(),
			items["oily_dressing"].getMap(),
			items["olive_oil"].getMap(),
			items["sesame_oil"].getMap(),
			items["birch_syrup"].getMap(),
			items["coffee"].getMap(),
			items["beer"].getMap(),
			items["broccoli"].getMap(),
			items["cabbage"].getMap(),
			items["carrot"].getMap(),
			items["corn"].getMap(),
			items["cucumber"].getMap(),
			items["onion"].getMap(),
			items["potato"].getMap(),
			items["rice"].getMap(),
			items["spinach"].getMap(),
			items["tomato"].getMap(),
			items["zucchini"].getMap(),
			items["knife_and_board"].getMap(),
			items["frying_pan"].getMap(),
			items["blender"].getMap(),
			items["parsnip"].getMap()
		];
		speed = 40;

		states = {
			"idle_stand": new Spritesheet("idle_stand", "http://childrenofur.com/assets/entityImages/npc_jabba1__x1_idle_stand_part1_png_1354831118.png", 3951, 4020, 439, 201, 180, true),
			"idle_stand_2": new Spritesheet("idle_stand_2", "http://childrenofur.com/assets/entityImages/npc_jabba1__x1_idle_stand_part2_png_1354831135.png", 3951, 1809, 439, 201, 74, true),
			"impatient": new Spritesheet("impatient", "http://childrenofur.com/assets/entityImages/npc_jabba1__x1_impatient_png_1354831125.png", 3951, 2010, 439, 201, 86, false),
			"talk": new Spritesheet("talk", "http://childrenofur.com/assets/entityImages/npc_jabba1__x1_talk_png_1354831102.png", 3951, 1206, 439, 201, 53, true),
			"talk_end": new Spritesheet("talk_end","http://childrenofur.com/assets/entityImages/npc_jabba1__x1_talk_end_png_1354831104.png",878,1407,439,201,14,false),
			"turn": new Spritesheet("turn", "http://childrenofur.com/assets/entityImages/npc_jabba1__x1_turn_png_1354831127.png", 878, 804, 439, 201, 7, false),
			"walk_end": new Spritesheet("walk_end", "http://childrenofur.com/assets/entityImages/npc_jabba1__x1_walk_end_png_1354831098.png", 878, 1005, 439, 201, 10, false),
			"walk": new Spritesheet("walk", "http://childrenofur.com/assets/entityImages/npc_jabba1__x1_walk_png_1354831096.png", 878, 1407, 439, 201, 14, true),
			"walk_reverse": new Spritesheet("walk_reverse","http://childrenofur.com/assets/entityImages/npc_jabba1__x1_walk_reverse_png_1354831129.png",878,1608,439,201,15,true)
		};
		setState('idle_stand');
	}

	void update() {
		super.update();

		//update x and y
		if(currentState.stateName == "walk") {
			moveXY(wallAction: (Wall wall) {
				facingRight = !facingRight;
				setState('turn');
			});
		}

		if(respawn != null && respawn.compareTo(new DateTime.now()) <= 0) {
			// if we just turned, we should say we're facing the other way, then we should start moving (that's why we turned around after all)
			if(currentState.stateName == 'turn') {
				setState('walk', repeat: 3);
				return;
			} else {
				// if we haven't just turned
				if(rand.nextInt(2) == 1) {
					// 50% chance of walking around
					setState('walk', repeat: 8);
				} else if(rand.nextInt(2) == 1) {
					// attract customers?
					setState('impatient');
				} else {
					setState('idle_stand');
				}
				return;
			}
		}
	}

	void close({WebSocket userSocket, String email}) {
		openCount -= 1;
		//if no one else has them open
		if(openCount <= 0) {
			openCount = 0;
			setState('idle_stand');
		}
	}
}