part of entity;

class TealWhiteTriangleLockedDoor extends LockedDoor {
	TealWhiteTriangleLockedDoor(String id, String streetName, int x, int y) : super(id, streetName, x, y) {
		requiredKey = "teal_white_triangle_key";

		if (streetName == "Ajaya Bliss") {
			toLocation = "LA9B6PJ3NM22M0D"; // Subarna Spells
			outside = false;
		} else if (streetName == "Subarna Spells") {
			toLocation = "LA9154LI9R22R7A"; // Ajaya Bliss
			outside = true;
			ItemRequirements keyReq = new ItemRequirements()
				..any = [requiredKey]
				..error = 'You need a Teal-White Triangle Key to unlock this door';
			actions.add(
				new Action.withName('enter')
					..actionWord = 'entering'
					..itemRequirements = keyReq
			);
		}

		currentState = new Spritesheet("door_bh_int", "http://childrenofur.com/assets/entityImages/door_asset_bureaucratic_hall_int.svg", 132, 312, 132, 312, 1, true);
	}
}