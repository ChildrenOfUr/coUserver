part of coUserver;

class Vendor extends NPC {
  List<Map> itemsForSale = new List();
  String vendorType;

  Vendor (String id, int x, int y) : super(id, x, y) {
    actions
      ..add({"action":"buy",
        "timeRequired":actionTime,
        "enabled":true,
        "actionWord":""})
      ..add({"action":"sell",
        "timeRequired":actionTime,
        "enabled":true,
        "actionWord":""});
  }

  buyItem({WebSocket userSocket, String itemType, int num, String email}) async {
    StatBuffer.incrementStat("itemsBoughtFromVendors", num);
    Item item = items[itemType];
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

  List<Map> _pickItems(List<String> categories) {
    List<Item> itemsToSell = items.values.where((Item m) {
      if (
      categories.contains(m.getMap()["category"])) {
        return true;
      } else {
        return false;
      }
    }).toList();

    List<Map> sellList = new List();

    itemsToSell.forEach((Item content) {
      sellList.add(content.getMap());
    });

    return sellList;
  }

  List _getItemsForSale() {
    return itemsForSale;
  }

  @override
  update() {

  }
}