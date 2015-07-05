part of coUserver;

class Shrine extends NPC {
	String description;

	Shrine(String id, int x, int y) : super(id, x, y) {
		actionTime = 0;

		actions
			..add({"action":"Commune With",
				      "timeRequired":actionTime,
				      "enabled":true,
				      "actionWord":""});
	}

	@override
	void update() {
	}

	communeWith({WebSocket userSocket, String email}) async {
		Metabolics m = await getMetabolics(email:email);

		String giantName = type.substring(0, 1).toUpperCase() + type.substring(1);
		InstanceMirror instanceMirror = reflect(m);
		int giantFavor = instanceMirror.getField(new Symbol(giantName.toLowerCase() + 'favor')).reflectee;

		Map map = {};
		map['giantName'] = giantName;
		map['favor'] = giantFavor;
		map['maxFavor'] = 1000;
		map['id'] = id;
		userSocket.add(JSON.encode(map));
	}

	donate({WebSocket userSocket, String itemType, int num, String email}) async {
		bool success = await takeItemFromUser(userSocket, email, itemType, num);
		if(success) {
			Item item = items[itemType];
			String giantName = type.substring(0, 1).toUpperCase() + type.substring(1);
			Metabolics m = await getMetabolics(email:email);
			InstanceMirror instanceMirror = reflect(m);
			int giantFavor = instanceMirror.getField(new Symbol(giantName.toLowerCase() + 'favor')).reflectee;
			int favAmt = (item.price * num * .35) ~/ 1;
			if(giantFavor >= 1000) {
				instanceMirror.setField(new Symbol(giantName.toLowerCase() + 'favor'), 0);
				addItemToUser(userSocket, email, items['emblem_of_' + giantName.toLowerCase()].getMap(), 1, id);
			} else {
				instanceMirror.setField(new Symbol(giantName.toLowerCase() + 'favor'), giantFavor + favAmt);
			}
			setMetabolics(m);

			Map addedFavorMap = {};
			addedFavorMap['favorUpdate'] = true;
			addedFavorMap['favor'] = giantFavor + favAmt;
			addedFavorMap['maxFavor'] = 1000;
			userSocket.add(JSON.encode(addedFavorMap));
		} else {
			print("$email failed to donate $num $itemType to $type");
		}
	}
}