part of entity;

class HellBartender extends NPC {
	HellBartender(String id, num x, num y, num z, num rotation, bool h_flip, String streetName) : super(id, x, y, z, rotation, h_flip, streetName) {
		type = "Hell Bartender";
		actionTime = 0;
		speed = 0;
		actions = [
			{
				"actionName": "glass of wine",
				"timeRequired": actionTime,
				"enabled": true,
				"actionWord": "wine"
			},
			{
				"actionName": "pint of beer",
				"timeRequired": actionTime,
				"enabled": true,
				"actionWord": "beer"
			}
		];
		states = {
			"idle1": new Spritesheet(
				"idle1",
				"https://childrenofur.com/assets/entityImages/hell_bartender__x1_idle1_png_1354837767.png",
				3416, 1182, 244, 197, 81, true
			),
			"idle2": new Spritesheet(
				"idle2",
				"https://childrenofur.com/assets/entityImages/hell_bartender__x1_idle2_png_1354837775.png",
				3660, 1182, 244, 197, 87, false
			),
			"talk_left": new Spritesheet(
				"talk_left",
				"https://childrenofur.com/assets/entityImages/hell_bartender__x1_talk_left_png_1354837789.png",
				3904, 1379, 244, 197, 110 , false
			),
			"talk_right_out": new Spritesheet(
				"talk_right_out",
				"https://childrenofur.com/assets/entityImages/hell_bartender__x1_talk_right_out_png_1354837783.png",
				976, 394, 244, 197, 7 , false
			),
			"talk_right": new Spritesheet(
				"talk_right",
				"https://childrenofur.com/assets/entityImages/hell_bartender__x1_talk_right_png_1354837781.png",
				3660, 1379, 244, 197, 103 , false
			)
		};
		setState("idle1");
	}

	@override
	update({bool simulateTick: false}) {
		if (respawn != null && new DateTime.now().isAfter(respawn)) {
			if (rand.nextInt(3) == 1) {
				setState('idle2');
			} else {
				setState('idle1');
			}
		}
	}

	Future glassOfWine({String email, WebSocket userSocket}) async {
		setState('talk_right', thenState: 'talk_right_out');
		say("I'm still setting up shop. Come back soon.");
	}

	Future pintOfBeer({String email, WebSocket userSocket}) async {
		setState('talk_right', thenState: 'talk_right_out');
		say("I'm still setting up shop. Come back soon.");
	}
}
