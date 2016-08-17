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
	Future<List<String>> list(String username) async {
		String json = (await User.findByUsername(username)).friends;
		return JSON.decode(json);
	}
}