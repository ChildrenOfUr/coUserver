part of coUserver;

class MealVendor extends Vendor {
  int openCount = 0;

  MealVendor(String id, String streetName, String tsid, int x, int y) : super(id, streetName, tsid, x, y) {
    type = 'Meal Vendor';
    itemsForSale = [
      items["earthshaker"].getMap(),
      items["face_smelter"].getMap(),
      items["flaming_humbaba"].getMap(),
      items["cheezy_sammich"].getMap(),
      items["potato_patty"].getMap(),
      items["basic_omelet"].getMap(),
      items["exotic_fruit_salad"].getMap(),
      items["scrumptious_frittata"].getMap(),
      items["pineapple_upside_down_pizza"].getMap(),
      items["super_veggie_kebabs"].getMap(),
      items["hash"].getMap(),
      items["divine_crepes"].getMap(),
      items["simple_bbq"].getMap(),
      items["obvious_panini"].getMap(),
      items["meat_gumbo"].getMap(),
      items["flummery"].getMap(),
      items["rich_tagine"].getMap(),
      items["chillybusting_chili"].getMap()
    ];
    itemsPredefined = true;
    speed = 40;
    states = {
      "attract": new Spritesheet("attract", "http://c2.glitch.bz/items/2012-12-06/npc_cooking_vendor__x1_attract_png_1354831634.png", 945, 2300, 189, 230, 50, false),
      "idle_stand": new Spritesheet("idle_stand", "http://c2.glitch.bz/items/2012-12-06/npc_cooking_vendor__x1_idle_stand_part1_png_1354831629.png", 3969, 3910, 189, 230, 357, true),
      "talk": new Spritesheet("talk", "http://c2.glitch.bz/items/2012-12-06/npc_cooking_vendor__x1_talk_png_1354831616.png", 945, 1840, 189, 230, 36, false),
      "walk_left": new Spritesheet("walk_left", "http://c2.glitch.bz/items/2012-12-06/npc_cooking_vendor__x1_walk_left_png_1354831611.png", 756, 920, 189, 230, 16, true),
      "walk": new Spritesheet("walk_right", "http://c2.glitch.bz/items/2012-12-06/npc_cooking_vendor__x1_walk_right_png_1354831603.png", 756, 920, 189, 230, 16, true)
    };
		facingRight = true;
    currentState = states['idle_stand'];
		respawn = new DateTime.now().add(new Duration(seconds: 5));
  }

  void update() {
		if (respawn != null && respawn.compareTo(new DateTime.now()) <= 0) {
				int roll = rand.nextInt(5);
				switch(roll) {
					case 0:
						// try to attract buyers
						currentState = states['attract'];
						respawn = new DateTime.now().add(new Duration(milliseconds: (currentState.numFrames / 30 * 1000).toInt()));
						break;

					case 1:
						// walk for 3 seconds
						if (x >= 3800) {
							speed = -40;
							facingRight = false;
							currentState = states['walk_left'];
							respawn = new DateTime.now().add(new Duration(seconds: 3));
						} else {
							speed = 40;
							facingRight = true;
							currentState = states['walk'];
							respawn = new DateTime.now().add(new Duration(seconds: 3));
						}
						x += speed;
						break;

					case 2:
					case 3:
					case 4:
						// do nothing
						currentState = states['idle_stand'];
						respawn = new DateTime.now().add(new Duration(seconds: 10));
						break;
				}
        return;
      }
  }

  void buy({WebSocket userSocket, String email}) {
    currentState = states['talk'];
    //don't go to another state until closed
    respawn = new DateTime.now().add(new Duration(days: 50));
    openCount++;

    super.buy(userSocket: userSocket, email: email);
  }

  void sell({WebSocket userSocket, String email}) {
    currentState = states['talk'];
    //don't go to another state until closed
    respawn = new DateTime.now().add(new Duration(days: 50));
    openCount++;

    super.sell(userSocket: userSocket, email: email);
  }

  void close({WebSocket userSocket, String email}) {
    openCount -= 1;
    //if no one else has them open
    if (openCount <= 0) {
      openCount = 0;
      currentState = states['idle_stand'];
      respawn = new DateTime.now().add(new Duration(seconds: 3));
    }
  }
}
