part of coUserver;

class ShoppeDoor extends Door {
	ShoppeDoor(String id, String streetName, int x, int y)
	: super(id, streetName, x, y) {
		if (streetName == "Uncle Friendly's Emporium") {
			toLocation = "LM4109NI2R640"; // Guillermo Gamera Way
			outside = false;
			actions.add({
				            "action": "exit",
				            "timeRequired": 0,
				            "enabled": true,
				            "actionWord": "walking out"
			            });
			currentState = new Spritesheet("door_shoppe_int",
			                               "http://childrenofur.com/assets/entityImages/door_asset_shoppeIn.svg", 187,
			                               164, 187, 164, 1, true);
		} else if (streetName == "Guillermo Gamera Way") {
			toLocation = "LM4118MEHFDMM"; // Uncle Friendly's Emporium
			outside = true;
			actions.add({
				            "action": "enter",
				            "timeRequired": 0,
				            "enabled": true,
				            "actionWord": "walking in"
			            });
			currentState = new Spritesheet("door_shoppe_int",
			                               "http://childrenofur.com/assets/entityImages/door_asset_shoppe.svg", 182,
			                               166, 182, 166, 1, true);
		}
		type = "Uncle Friendly's Emporium";
	}
}
