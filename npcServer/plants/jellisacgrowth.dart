part of coUserver;

class Jellisac extends Plant {
	Jellisac(String id, int x, int y) : super(id, x, y) {
		actionTime = 2000;
		type = "Jellisac Growth";

		actions.add({
			"action":"grab",
			"actionWord":"squishing",
			"timeRequired":actionTime,
			"enabled":true,
			"requires":[
				{
					"num":4,
					"of":['energy'],
					"error": "You need at least 4 energy to even think about touching this."
				}
			]
		});

		states = {
			"1-2-3-4-5" : new Spritesheet("1-2-3-4-5", "http://childrenofur.com/assets/entityImages/jellisac.png", 210, 49, 42, 49, 5, false),
		};
		int maturity = new Random().nextInt(states.length) + 1;
		currentState = states['1-2-3-4-5'];
		state = new Random().nextInt(currentState.numFrames);
		maxState = 5;
	}

	Future<bool> grab({WebSocket userSocket, String email}) async {
		bool success = await super.trySetMetabolics(email,energy:-4,imgMin:10,imgRange:5);
		if(!success) {
			return false;
		}

		StatBuffer.incrementStat("jellisacGrabbed", 1);
		state--;
		if(state < 1) {
			respawn = new DateTime.now().add(new Duration(minutes:2));
			return false;
		}

		int numToGive = 1;
		// 1 in 15 chance to get an extra
		if(new Random().nextInt(14) == 14) {
			numToGive = 2;
		}
		InventoryV2.addItemToUser(userSocket, email, items['jellisac'].getMap(), numToGive, id);

		return true;
	}
}