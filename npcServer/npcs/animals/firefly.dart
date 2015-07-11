part of coUserver;

class Firefly extends NPC {
	Firefly(String id, int x, int y) : super(id, x, y) {
		actionTime = 4000;
		type = "Firefly";
		actions
			..add({
			"action": "collect",
			"timeRequired": actionTime,
			"enabled": true,
			"actionWord": "chasing",
			"requires":[
				{
					'num':3,
					'of':['energy'],
					"error": "Chasing fireflies is hard work, so you'll need at least 3 energy."
				},
				{
					'num': 1,
					'of': ['firefly_jar'],
					"error": "Fireflies won't stay in your hands. You need a jar."
				}
			]
		});
		speed = 5; //pixels per second
		states = {
			"fullPath": new Spritesheet("fullPath", "http://c2.glitch.bz/items/2012-12-06/npc_firefly__x1_fullPath_png_1354833043.png", 870, 360, 87, 40, 89, true),
			"halfPath": new Spritesheet("halfPath", "http://c2.glitch.bz/items/2012-12-06/npc_firefly__x1_halfPath_png_1354833044.png", 870, 160, 87, 40, 40, true),
			"smallPath": new Spritesheet("smallPath", "http://c2.glitch.bz/items/2012-12-06/npc_firefly__x1_smallPath_png_1354833044.png", 870, 80, 87, 40, 20, true)
		};
		currentState = states["fullPath"];
	}

	Future<bool> collect({WebSocket userSocket, String email}) async {
		// small flight path for 10 seconds
		currentState = states["smallPath"];
		int length = (10000 * (currentState.numFrames / 30 * 1000)).toInt();
		respawn = new DateTime.now().add(new Duration(milliseconds:length));

		// no such action yet
		return false;
	}

	update() {
		//if respawn is in the past, it is time to choose a new animation
		if(respawn != null && new DateTime.now().compareTo(respawn) > 0) {
			// 50% chance to move the other way...gradually
			if (rand.nextInt(1) == 0) {
				facingRight = !facingRight;
			}

			switch (rand.nextInt(4)) {
				case 0:
				case 1:
					currentState = states["fullPath"];
					break;
				case 2:
				case 3:
					currentState = states["halfPath"];
					break;
				case 4:
					currentState = states["smallPath"];
			}

			// stay for 10 seconds
			int length = (10000 * (currentState.numFrames / 30 * 1000)).toInt();
			respawn = new DateTime.now().add(new Duration(milliseconds:length));
		}
	}
}