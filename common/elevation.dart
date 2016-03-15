part of coUserver;

@app.Group("/elevation")
class Elevation {
	static Map<String, String> _cache = new Map();
	static Elevation INSTANCE = new Elevation();

	/// Used by client applications (game, forums, site, etc)
	@app.Route("/get/:username")
	Future<String> get(String username) async {
		if (_cache[username] != null) {
			return _cache[username];
		} else {
			List<User> rows = await dbConn.query(
				"SELECT elevation FROM users WHERE username = @username",
				User, {"username": username}
			);

			String elevationStr = rows.first.elevation ?? "";

			_cache[username] = elevationStr;
			return elevationStr;
		}
	}

	/// Used by Slack
	/*
	token=9rZYYzfD4qAcpT1SWzL7mDvb
	team_id=T0001
	team_domain=example
	channel_id=C2147483705
	channel_name=test
	user_id=U2147483697
	user_name=Steve
	command=/weather
	text=94070
	response_url=https://hooks.slack.com/commands/1234/5678
	 */
	@app.Route("/set")
	Future<String> set(
		@app.QueryParam("token") String token,
		@app.QueryParam("channel_name") String channelName,
		@app.QueryParam("text") String text
	) async {
		if (token != slackPromoteToken) {
			return "Invalid token";
		}

		if (channelName != "administration") {
			return "Run this command from the administration group";
		}

		String elevation;
		String username;
		try {
			List<String> parts = text.split(" ");
			elevation = parts.first.trim();
			username = parts.sublist(1).join(" ");
		} catch(_) {
			return "Invalid parameters";
		}

		if (elevation == "none") {
			elevation = "";
		}

		int rows = await dbConn.execute(
			"UPDATE users SET elevation = @elevation WHERE username = @username",
			{"elevation": elevation, "username": username}
		);

		if (rows == 1) {
			_cache[username] = elevation;
			return "$username is now a $elevation";
		} else {
			return "An unknown error occurred. Try again?";
		}
	}
}