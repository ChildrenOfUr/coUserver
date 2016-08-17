part of coUserver;

@app.Group('/friends')
class FriendsEndpoint {
	@app.Route('/add')
	Future<bool> add(
		@app.QueryParam('username') String username,
		@app.QueryParam('friendUsername') String friendUsername,
		@app.QueryParam('rstoken') String rsToken
	) async {
		// Check authentication
		if (rsToken != redstoneToken) {
			return false;
		}

		// Can't friend yourself
		username = username.trim();
		friendUsername = friendUsername.trim();
		if (username == friendUsername) {
			return false;
		}

		// Get existing friends list
		String json = (await User.findByUsername(username)).friends;
		List<int> ids = JSON.decode(json);

		// Get new friend info
		int friendId = await User.getIdFromUsername(friendUsername);
		if (friendId == null) {
			return false;
		}

		// Add to list (if not already on it)
		if (!ids.contains(friendId)) {
			ids.add(friendId);
			ids.sort();
		} else {
			// Already on it
			return false;
		}

		// Save new friends list
		json = JSON.encode(ids);

		try {
			User.uncache(username: username);
			return await (dbConn.execute(
				'UPDATE users SET friends = @json WHERE username = @username',
				{'json': json, 'username': username})) == 1;
		} catch (e) {
			Log.error('Could not write friends list for $username while adding $friendUsername', e);
			return false;
		}
	}

	@app.Route('/remove')
	Future<bool> remove(
		@app.QueryParam('username') String username,
		@app.QueryParam('friendUsername') String friendUsername,
		@app.QueryParam('rstoken') String rsToken
	) async {
		// Check authentication
		if (rsToken != redstoneToken) {
			return false;
		}

		username = username.trim();
		friendUsername = friendUsername.trim();

		// Get existing friends list
		String json = (await User.findByUsername(username)).friends;
		List<int> ids = JSON.decode(json);

		// Get new friend info
		int friendId = await User.getIdFromUsername(friendUsername);
		if (friendId == null) {
			return false;
		}

		// Remove from list (if on it)
		if (ids.contains(friendId)) {
			ids.remove(friendId);
			ids.sort();
		} else {
			// Not on it
			return false;
		}

		// Save new friends list
		json = JSON.encode(ids);

		try {
			User.uncache(username: username);
			return await (dbConn.execute(
				'UPDATE users SET friends = @json WHERE username = @username',
				{'json': json, 'username': username})) == 1;
		} catch (e) {
			Log.error('Could not write friends list for <username=$username> while removing <friendUsername=$friendUsername>', e);
			return false;
		}
	}

	@app.Route('/list/:username')
	Future<Map<String, bool>> list(String username) async {
		// Get ids
		username = username.trim();
		List<int> ids = JSON.decode((await User.findByUsername(username)).friends);

		// Convert to usernames
		List<String> usernames = [];
		await Future.forEach(ids, (int id) async => usernames.add(await User.getUsernameFromId(id)));
		usernames.sort();

		// Check whether they are online
		List<String> onlineUsers = [];
		List<String> offlineUsers = [];
		usernames.forEach((String username) {
			if (ServerStatus.onlinePlayers.contains(username)) {
				onlineUsers.add(username);
			} else {
				offlineUsers.add(username);
			}
		});

		// Sort with online first
		Map<String, bool> statuses = {};
		onlineUsers.forEach((String username) => statuses.addAll({username: true}));
		offlineUsers.forEach((String username) => statuses.addAll({username: false}));
		return statuses;
	}
}