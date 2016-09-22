part of entity;

class ToolVendor extends Vendor {
	int openCount = 0;

	ToolVendor(String id, String streetName, String tsid, num x, num y, num z) : super(id, streetName, tsid, x, y, z) {
		type = 'Tool Vendor';
		itemsForSale = [
			items["pig_bait"].getMap(),
			items["butterfly_lotion"].getMap(),
			items["meat_collector"].getMap(),
			items["piggy_feeder"].getMap(),
			items["butterfly_milker"].getMap(),
			items["egg_seasoner"].getMap(),
			items["bean_seasoner"].getMap(),
			items["hatchet"].getMap(),
			items["hoe"].getMap(),
			items["watering_can"].getMap(),
			items["bubble_tuner"].getMap(),
			items["gassifier"].getMap(),
			items["fruit_changing_machine"].getMap(),
			items["spice_mill"].getMap(),
			items["alchemistry_kit"].getMap(),
			items["elemental_pouch"].getMap(),
			items["test_tube"].getMap(),
			items["beaker"].getMap(),
			items["pick"].getMap(),
			items["fancy_pick"].getMap(),
			items["grinder"].getMap(),
			items["tinkertool"].getMap(),
			items["focusing_orb"].getMap(),
			items["alchemical_tongs"].getMap(),
			items["smelter"].getMap(),
			items["shovel"].getMap(),
			items["scraper"].getMap(),
			items["quill"].getMap(),
			items["machine_stand"].getMap(),
			items["blockmaker_chassis"].getMap(),
			items["machine_engine"].getMap(),
			items["blockmaker_plates"].getMap(),
			items["fuelmaker_case"].getMap(),
			items["fuelmaker_core"].getMap(),
			items["cauldron"].getMap(),
			items["tincturing_kit"].getMap(),
			items["still"].getMap(),
			items["metalmaker_mechanism"].getMap(),
			items["metalmaker_tooler"].getMap(),
			items["woodworker_fuser"].getMap(),
			items["woodworker_chassis"].getMap(),
			items["spindle"].getMap(),
			items["loomer"].getMap(),
			items["construction_tool"].getMap(),
			items["bulb"].getMap(),
		];
		itemsForSale.addAll(pickItems(["Storage"]));
		itemsPredefined = true;
		speed = 75;
		states = {
			"attract": new Spritesheet("attract",
			                           "http://childrenofur.com/assets/entityImages/npc_tool_vendor__x1_attract_png_1354831448.png",
			                           925, 2500, 185, 250, 50, false),
			"idle_stand": new Spritesheet("idle_stand",
			                              "http://childrenofur.com/assets/entityImages/npc_tool_vendor__x1_idle_stand_png_1354831438.png",
			                              4070, 3750, 185, 250, 329, true),
			"talk": new Spritesheet("talk",
			                        "http://childrenofur.com/assets/entityImages/npc_tool_vendor__x1_talk_png_1354831442.png",
			                        925, 1500, 185, 250, 26, false),
			"turn_left": new Spritesheet("turn_left",
			                             "http://childrenofur.com/assets/entityImages/npc_tool_vendor__x1_turn_left_png_1354831414.png",
			                             925, 500, 185, 250, 10, false),
			"turn_right": new Spritesheet("turn_right",
			                              "http://childrenofur.com/assets/entityImages/npc_tool_vendor__x1_turn_right_png_1354831419.png",
			                              740, 750, 185, 250, 11, false),
			"walk_left": new Spritesheet("walk_left",
			                             "http://childrenofur.com/assets/entityImages/npc_tool_vendor__x1_walk_left_png_1354831417.png",
			                             925, 1250, 185, 250, 25, true),
			"walk": new Spritesheet("walk",
			                        "http://childrenofur.com/assets/entityImages/npc_tool_vendor__x1_walk_png_1354831412.png",
			                        925, 1250, 185, 250, 24, true)
		};
		setState('idle_stand');
	}

	void update({bool simulateTick: false}) {
		super.update();

		//update x and y
		if (currentState.stateName == "walk") {
			moveXY();
		}

		if(respawn != null && respawn.compareTo(new DateTime.now()) <= 0) {
			// if we just turned, we should say we're facing the other way, then we should start moving (that's why we turned around after all)
			if(currentState.stateName == 'turn_left') {
				// if we turned left, we are no longer facing right
				facingRight = false;
				// start walking left
				setState('walk');
			} else if(currentState.stateName == 'turn_right') {
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
						setState('attract');
					} else if (rand.nextInt(2) == 1){
						// wait
						setState('idle_stand');
					}
				}
			}
		}
	}

	void buy({WebSocket userSocket, String email}) {
		setState('idle_stand');
		//don't go to another state until closed
		respawn = new DateTime.now().add(new Duration(days:50));
		openCount++;

		super.buy(userSocket:userSocket, email:email);
	}

	void sell({WebSocket userSocket, String email}) {
		setState('talk');
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
			setState('idle_stand');
		}
	}
}