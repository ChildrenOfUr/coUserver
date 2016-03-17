part of entity;

class BureaucraticHallDoor extends Door {
	BureaucraticHallDoor(String id, String streetName, x, y) : super (id, streetName, x, y) {
		if(streetName.toLowerCase().contains("bureaucratic hall")) {
			switch(streetName) {
				case "Andra Bureaucratic Hall":
					toLocation = "LA5I10NJDL52TKD";
					// Chego Chase
					break;

				case "Muufo Bureaucratic Hall":
					toLocation = "LA91JUQT2G82GUL";
					// Baeli Bray
					break;

				case "Bureaucratic Hall":
					toLocation = "LLI32G3NUTD100I";
					// Gregarious Grange
					break;
			}
			outside = false;
			actions.add({
				"action": "exit",
				"timeRequired": 0,
				"enabled": true,
				"actionWord": "walking out"
			});
			currentState = new Spritesheet("door_bh_int", "http://childrenofur.com/assets/entityImages/door_asset_bureaucratic_hall_int.svg", 132, 312, 132, 312, 1, true);
		} else {
			switch(streetName) {
				case "Chego Chase":
					toLocation = "LDOCV86VHCD245F";
					// Andra Bureaucratic Hall
					break;

				case "Baeli Bray":
					toLocation = "LIF2E3LVGK82J7Q";
					// Muufo Bureaucratic Hall
					break;

				case "Gregarious Grange":
					toLocation = "LIF101O8CDQ1AMU";
					// Bureaucratic Hall
					break;
			}
			outside = true;
			actions.add({
				"action": "enter",
				"timeRequired": 0,
				"enabled": true,
				"actionWord": "walking in"
			});
			currentState = new Spritesheet("door_bh_ext", "http://childrenofur.com/assets/entityImages/door_asset_bureaucratic_hall_ext.svg", 116, 122, 116, 122, 1, true);
		}
		type = "Bureaucratic Hall";
	}
}