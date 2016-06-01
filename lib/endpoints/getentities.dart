part of coUserver;

@app.Route('/getEntities')
Future<Map<String, dynamic>> getEntities(@app.QueryParam('tsid') String tsid) async {
	return {"entities": encode(await StreetEntities.getEntities(tsid))};
}
