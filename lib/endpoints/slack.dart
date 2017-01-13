part of coUserver;

@app.Route('/slack', methods: const [app.POST])
String parseMessageFromSlack(@app.Body(app.FORM) Map form) {
	String token = form['token'];
	if (token != KEYCHAIN.keys['couKey'] && token != KEYCHAIN.keys['glitchForeverKey'] && token != KEYCHAIN.keys['devKey']) {
		return "NOT AUTHORIZED";
	}

	String username = form['user_name'];
	String text = form['text'];
	Map map = {};

	if (username != "slackbot" && text != null && text.isNotEmpty) {
		if (token == KEYCHAIN.keys['couKey']) {
			map = {'username':username, 'message': text, 'channel':'Global Chat'};
		} else {
			map = {'username':'$username', 'message': text, 'channel':'Global Chat'};
		}

		ChatHandler.sendAll(JSON.encode(map));
	}

	return "OK";
}
