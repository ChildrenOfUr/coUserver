part of coUserver;

class SkillRequirements {
  @Field()
  Map<String, int> requiredSkillLevels = {};
}

class ItemRequirements {
  @Field()
  List<String> any = [];
  @Field()
  Map<String, int> all = {};
}

class Action {
  @Field()
  String name;
  @Field()
  String description = '';
  @Field()
  int timeRequired = 0;
  @Field()
  ItemRequirements itemRequirements = new ItemRequirements();
  @Field()
  SkillRequirements skillRequirements = new SkillRequirements();

  Action();

  Action.withName(this.name);

  @override
  String toString() {
    String returnString = "$name requires any of ${itemRequirements.any}, all of ${itemRequirements.all} and at least ";
    skillRequirements.requiredSkillLevels.forEach((String skill, int level) {
      returnString += "$level level of $skill, ";
    });
    returnString = returnString.substring(0, returnString.length - 1);

    return returnString;
  }
}

class Item {
  @Field()
  String category;
  @Field()
  String iconUrl;
  @Field()
  String spriteUrl;
  @Field()
  String toolAnimation;
  @Field()
  String name;
  @Field()
  String description;
  @Field()
  String item_id;
  @Field()
  String itemType;
  @Field()
  int price;
  @Field()
  int stacksTo;
  @Field()
  int iconNum = 4;
  @Field()
  int durability;
  @Field()
  num x;
  @Field()
  num y;
  @Field()
  bool onGround = false;
  @Field()
  bool isContainer = false;
  @Field()
  int subSlots;
  @Field()
  List<String> subSlotFilter;
  @Field()
  List<Action> actions = [];

  Action dropAction = new Action.withName('drop')
    ..description = "Drop this item on the ground.";
  Action pickupAction = new Action.withName('pickup')
    ..description = "Put this item in your bags.";

  Random rand = new Random();

  Item();

  Item.clone(this.itemType) {
    Item model = items[itemType];
    category = model.category;
    iconUrl = model.iconUrl;
    spriteUrl = model.spriteUrl;
    toolAnimation = model.toolAnimation;
    name = model.name;
    description = model.description;
    price = model.price;
    stacksTo = model.stacksTo;
    iconNum = model.iconNum;
    durability = model.durability;
    x = model.x;
    y = model.y;
    isContainer = model.isContainer;
    subSlots = model.subSlots;
    subSlotFilter = model.subSlotFilter;
    actions = model.actions;

    bool found = false;
    actions.forEach((Action action) {
      if (action.name == 'drop') {
        found = true;
      }
    });

    if (!found) {
      actions.insert(0, dropAction);
    }
  }

  Map getMap() {
    return {"iconUrl":iconUrl,
      "spriteUrl":spriteUrl,
      "name":name,
      "itemType":itemType,
      "category":category,
      "isContainer":isContainer,
      "description":description,
      "price":price,
      "stacksTo":stacksTo,
      "iconNum":iconNum,
      "id":item_id,
      "onGround":onGround,
      "x":x,
      "y":y,
      "actions":actionList,
      "tool_animation": toolAnimation,
      "durability": durability};
  }

  List<Map> get actionList {
    if (onGround) {
      return [encode(pickupAction)];
    } else {
      List<Map> result = encode(actions);
      bool found = false;
      actions.forEach((Action action) {
        if (action.name == 'drop') {
          found = true;
        }
      });
      if (!found) {
        result.insert(0, encode(dropAction));
      }
      return result;
    }
  }

  static Future<bool> trySetMetabolics(String identity, {int energy:0, int mood:0, int img:0, int currants:0}) async {
    Metabolics m = new Metabolics();
    if (identity.contains("@")) {
      m = await getMetabolics(email:identity);
    } else {
      m = await getMetabolics(username:identity);
    }
    m.energy += energy;
    m.mood += mood;
    m.img += img;
    m.lifetime_img += img;
    m.currants += currants;
    int result = await setMetabolics(m);
    if (result < 1) {
      return false;
    }
    return true;
  }

  // //////////////// //
  // Butterfly Lotion //
  // //////////////// //

  Future<bool> taste({String streetName, Map map, WebSocket userSocket, String email}) async {
    toast("That didn't taste as good as it smells. -5 mood", userSocket);
    return trySetMetabolics(email, mood:-5);
  }

  // /////// //
  // Cubimal //
  // /////// //

  Future<bool> setFree({String streetName, Map map, WebSocket userSocket, String email}) async {
    String cubiType = map['dropItem']['itemType'];
    bool success = await takeItemFromUser(userSocket, email, cubiType, 1);
    if (!success) return false;
    Map<String, double> cubis;
    cubis = {
      "chick": 17.000,
      "piggy": 34.000,
      "butterfly": 50.000,
      "crab": 58.000,
      "batterfly": 66.000,
      "frog": 74.000,
      "firefly": 82.000,
      "bureaucrat": 84.000,
      "cactus": 86.000,
      "snoconevendor": 88.000,
      "squid": 90.000,
      "juju": 92.000,
      "smuggler": 93.250,
      "deimaginator": 94.500,
      "greeterbot": 95.750,
      "dustbunny": 97.000,
      "gwendolyn": 97.500,
      "unclefriendly": 98.000,
      "helga": 98.500,
      "magicrock": 99.000,
      "yeti": 99.500,
      "rube": 99.750,
      "rook": 100.00,
      "fox": 14.500,
      "sloth": 29.000,
      "emobear": 37.000,
      "foxranger": 45.000,
      "groddlestreetspirit": 54.000,
      "uraliastreetspirit": 61.000,
      "firebogstreetspirit": 69.000,
      "gnome": 77.000,
      "butler": 81.000,
      "craftybot": 85.000,
      "phantom": 89.000,
      "ilmenskiejones": 93.000,
      "trisor": 94.000,
      "toolvendor": 95.000,
      "mealvendor": 96.000,
      "gardeningtoolsvendor": 97.000,
      "maintenancebot": 98.000,
      "senorfunpickle": 99.000,
      "hellbartender": 99.500,
      "scionofpurple": 100.50
    };
    int img = ((cubis[(map["dropItem"]["itemType"] as String).substring(8)] / 2) * (rand.nextDouble() + 0.1)).truncate();
    trySetMetabolics(email, mood: 10, img: img);
    StatBuffer.incrementStat("cubisSetFree", 1);
    toast("Your cubimal was released back into the wild. You got $img iMG.", userSocket);
    return success;
  }

  Future<bool> race({String streetName, Map map, WebSocket userSocket, String email}) async {
    // number 1 to 50
    int base = rand.nextInt(49) + 1;
    // number 0.0 (incl) to 1.0 (excl)
    double multiplier = rand.nextDouble();
    // multiply them for more variety
    num result = base * multiplier;
    // 80% chance to cut numbers at least 17 in half
    if (result >= 17 && rand.nextInt(4) <= 3) result /= 2;
    // cut to two decimal places (and a string)
    String twoPlaces = result.toStringAsFixed(2);
    // back to number format
    num distance = num.parse(twoPlaces);

    String plural;
    if (distance == 1) {
      plural = "";
    } else {
      plural = "s";
    }

    String message;
    String username = "A "; //TODO: get username from userSocket

    if (map["dropItem"]["itemType"] == 'npc_cubimal_factorydefect_chick') {
      distance = -(distance / 2);
      message = "$username defective chick cubimal travelled ${distance.toString()} plank$plural, and broke";
    } else {
      message = "$username ${map["dropItem"]["name"]} travelled ${distance.toString()} plank$plural before stopping";
    }

    StreetUpdateHandler.streets[streetName].occupants.forEach((WebSocket ws) => toast(message, ws));

    return true;
  }

  // /////////// //
  // Cubimal Box //
  // /////////// //

  Future<bool> takeOutCubimal({String streetName, Map map, WebSocket userSocket, String email}) async {
    int series;
    Map<String, String> cubis;
    if (map['dropItem']['itemType'] == 'cubimal_series_1_box') {
      series = 1;
      cubis = {
        "17.000": "chick",
        "34.000": "piggy",
        "50.000": "butterfly",
        "58.000": "crab",
        "66.000": "batterfly",
        "74.000": "frog",
        "82.000": "firefly",
        "84.000": "bureaucrat",
        "86.000": "cactus",
        "88.000": "snoconevendor",
        "90.000": "squid",
        "92.000": "juju",
        "93.250": "smuggler",
        "94.500": "deimaginator",
        "95.750": "greeterbot",
        "97.000": "dustbunny",
        "97.500": "gwendolyn",
        "98.000": "unclefriendly",
        "98.500": "helga",
        "99.000": "magicrock",
        "99.500": "yeti",
        "99.750": "rube",
        "100.00": "rook"
      };
    } else if (map['dropItem']['itemType'] == 'cubimal_series_2_box') {
      series = 2;
      cubis = {
        "14.500": "fox",
        "29.000": "sloth",
        "37.000": "emobear",
        "45.000": "foxranger",
        "54.000": "groddlestreetspirit",
        "61.000": "uraliastreetspirit",
        "69.000": "firebogstreetspirit",
        "77.000": "gnome",
        "81.000": "butler",
        "85.000": "craftybot",
        "89.000": "phantom",
        "93.000": "ilmenskiejones",
        "94.000": "trisor",
        "95.000": "toolvendor",
        "96.000": "mealvendor",
        "97.000": "gardeningtoolsvendor",
        "98.000": "maintenancebot",
        "99.000": "senorfunpickle",
        "99.500": "hellbartender",
        "100.50": "scionofpurple"
      };
    } else {
      return false;
    }
    String cubimal = "cubimal_";
    String box = "cubimal_series_" + series.toString() + "_box";
    num seek = rand.nextInt(10000) / 100;
    for (String cubiChance in cubis.keys) {
      if (seek <= num.parse(cubiChance)) {
        cubimal += cubis[cubiChance];
        break;
      }
    }
    bool success = await takeItemFromUser(userSocket, email, box, 1);
    await addItemToUser(userSocket, email, items[cubimal].getMap(), 1, box);
    StatBuffer.incrementStat("cubiBoxesOpened", 11);
    return success;
  }

  // ////// //
  // Emblem //
  // ////// //

  Future<bool> caress({String streetName, Map map, WebSocket userSocket, String email}) async {
    int amt = rand.nextInt(10) + 5;
    StatBuffer.incrementStat("emblemsCaressed", 1);
    toast("+$amt mood for caressing", userSocket);
    return await trySetMetabolics(email, mood:amt);
  }

  Future<bool> consider({String streetName, Map map, WebSocket userSocket, String email}) async {
    int amt = rand.nextInt(10) + 5;
    StatBuffer.incrementStat("emblemsConsidered", 1);
    toast("+$amt energy for considering", userSocket);
    return await trySetMetabolics(email, energy:amt);
  }

  Future<bool> contemplate({String streetName, Map map, WebSocket userSocket, String email}) async {
    int amt = rand.nextInt(10) + 5;
    StatBuffer.incrementStat("emblemsContemplated", 1);
    toast("+$amt iMG for contemplating", userSocket);
    return await trySetMetabolics(email, img:amt);
  }

  Future<bool> iconize({String streetName, Map map, WebSocket userSocket, String email}) async {
    String emblemType = itemType;
    String iconType = "icon_of_" + itemType.substring(10);
    bool success1 = await takeItemFromUser(userSocket, email, emblemType, 11);
    if (!success1) {
      return false;
    }
    int success2 = await addItemToUser(userSocket, email, items[iconType].getMap(), 1, item_id);
    if (success2 == 0) {
      return false;
    } else {
      StatBuffer.incrementStat("emblemsIconized", 11);
      StatBuffer.incrementStat("iconsCreated", 1);
      return true;
    }
  }

  // //////////// //
  // Focusing Orb //
  // //////////// //

  Future<bool> levitate({String streetName, Map map, WebSocket userSocket, String email}) async {
    toast("Levitating is not implemented yet. Sorry!", userSocket);
    return false;
  }

  Future<bool> focusEnergy({String streetName, Map map, WebSocket userSocket, String email}) async {
    toast("+10 energy focused", userSocket);
    return await trySetMetabolics(email, energy:10);
  }

  Future<bool> focusMood({String streetName, Map map, WebSocket userSocket, String email}) async {
    toast("+10 mood focused", userSocket);
    return await trySetMetabolics(email, mood:10);
  }

  Future<bool> radiate({String streetName, Map map, WebSocket userSocket, String email}) async {
    List<String> users = [];
    List<Identifier> ids = ChatHandler.users.values.where((Identifier id) => id.channelList.contains(streetName)).toList();
    ids.forEach((Identifier id) => users.add(id.username));
    int numUsersOnStreet = users.length;
    if (numUsersOnStreet == 1) {
      return false;
    } else {
      int amt;
      if (numUsersOnStreet < 10) {
        amt = 20;
      } else if (numUsersOnStreet > 10 && numUsersOnStreet < 20) {
        amt = 40;
      } else {
        amt = 60;
      }

      amt = (amt / numUsersOnStreet).ceil();
      users.forEach((String username) => trySetMetabolics(username, mood: amt, energy: amt, img: amt));
      StreetUpdateHandler.streets[streetName].occupants.forEach((WebSocket ws) => toast("Someone on $streetName is radiating. Everyone here got $amt energy, mood, and iMG", ws));
      return true;
    }
  }

  Future<bool> meditate({String streetName, Map map, WebSocket userSocket, String email}) async {
    toast("+5 energy, mood, and iMG", userSocket);
    return await trySetMetabolics(email, energy:5, mood:5, img: 5);
  }

  // //// //
  // Food //
  // //// //

  // takes away item and gives the stats specified in items/actions/consume.json

  Future<bool> consume({String streetName, Map map, WebSocket userSocket, String email}) async {
    bool success = await takeItemFromUser(userSocket, email, map['dropItem']['itemType'], map['count']);
    if (!success) {
      return false;
    }

    int energyAward = consumeValues[map['dropItem']['itemType']]['energy'];
    int moodAward = consumeValues[map['dropItem']['itemType']]['mood'];
    int imgAward = consumeValues[map['dropItem']['itemType']]['img'];

    toast("Consuming that ${map["dropItem"]["name"]} gave you $energyAward energy, $moodAward mood, and $imgAward iMG", userSocket);

    return await trySetMetabolics(email, energy:energyAward, mood:moodAward, img:imgAward);
  }

  // these two are just aliases to consume because they do the same thing, but are named differently in the item menu

  Future eat({String streetName, Map map, WebSocket userSocket, String email}) async {
    StatBuffer.incrementStat("foodsConsumed", 1);
    return consume(streetName:streetName, map:map, userSocket:userSocket, email:email);
  }

  Future drink({String streetName, Map map, WebSocket userSocket, String email}) async {
    StatBuffer.incrementStat("drinksConsumed", 1);
    return consume(streetName:streetName, map:map, userSocket:userSocket, email:email);
  }

  // //// //
  // Icon //
  // //// //

  Future<bool> tithe({String streetName, Map map, WebSocket userSocket, String email}) async {
    StatBuffer.incrementStat("iconsTithed", 11);
    return await trySetMetabolics(email, currants:-100);
  }

  Future<bool> ruminate({String streetName, Map map, WebSocket userSocket, String email}) async {
    StatBuffer.incrementStat("iconsRuminated", 11);
    return await trySetMetabolics(email, mood:50);
  }

  Future<bool> revere({String streetName, Map map, WebSocket userSocket, String email}) async {
    StatBuffer.incrementStat("iconsRevered", 11);
    return await trySetMetabolics(email, energy:50);
  }

  Future<bool> reflect({String streetName, Map map, WebSocket userSocket, String email}) async {
    StatBuffer.incrementStat("iconsTithed", 11);
    return await trySetMetabolics(email, img:50);
  }

  // //// //
  // Item //
  // //// //

  // ground -> inventory

  void pickup({WebSocket userSocket, String email}) {
    onGround = false;
    Item item = new Item.clone(itemType)
      ..onGround = false;
    addItemToUser(userSocket, email, item.getMap(), 1, item_id);
    StatBuffer.incrementStat("itemsPickedup", 1);
  }

  // inventory -> ground

  Future drop({WebSocket userSocket, Map map, String streetName, String email}) async {
    bool success = await takeItemFromUser(userSocket, email, map['dropItem']['itemType'], map['count']);
    if (!success) {
      return;
    }

    String id = "i" + createId(x, y, map['dropItem']['itemType'], map['tsid']);
    Item item = new Item.clone(itemType)
      ..x = map['x']
      ..y = map['y']
      ..item_id = id
      ..onGround = true;

    StreetUpdateHandler.streets[streetName].groundItems[id] = item;

    StatBuffer.incrementStat("itemsDropped", map['count']);
  }

  // /////// //
  // Recipes //
  // /////// //

  // Awesome Pot
  Future cook({String streetName, Map map, WebSocket userSocket, String email}) async {
    userSocket.add(JSON.encode(({"useItem": "Awesome Pot"})));
    return;
  }

  // Bean Seasoner
  Future seasonBeans({String streetName, Map map, WebSocket userSocket, String email}) async {
    userSocket.add(JSON.encode(({"useItem": "Bean Seasoner"})));
    return;
  }

  // Blender
  Future blend({String streetName, Map map, WebSocket userSocket, String email}) async {
    userSocket.add(JSON.encode(({"useItem": "Blender"})));
    return;
  }

  // Bubble Tuner
  Future tuneBubbles({String streetName, Map map, WebSocket userSocket, String email}) async {
    userSocket.add(JSON.encode(({"useItem": "Bubble Tuner"})));
    return;
  }

  // Cocktail Shaker
  Future shake({String streetName, Map map, WebSocket userSocket, String email}) async {
    userSocket.add(JSON.encode(({"useItem": "Cocktail Shaker"})));
    return;
  }

  // Egg Seasoner
  Future seasonEggs({String streetName, Map map, WebSocket userSocket, String email}) async {
    userSocket.add(JSON.encode(({"useItem": "Egg Seasoner"})));
    return;
  }

  // Famous Pugilist Grill
  Future grill({String streetName, Map map, WebSocket userSocket, String email}) async {
    userSocket.add(JSON.encode(({"useItem": "Famous Pugilist Grill"})));
    return;
  }

  // Fruit Changing Machine
  Future convertFruit({String streetName, Map map, WebSocket userSocket, String email}) async {
    userSocket.add(JSON.encode(({"useItem": "Fruit Changing Machine"})));
    return;
  }

  // Grinders
  Future<bool> crush({String streetName, Map map, WebSocket userSocket, String email}) async {
    // Two types, "grinder" and "grand_ol_grinder"
    // TODO: Send correct type to client, as the actions take different amounts of time once the window is open
    toast("Crushing is not implemented yet. Sorry!", userSocket);
    return false;
  }

  // Frying Pan
  Future fry({String streetName, Map map, WebSocket userSocket, String email}) async {
    userSocket.add(JSON.encode(({"useItem": "Frying Pan"})));
    return;
  }

  // Gassifier
  Future gassify({String streetName, Map map, WebSocket userSocket, String email}) async {
    userSocket.add(JSON.encode(({"useItem": "Gassifier"})));
    return;
  }

  // Loomer
  Future loom({String streetName, Map map, WebSocket userSocket, String email}) async {
    userSocket.add(JSON.encode(({"useItem": "Loomer"})));
    return;
  }

  // Saucepan
  Future simmer({String streetName, Map map, WebSocket userSocket, String email}) async {
    userSocket.add(JSON.encode(({"useItem": "Saucepan"})));
    return;
  }

  // Spice Mill
  Future mill({String streetName, Map map, WebSocket userSocket, String email}) async {
    userSocket.add(JSON.encode(({"useItem": "Spice Mill"})));
    return;
  }
}