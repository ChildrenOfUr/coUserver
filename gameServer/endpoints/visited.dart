part of coUserver;

@app.Route("/getLocationHistory/:email")
Future<List<String>> getLocationHistory(String email) async {
	Metabolics metabolics = await getMetabolics(email: email);
	String lhJson = metabolics.location_history;
	List<String> lhList = JSON.decode(lhJson);
	return lhList;
}

@app.Route("/getLocationHistoryInverse/:email")
Future<List<String>> getLocationHistoryInverse(String email) async {
	List<String> history = await getLocationHistory(email);
	List<String> allTsids = new List();
	mapdata_streets.values.forEach((Map<String, dynamic> streetData) {
		if (streetData["tsid"] != null) {
			allTsids.add(streetData["tsid"]);
		}
	});
	return allTsids.where((String tsid) => !history.contains(tsid)).toList();
}