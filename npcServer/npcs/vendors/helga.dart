part of coUserver;

class Helga extends NPC {
  int openCount = 0;
  Helga(String id, int x, int y) : super(id, x, y) {
    actionTime = 0;
    actions
      ..add({"action":"buy",
      "timeRequired":actionTime,
      "enabled":true,
      "actionWord":""})
      ..add({"action":"sell",
      "timeRequired":actionTime,
      "enabled":true,
      "actionWord":""});

    type = "Helga";
    speed = 40;

    states = {
      "idle_stand_1": new Spritesheet("idle_stand",
        "http://c2.glitch.bz/items/2012-12-06/npc_jabba2__x1_idle_stand_part1_png_1354831705.png",
        3942, 4074, 438, 194, 189, true),
      "idle_stand_2": new Spritesheet("idle_stand",
        "http://c2.glitch.bz/items/2012-12-06/npc_jabba2__x1_idle_stand_part2_png_1354831715.png",
        3942, 2910, 438, 194, 131, true),
      "impatient": new Spritesheet("impatient",
        "http://c2.glitch.bz/items/2012-12-06/npc_jabba2__x1_impatient_png_1354831691.png",
        3942, 2134, 438, 194, 98, true),
      "talk": new Spritesheet("talk",
        "http://c2.glitch.bz/items/2012-12-06/npc_jabba2__x1_talk_png_1354831682.png",
        3942, 1552, 438, 194, 72, true),
      "turn": new Spritesheet("turn",
        "http://c2.glitch.bz/items/2012-12-06/npc_jabba2__x1_turn_png_1354831675.png",
        876, 1746, 438, 194, 18, false),
      "turn_right": new Spritesheet("turn_right",
        "http://c2.glitch.bz/items/2012-12-06/npc_jabba2__x1_turn_right_png_1354831667.png",
        876, 1552, 438, 194, 16, false),
      "walk_end": new Spritesheet("walk_end",
        "http://c2.glitch.bz/items/2012-12-06/npc_jabba2__x1_walk_end_png_1354831672.png",
        876, 1552, 438, 194, 15, false),
      "walk_left_end": new Spritesheet("walk_left_end",
        "http://c2.glitch.bz/items/2012-12-06/npc_jabba2__x1_walk_left_end_png_1354831665.png",
        876, 1552, 438, 194, 15, false),
      "walk_left": new Spritesheet("walk_left",
        "http://c2.glitch.bz/items/2012-12-06/npc_jabba2__x1_walk_left_png_1354831662.png",
        876, 1552, 438, 194, 16, true),
      "walk": new Spritesheet("walk",
        "http://c2.glitch.bz/items/2012-12-06/npc_jabba2__x1_walk_png_1354831670.png",
        876, 1552, 438, 194, 16, true),
    };
    currentState = states['idle_stand'];
  }

  void update() {
    if(respawn != null && respawn.compareTo(new DateTime.now()) <= 0) {
      // if we just turned, we should say we're facing the other way, then we should start moving (that's why we turned around after all)
      if(currentState.stateName == 'turn_left') {
        // if we turned left, we are no longer facing right
        facingRight = false;
        // reverse direction
        speed = -speed;
        // start walking left
        currentState = states['walk'];
        // respawn when we finish walking
        respawn = new DateTime.now().add(new Duration(milliseconds:(currentState.numFrames / 30 * 1000).toInt()));
        return;
      } else if (currentState.stateName == 'turn_right') {
        // if we turned right, we are now facing right
        facingRight = true;
        // reverse direction
        speed = -speed;
        // start walking right
        currentState = states['walk'];
        // respawn when we finish walking
        respawn = new DateTime.now().add(new Duration(milliseconds:(currentState.numFrames / 30 * 1000).toInt()));
        return;
      } else {
        // if we haven't just turned
        if(rand.nextInt(2) == 1) {
          // 50% chance of trying to attract buyers
          currentState = states['impatient'];
          // respawn when done
          respawn = new DateTime.now().add(new Duration(milliseconds:(currentState.numFrames / 30 * 1000).toInt()));
        } else {
          // wait
          currentState = states['idle_stand'];
          respawn = null;
        }
        return;
      }
    }
    if(respawn == null) {
      //sometimes move around
      int roll = rand.nextInt(20);
      if(roll > 10 && roll <= 15) {
        // 25% chance to turn left
        currentState = states['turn_left'];
        // no longer facing right
        facingRight = false;
        // respawn after walking left three times
        respawn = new DateTime.now().add(new Duration(milliseconds:(currentState.numFrames / 30 * 1000).toInt() * 3));
      } else if (roll > 15 && roll <= 20) {
        // 25% chance to turn right
        currentState = states['turn_right'];
        // now facing right
        facingRight = true;
        // respawn after walking right three times
        respawn = new DateTime.now().add(new Duration(milliseconds:(currentState.numFrames / 30 * 1000).toInt() * 3));
      } else {
        // 50% chance of nothing happening
      }
    }
  }

  void buy({WebSocket userSocket, String email}) {
    currentState = states['idle_stand'];
    //don't go to another state until closed
    respawn = new DateTime.now().add(new Duration(days:50));
    openCount++;

    Map map = {};
    map['vendorName'] = type;
    map['id'] = id;
    map['itemsForSale'] = _getItemsForSale();
    userSocket.add(JSON.encode(map));
  }

  void sell({WebSocket userSocket, String email}) {
    currentState = states['talk'];
    //don't go to another state until closed
    respawn = new DateTime.now().add(new Duration(days:50));
    openCount++;

    //prepare the buy window at the same time
    Map map = {};
    map['vendorName'] = type;
    map['id'] = id;
    map['itemsForSale'] = _getItemsForSale();
    map['openWindow'] = 'vendorSell';
    userSocket.add(JSON.encode(map));
  }

  void close({WebSocket userSocket, String email}) {
    openCount -= 1;
    //if no one else has them open
    if(openCount <= 0) {
      openCount = 0;
      currentState = states['idle_stand'];
      int length = (currentState.numFrames / 30 * 1000).toInt();
      respawn = new DateTime.now().add(new Duration(milliseconds:length));
    }
  }

  buyItem({WebSocket userSocket, String itemName, int num, String email}) async {
    StatBuffer.incrementStat("itemsBoughtFromVendors", num);
    Item item = items[itemName];

    Metabolics m = await getMetabolics(email:email);
    if(m.currants >= item.price * num) {
      m.currants -= item.price * num;
      setMetabolics(m);
      addItemToUser(userSocket, email, item.getMap(), num, id);
    }
  }

  sellItem({WebSocket userSocket, String itemName, int num, String email}) async {
    bool success = await takeItemFromUser(userSocket, email, itemName, num);

    if(success) {
      Item item = items[itemName];

      Metabolics m = await getMetabolics(email:email);
      m.currants += (item.price * num * .7) ~/ 1;
      setMetabolics(m);
    }
  }

  List _getItemsForSale() {
    List<Map> saleItems = [];

    saleItems.add(items['Coffee'].getMap());

    return saleItems;
  }
}