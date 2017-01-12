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
		if (rsToken != clientToken) {
			return false;
		}

		try {
			// Can't friend yourself
			username = Uri.decodeComponent(username.trim());
			friendUsername = Uri.decodeComponent(friendUsername.trim());
			if (username == friendUsername) {
				return false;
			}

			// Get existing friends list
			String json = (await User.findByUsername(username)).friends;
			List<int> ids = JSON.decode(json);

			// Get new friend info
			int friendId = (await User.findByUsername(friendUsername)).id;
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

			// Notify new friend
			WebSocket friendSocket = StreetUpdateHandler.userSockets[await User.getEmailFromUsername(friendUsername)];
			if (friendSocket != null) {
				toast('$username added you to their friends!', friendSocket, onClick: 'addFriend|$username');
			}

			try {
				User.uncache(username: username);
				return await (dbConn.execute(
					'UPDATE users SET friends = @json WHERE username = @username',
					{'json': json, 'username': username})) == 1;
			} catch (e) {
				Log.error('Could not write friends list for $username while adding $friendUsername', e);
				return false;
			}
		} catch (e) {
			Log.warning("Could not add $friendUsername to $username's friends", e);
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
		if (rsToken != clientToken) {
			return false;
		}

		try {
			username = Uri.decodeComponent(username.trim());
			friendUsername = Uri.decodeComponent(friendUsername.trim());

			// Get existing friends list
			String json = (await User.findByUsername(username)).friends;
			List<int> ids = JSON.decode(json);

			// Get new friend info
			int friendId = (await User.findByUsername(friendUsername)).id;
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
		} catch (e) {
			Log.warning("Could not remove $friendUsername from $username's friends", e);
			return false;
		}
	}

	@app.Route('/list/:username')
	Future<Map<String, bool>> list(String username) async {
		try {
			// Get ids
			username = Uri.decodeComponent(username.trim());
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
		} catch (e) {
			Log.warning('Could not list friends for $username', e);
			return {};
		}
	}
}