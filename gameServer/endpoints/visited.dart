part of coUserver;

@app.Route("/getLocationHistory/:email")
Future<List<String>> getLocationHistory(String email) async {
	Metabolics metabolics = await getMetabolics(email: email);
	String lhJson = metabolics.location_history;
	List<String> lhList = JSON.decode(lhJson);
	return lhList;
}