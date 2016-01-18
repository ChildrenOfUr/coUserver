part of coUserver;

class Salmon extends NPC {
  int ySpeed;

  Salmon(String id, int x, int y) : super(id, x, y) {
    actions.add({
      "action": "pocket",
      "enabled": true,
      "timeRequired": 0,
      "actionWord": "pocketing",
      "description": "Put in pocket",
      "requires": [{'num': 4, 'of': ['energy']}]
    });
    type = "Salmon";
    speed = 35;
    ySpeed = 0;
    states = {
      "swimDown15": new Spritesheet("swimRightDown15", "http://childrenofur.com/assets/entityImages/npc_salmon__x1_swimRightDown15_png_1354840510.png", 649, 74, 59, 37, 22, true),
      "swimDown30": new Spritesheet("swimRightDown30", "http://childrenofur.com/assets/entityImages/npc_salmon__x1_swimRightDown30_png_1354840511.png", 649, 74, 59, 37, 22, true),
      "swimUp15": new Spritesheet("swimRightUp15", "http://childrenofur.com/assets/entityImages/npc_salmon__x1_swimRightUp15_png_1354840509.png", 649, 74, 59, 37, 22, true),
      "swimUp30": new Spritesheet("swimRightUp30", "http://childrenofur.com/assets/entityImages/npc_salmon__x1_swimRightUp30_png_1354840509.png", 649, 74, 59, 37, 22, true),
      "swim": new Spritesheet("swimRight", "http://childrenofur.com/assets/entityImages/npc_salmon__x1_swimRight_png_1354840508.png", 649, 74, 59, 37, 22, true),
      "turn": new Spritesheet("turnRight", "http://childrenofur.com/assets/entityImages/npc_salmon__x1_turnRight_png_1354840511.png", 649, 37, 59, 37, 11, false),
      "gone": new Spritesheet("gone", "http://childrenofur.com/assets/entityImages/blank.png", 1, 1, 1, 1, 1, false)
    };
    currentState = states["swim"];
  }

  void update() {
    x += speed;
    y += ySpeed;

    if(respawn != null && respawn.compareTo(new DateTime.now()) <= 0) {
      // if we just turned, we should say we're facing the other way, then we should start moving (that's why we turned around after all)
      if(facingRight && currentState.stateName == 'turn') {
        // if we turned left, we are no longer facing right
        facingRight = false;
        // reverse direction
        speed = -speed;
        // start swimming left
        currentState = states['swim'];
        // respawn when we finish walking
        respawn = new DateTime.now().add(new Duration(milliseconds:(currentState.numFrames / 30 * 1000).toInt()));
        return;
      } else if(!facingRight && currentState.stateName == 'turn') {
        // if we turned right, we are now facing right
        facingRight = true;
        // reverse direction
        speed = -speed;
        // start swimming right
        currentState = states['swim'];
        // respawn when we finish walking
        respawn = new DateTime.now().add(new Duration(milliseconds:(currentState.numFrames / 30 * 1000).toInt()));
        return;
      }
    }

    if(respawn == null) {
      //sometimes move around
      int roll = rand.nextInt(10);
      switch (roll) {

        case 0:
        case 1:
          // turn around
          currentState = states['turn'];
          respawn = new DateTime.now().add(new Duration(milliseconds:((currentState.numFrames / 30 * 1000)).toInt()));
          ySpeed = 0;
          break;

        case 2:
          // swim up (steeply)
          currentState = states['swimUp30'];
          respawn = new DateTime.now().add(new Duration(milliseconds:((currentState.numFrames / 30 * 1000) * 1500).toInt()));
          ySpeed = 30;
          break;

        case 3:
          // swim up (unholy)
          currentState = states['swimUp15'];
          respawn = new DateTime.now().add(new Duration(milliseconds:((currentState.numFrames / 30 * 1000) * 3000).toInt()));
          ySpeed = 15;
          break;

        case 4:
          // swim down (steeply)
          currentState = states['swimDown30'];
          respawn = new DateTime.now().add(new Duration(milliseconds:((currentState.numFrames / 30 * 1000) * 1500).toInt()));
          ySpeed = -30;
          break;

        case 5:
          // swim down (unholy)
          currentState = states['swimDown15'];
          respawn = new DateTime.now().add(new Duration(milliseconds:((currentState.numFrames / 30 * 1000) * 3000).toInt()));
          ySpeed = -15;
          break;

      }
    }
  }

  Future<bool> pocket({WebSocket userSocket, String email}) async {
    if (currentState == states['gone']) return false;
    bool success = await super.trySetMetabolics(email, energy:-4, imgMin:1, imgRange:5);
    if(!success) return false;

    // 50% chance to get a pocket salmon
    // 50% chance to let it slip out of your hands, you only catch a bubble
    if(new Random().nextInt(1) == 1) {
      await InventoryV2.addItemToUser(email, items['pocket_salmon'].getMap(), 1, id);
      StatBuffer.incrementStat("salmonPocketed", 1);
      currentState = states["gone"];
      respawn = new DateTime.now().add(new Duration(minutes:2));
      return true;
    } else {
      await InventoryV2.addItemToUser(email, items['salmon_bubble'].getMap(), 1, id);
      say("You missed me, but you managed to grab a bubble.");
      return false;
    }
  }
}