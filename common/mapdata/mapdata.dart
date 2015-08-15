part of coUserver;

Map<String, Map<String, dynamic>> mapdata;

@app.Route("/getMapData")
String getMapData(@app.QueryParam("token") String token) {
	if (token == redstoneToken) {
		// Only assemble the data the first time it is requested,
		// for future requests use the pre-assembled version
		if(mapdata == null) {
			mapdata = {
				"hubs": mapdata_hubs,
				"streets": mapdata_streets
			};
		}
		return JSON.encode(mapdata);
	} else {
		return "Invalid token";
	}
}