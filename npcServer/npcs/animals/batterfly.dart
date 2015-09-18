part of coUserver;

class Batterfly extends NPC {

  Random bfRand = new Random();

  Batterfly(String id, int x, int y) : super(id, x, y) {
    type = "Batterfly";
    speed = 75; //pixels per second
    actions = [];
    states = {
      "chew": new Spritesheet("chew", "http://childrenofur.com/assets/entityImages/npc_batterfly__x1_chew_png_1354831854.png", 999, 1344, 111, 96, 120, false),
      "front_turned": new Spritesheet("front_turned", "http://childrenofur.com/assets/entityImages/npc_batterfly__x1_front_turned_png_1354831847.png", 888, 480, 111, 96, 40, true),
      "front_waiting": new Spritesheet("front_waiting", "http://childrenofur.com/assets/entityImages/npc_batterfly__x1_front_waiting_png_1354831849.png", 888, 480, 111, 96, 40, true),
      "fly_profile": new Spritesheet("fly_profile", "http://childrenofur.com/assets/entityImages/npc_batterfly__x1_profile_png_1354831844.png", 888, 480, 111, 96, 40, true),
      "fly_profile_turned": new Spritesheet("fly_profile_turned", "http://childrenofur.com/assets/entityImages/npc_batterfly__x1_profile_turned_png_1354831846.png", 888, 480, 111, 96, 40, true)
    };
    currentState = states["fly_profile"];
    facingRight = true;
  }

  update() {
    if (currentState.stateName == "fly_profile") {
      if (facingRight) {
        x += speed;
      } else {
        x -= speed;
      }

      y += rand.nextInt(50) - 25;

      if (x < 0) {
        x = 0;
      }
      if (x > 4000) {
        x = 4000;
      }

      int roll = bfRand.nextInt(10);
      if (roll == 9) {
        // 10% chance to face us
        currentState = states["fly_profile_turned"];
        int length = (2 * currentState.numFrames / 30 * 1000).toInt();
        respawn = new DateTime.now().add(new Duration(milliseconds:length));
      } else if (roll < 3) {
        // 30% to turn around
        facingRight = !facingRight;
      }
    }
  }
}