part of entity;

class ShoppeDoor extends Door {
	ShoppeDoor(String id, String streetName, num x, num y)
	: super(id, streetName, x, y) {
		if (streetName == "Uncle Friendly's Emporium") {
			toLocation = "LM4109NI2R640"; // Guillermo Gamera Way
			outside = false;
			actions.add(
				new Action.withName('exit')
					..actionWord = 'walking out'
				);
			currentState = new Spritesheet("door_shoppe_int",
			                               "http://childrenofur.com/assets/entityImages/door_asset_shoppeIn.svg", 187,
			                               164, 187, 164, 1, true);
		} else if (streetName == "Guillermo Gamera Way") {
			toLocation = "LM4118MEHFDMM"; // Uncle Friendly's Emporium
			outside = true;
			actions.add(
				new Action.withName('enter')
					..actionWord = 'walking in'
				);
			currentState = new Spritesheet("door_shoppe_int",
			                               "http://childrenofur.com/assets/entityImages/door_asset_shoppe.svg", 182,
			                               166, 182, 166, 1, true);
		}
		type = "Uncle Friendly's Emporium";
	}
}
