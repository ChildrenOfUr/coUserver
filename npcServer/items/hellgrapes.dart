part of coUserver;

class HellGrapes extends Plant {
  HellGrapes(String id, int x, int y) : super(id, x, y) {
    actionTime = 3000;
    type = "Hellish Grapes";

    actions.add({
      "action": "squish",
      "actionWord": "squishing",
      "description": "You have to work to get out.",
      "timeRequired": 0,
      "enabled": true,
      "requires": []
    });

    states = {
      "grapes": new Spritesheet("1-2-3-4", "http://c2.glitch.bz/items/2012-12-06/bunch_of_grapes__x1_1_x1_2_x1_3_x1_4_png_1354829730.png", 228, 30, 57, 30, 1, true)
    };
    currentState = states["grapes"];
    state = 0;
    maxState = 0;
  }

  @override
  void update() {
    if (state == 0) {
      setActionEnabled("squish", true);
    }

    if (respawn != null && new DateTime.now().compareTo(respawn) >= 0) {
      state = 0;
      setActionEnabled("squish", true);
      respawn = null;
    }

    if (state < maxState){
      state = maxState;
    }
  }

  Future<bool> squish({WebSocket userSocket, String email}) async {
    // Update global stat
    StatBuffer.incrementStat("grapesSquished", 1);
    // Hide
    state = 5;
    // Show after 2 minutes
    respawn = new DateTime.now().add(new Duration(minutes: 2));

    // Send the player home
    Map<String, String> map = {
      "gotoStreet": "true",
      "tsid": "", // TODO: set to undeadTSID of useridentifier
      "dead": "false"
    };

    userSocket.add(JSON.encode(map));
    //TODO: userIdentifier.dead = true;

    return true;
  }
}
