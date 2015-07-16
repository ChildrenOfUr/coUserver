part of coUserver;

class ShoppeDoor extends Door {
	ShoppeDoor(String id, String streetName, int x, int y) : super (id, streetName, x, y) {
		if(streetName == "Uncle Friendly's Emporium") {
			toLocation = "LM4109NI2R640"; // Guillermo Gamera Way
			outside = false;
			currentState = new Spritesheet("door_shoppe_int", "http://childrenofur.com/assets/game/doors/shoppe_door_int.png", 187, 164, 187, 164, 1, true);
		} else if(streetName == "Guillermo Gamera Way") {
			toLocation = "LM4118MEHFDMM"; // Uncle Friendly's Emporium
			outside = true;
			currentState = new Spritesheet("door_shoppe_int", "http://childrenofur.com/assets/game/doors/shoppe_door_ext.png", 182, 166, 182, 166, 1, true);
		}
		type = "Uncle Friendly's Emporium";
		if(outside) {
			actions.add({
				            "action": "enter",
				            "timeRequired": 0,
				            "enabled": true,
				            "actionWord": "walking in"
			            });
		} else {
			actions.add({
				            "action": "exit",
				            "timeRequired": 0,
				            "enabled": true,
				            "actionWord": "walking out"
			            });
		}
	}
}