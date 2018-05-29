part of entity;

class HollowDoor extends Door {
	static final List<Map<String, dynamic>> DATA = [
		{
			"outside": {
				"tsid": "LCR195Q63RK143M",
				"streetName": "Grimssea Bottom"
			},
			"inside": {
				"tsid": "LDODG1KQLOS2GNO",
				"streetName": "Grimssea Hollow"
			}
		}
	];

	static Map<String, dynamic> _findState(String streetName) {
		bool _outside = false;
		Map _data = new Map();

		for(Map<String, dynamic> hollowDoorData in DATA) {
			if (hollowDoorData["outside"]["streetName"] == streetName) {
				_outside = true;
				_data = hollowDoorData;
				break;
			} else if (hollowDoorData["inside"]["streetName"] == streetName) {
				_outside = false;
				_data = hollowDoorData;
				break;
			}
		}

		return ({
			"data": _data,
			"outside": _outside
		});
	}

	HollowDoor(String id, String streetName, num x, num y) : super(id, streetName, x, y) {
		Map<String, dynamic> datastate = _findState(streetName);
		outside = datastate["outside"];

		if (outside) {
			toLocation = datastate["data"]["inside"]["tsid"];
			actions = [
				new Action.withName("enter")
					..timeRequired = 0
					..enabled = true
					..actionWord = "walking in"
			];
			currentState = new Spritesheet(
				"door_shoppe_int",
				"https://childrenofur.com/assets/entityImages/door_asset_mini_door_01a_g1.png",
				55, 120, 55, 120, 1, true
			);
		} else {
			toLocation = datastate["data"]["outside"]["tsid"];
			actions = [
				new Action.withName("exit")
					..timeRequired = 0
					..enabled = true
					..actionWord = "walking out"
			];
			currentState = new Spritesheet(
				"door_shoppe_int",
				"https://childrenofur.com/assets/entityImages/door_asset_heights.png",
				154, 175, 154, 175, 1, true
			);
		}

		type = datastate["data"]["inside"]["streetName"];
	}

	@override
	void enter({WebSocket userSocket, String email}) {
		toast("You can't fit in there!", userSocket);
	}
}