part of coUserver;

// USERS

@app.Route('/searchUsers')
Future<List<String>> searchUsers(@app.QueryParam('query') String query) async {
	query = '%${query.toLowerCase()}%';

	List<User> users = await dbConn.query(
		'SELECT * FROM users WHERE lower(username) LIKE @query',
		User, {'query': query});

	List<String> usernames = [];

	users.forEach((User user) {
		usernames.add(user.username);
	});

	return usernames;
}

@app.Route('/listUsers')
Future<List<String>> listUsers(@app.QueryParam('channel') String channel) async {
	List<String> users = [];

	List<Identifier> ids = ChatHandler.users.values.where((Identifier id) =>
		id.channelList.contains(channel)).toList();

	ids.forEach((Identifier id) => users.add(id.username));

	return users;
}

// IP ADDRESSES

List<String> connectionHistory = [];

@app.Route('/addresses')
List<String> getConnectionHistory() => connectionHistory;

void addToConnectionHistory(InternetAddress address) {
	if (!connectionHistory.contains(address.address)) {
		connectionHistory.add(address.address);
	}
}