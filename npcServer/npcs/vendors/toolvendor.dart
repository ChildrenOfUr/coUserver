part of coUserver;

class ToolVendor extends NPC {
  int openCount = 0;
  ToolVendor(String id, int x, int y) : super(id, x, y) {
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

    type = "Tool Vendor";
    speed = 75;

    states = {
      "attract": new Spritesheet("attract",
        "http://c2.glitch.bz/items/2012-12-06/npc_tool_vendor__x1_attract_png_1354831448.png",
        925, 2500, 185, 250, 50, false),
      "idle_stand": new Spritesheet("idle_stand",
        "http://c2.glitch.bz/items/2012-12-06/npc_tool_vendor__x1_idle_stand_png_1354831438.png",
        4070, 3750, 185, 250, 329, true),
      "talk": new Spritesheet("talk",
        "http://c2.glitch.bz/items/2012-12-06/npc_tool_vendor__x1_talk_png_1354831442.png",
        925, 1500, 185, 250, 26, false),
      "turn_left": new Spritesheet("turn_left",
        "http://c2.glitch.bz/items/2012-12-06/npc_tool_vendor__x1_turn_left_png_1354831414.png",
        925, 500, 185, 250, 10, false),
      "turn_right": new Spritesheet("turn_right",
        "http://c2.glitch.bz/items/2012-12-06/npc_tool_vendor__x1_turn_right_png_1354831419.png",
        740, 750, 185, 250, 11, false),
      "walk_left": new Spritesheet("walk_left",
        "http://c2.glitch.bz/items/2012-12-06/npc_tool_vendor__x1_walk_left_png_1354831417.png",
        925, 1250, 185, 250, 25, true),
      "walk": new Spritesheet("walk",
        "http://c2.glitch.bz/items/2012-12-06/npc_tool_vendor__x1_walk_png_1354831412.png",
        925, 1250, 185, 250, 24, true)
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
          currentState = states['attract'];
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
    saleItems.add(items['Butterfly Lotion'].getMap());
    saleItems.add(items['Hatchet'].getMap());
    saleItems.add(items['Hoe'].getMap());
    saleItems.add(items['High Class Hoe'].getMap());
    saleItems.add(items['Watering Can'].getMap());
    saleItems.add(items['Pick'].getMap());
    saleItems.add(items['Fancy Pick'].getMap());
    saleItems.add(items['Shovel'].getMap());
    saleItems.add(items['Ace of Spades'].getMap());
    return saleItems;
  }
}