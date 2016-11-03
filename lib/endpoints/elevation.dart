part of coUserver;

@app.Group('/elevation')
class Elevation {
	static final String DEFAULT = '_';

	static Map<String, String> _cache = new Map();
	static Elevation INSTANCE = new Elevation();

	/// Used by client applications (game, forums, site, etc)
	@app.Route('/get/:username')
	Future<String> get(String username) async {
		username = Uri.decodeComponent(username);

		if (_cache[username] != null) {
			return _cache[username];
		} else {
			List<User> rows = await dbConn.query(
				'SELECT elevation FROM users WHERE username = @username',
				User, {'username': username}
			);

			String elevationStr = DEFAULT;
			if (rows.length > 0) {
				elevationStr = rows.first.elevation ?? elevationStr;
			}

			_cache[username] = elevationStr;
			return elevationStr;
		}
	}

	/// Used to list guides/devs on site
	@app.Route('/list/:status')
	Future<List<Map<String, dynamic>>> list(String status) async {
		List<User> rows = await dbConn.query(
			'SELECT username, last_login FROM users'
			' WHERE elevation = @elevation',
			User, {'elevation': status}
		);

		List<Map<String, dynamic>> users = new List();

		rows.forEach((User user) {
			users.add({
				'username': user.username,
				'last_login': user.last_login?.toString() ?? 'never'
			});
		});

		return users;
	}

	/// Used by Slack
	@app.Route('/set')
	Future<String> set(
		@app.QueryParam('token') String token,
		@app.QueryParam('channel_id') String channel,
		@app.QueryParam('text') String text
	) async {
		if (token != slackPromoteToken) {
			return 'Invalid token';
		}

		if (channel != 'G0277NLQS') {
			return 'Run this from the administration group';
		}

		String elevation;
		String username;
		try {
			List<String> parts = text.split(' ');
			elevation = parts.first.trim();
			username = parts.sublist(1).join(' ');
		} catch(_) {
			return 'Invalid parameters';
		}

		if (elevation == 'none') {
			elevation = DEFAULT;
		}

		int rows = await dbConn.execute(
			'UPDATE users SET elevation = @elevation WHERE username = @username',
			{'elevation': elevation, 'username': username}
		);

		if (rows == 1) {
			_cache[username] = elevation;
			return '$username is now ' + (elevation != DEFAULT ? 'a $elevation' : 'demoted');
		} else {
			return 'An unknown error occurred. Try again?';
		}
	}
}
