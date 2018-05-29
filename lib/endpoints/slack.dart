part of coUserver;

@app.Route('/slack', methods: const [app.POST])
String parseMessageFromSlack(@app.Body(app.FORM) Map form) {
	String token = form['token'];
	if (token != couKey && token != glitchForeverKey && token != devKey) {
		return "NOT AUTHORIZED";
	}

	String username = form['user_name'];
	String text = form['text'];
	Map map = {};

	if (username != "slackbot" && text != null && text.isNotEmpty) {
		if (token == couKey) {
			map = {'username':username, 'message': text, 'channel':'Global Chat'};
		} else {
			map = {'username':'$username', 'message': text, 'channel':'Global Chat'};
		}

		ChatHandler.sendAll(jsonEncode(map));
	}

	return "OK";
}
