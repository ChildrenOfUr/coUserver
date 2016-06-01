// Used by the mapfiller to report broken streets
/*
@app.Route('/reportStreet')
String reportStreet(@app.QueryParam('tsid') String tsid,
                   @app.QueryParam('reason') String reason,
                   @app.QueryParam('details') String details) {
	reportBrokenStreet(tsid, reason);

	// Post a message to map-filler-reports
	slack.token = mapFillerReportsToken;
	slack.team = slackTeam;

	String text = "$tsid: $reason\n$details";
	slack.Message message = new slack.Message(text, username:"doesn't apply");
	slack.send(message);

	return "OK";
}
*/

// Used by the mapfiller to find a street to edit
/*
@app.Route('/getRandomStreet')
String getRandomStreet() => getTsidOfUnfilledStreet();
*/


// Used by the mapfiller to save entities
/*
@app.Route('/entityUpload', methods: const[app.POST])
String uploadEntities(@app.Body(app.JSON) Map params) {
	if (params['tsid'] == null) {
		return "FAIL";
	} else {
		saveStreetData(params);
		return "OK";
	}
}
*/
