part of map_data;

abstract class MapdataEndpoint {
	static Map<String, Map<String, Map<String, dynamic>>> mapdata;

	static void init(
		Map<String, Map<String, dynamic>> hubs,
		Map<String, Map<String, dynamic>> streets
	) {
		mapdata = {
			'hubs': hubs,
			'streets': streets
		};
	}

	static String getMapData() {
		return JSON.encode(mapdata);
	}
}

@app.Route('/getMapData')
String getMapData(@app.QueryParam('token') String token) {
	if (token == redstoneToken) {
		return MapdataEndpoint.getMapData();
	} else {
		return 'Invalid token';
	}
}
