part of coUserver;

class Vendor extends NPC {
	List<Map> itemsForSale = new List();
	String vendorType;
	List<Item> itemsToSell;

	Vendor(String id, int x, int y) : super(id, x, y) {
		//vendor actions are instant
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
	}

	@override
	update();

	buy({WebSocket userSocket, String email}) {
		Map map = {};
		map['vendorName'] = type;
		map['id'] = id;
		map['itemsForSale'] = itemsForSale;
		userSocket.add(JSON.encode(map));
	}

	sell({WebSocket userSocket, String email}) {
		//prepare the buy window at the same time
		Map map = {};
		map['vendorName'] = type;
		map['id'] = id;
		map['itemsForSale'] = itemsForSale;
		map['openWindow'] = 'vendorSell';
		userSocket.add(JSON.encode(map));
	}

	buyItem({WebSocket userSocket, String itemType, int num, String email}) async {
		if(!items.containsKey(itemType)) {
			return;
		}

		StatBuffer.incrementStat("itemsBoughtFromVendors", num);
		Item item = items[itemType];
		Metabolics m = await getMetabolics(email:email);
		if(m.currants >= item.price * num) {
			m.currants -= item.price * num;
			setMetabolics(m);
			addItemToUser(userSocket, email, item.getMap(), num, id);
		}
	}

	sellItem({WebSocket userSocket, String itemType, int num, String email}) async {
		if(!items.containsKey(itemType)) {
			return;
		}

		bool success = await takeItemFromUser(userSocket, email, items[itemType].getMap()['name'], num);

		if(success) {
			Item item = items[itemType];

			Metabolics m = await getMetabolics(email:email);
			m.currants += (item.price * num * .7) ~/ 1;
			setMetabolics(m);
		}
	}

	List<Map> pickItems(List<String> categories) {
		itemsToSell = items.values.where((Item m) {
			if(
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
}