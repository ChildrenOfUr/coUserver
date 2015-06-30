part of coUserver;

class Butterfly extends NPC {
  bool massaged = false;
  int numMilks = 0;
  Butterfly(String id, int x, int y) : super(id, x, y) {
    type = "Butterfly";
    actions..add({
      "action": "massage",
      "timeRequired": actionTime,
      "enabled": true,
      "actionWord": "massaging"
    });
    actions..add({
      "action": "milk",
      "timeRequired": actionTime,
      "enabled": true,
      "actionWord": "milking"
    });
    speed = 75; //pixels per second
    states = {
      "fly-angle1": new Spritesheet("fly-angle1",
        "http://c2.glitch.bz/items/2012-12-06/npc_butterfly__x1_fly-angle1_png_1354829526.png",
        840, 195, 70, 65, 34, true),
      "fly-angle2": new Spritesheet("fly-angle2",
        "http://c2.glitch.bz/items/2012-12-06/npc_butterfly__x1_fly-angle2_png_1354829527.png",
        700, 130, 70, 65, 20, true),
      "fly-rooked": new Spritesheet("fly-rooked",
        "http://c2.glitch.bz/items/2012-12-06/npc_butterfly__x1_fly-rooked_png_1354829525.png",
        980, 65, 70, 65, 14, true),
      "fly-side": new Spritesheet("fly-side",
        "http://c2.glitch.bz/items/2012-12-06/npc_butterfly__x1_fly-side_png_1354829525.png",
        980, 390, 70, 65, 84, true),
      "fly-top": new Spritesheet("fly-top",
        "http://c2.glitch.bz/items/2012-12-06/npc_butterfly__x1_fly-top_png_1354829528.png",
        910, 455, 70, 65, 87, true),
      "rest-angle1": new Spritesheet("rest-angle1",
        "http://c2.glitch.bz/items/2012-12-06/npc_butterfly__x1_rest-angle1_png_1354829530.png",
        420, 65, 70, 65, 6, true),
      "rest-angle2": new Spritesheet("rest-angle2",
        "http://c2.glitch.bz/items/2012-12-06/npc_butterfly__x1_rest-angle2_png_1354829531.png",
        700, 65, 70, 65, 10, true),
      "rest-top": new Spritesheet("rest-top",
        "http://c2.glitch.bz/items/2012-12-06/npc_butterfly__x1_rest-top_png_1354829532.png",
        980, 195, 70, 65, 42, true)
    };
    currentState = states["fly-side"];
    responses = {
      "massage": [],
      "milk": [],
      "milkFail": []
    };
  }

  Future<bool> massage({WebSocket userSocket, String email}) async {
    bool success = await super.trySetMetabolics(email,energy:-5,mood:3,imgMin:5,imgRange:3);
    if(!success) {
      return false;
    }

    StatBuffer.incrementStat("butterfliesMassaged", 1);
    //say(responses['massage'].elementAt(rand.nextInt(responses['massage'].length)));
    massaged = true;
    numMilks = 0;
    return true;
  }

  Future<bool> milk({WebSocket userSocket, String email}) async {
    bool success = await super.trySetMetabolics(email,energy:-5,mood:4,imgMin:5,imgRange:3);
    if(!success) {
      return false;
    }
    if (massaged && numMilks <= 2) {
      addItemToUser(userSocket, email, items['Butterfly Milk'].getMap(), 1, id);
      StatBuffer.incrementStat("butterfliesMilked", 1);
      numMilks++;
      //say(responses['milk'].elementAt(rand.nextInt(responses['milk'].length)));
    } else {
    //say(responses['milkFail'].elementAt(rand.nextInt(responses['milkFail'].length)));
    }
    return true;
  }

  update()
  {
    if(currentState.stateName == "fly-side") //we need to update x to hopefully stay in sync with clients
    {
      if(facingRight) {
        x += speed;
        //75 pixels/sec is the speed set on the client atm
      } else {
        x -= speed;
      }

      Random random = new Random();

      y += random.nextInt(10) - 5;

      if(x < 0) {
        x = 0;
      }
      if(x > 4000) {
        //TODO temporary
        x = 4000;
      }

      //hard to check right bounds without actually loading the street
      //which we aren't doing right now.  we're just making everything up in the constructor
      //but at some point, TODO we should get real street info
      //if(x > street.width-width)
      //x = street.width-width;
    }

    //if respawn is in the past, it is time to choose a new animation
    if(respawn != null && new DateTime.now().compareTo(respawn) > 0) {
      //1 in 4 chance to change direction
      if(rand.nextInt(4) == 1) {
        facingRight = !facingRight;
      }

      int num = rand.nextInt(10);
      if (num == 6 || num == 7) {
        currentState = states['fly-angle1'];
      } else if (num == 8 || num == 9) {
        currentState = states['fly-angle2'];
      } else {
        currentState = states['fly-side'];
      }

      //choose a new animation after this one finishes
      //we can calculate how long it should last by dividing the number
      //of frames by 30
      int length = (currentState.numFrames/30*1000).toInt();
      respawn = new DateTime.now().add(new Duration(milliseconds:length));
    }
  }
}