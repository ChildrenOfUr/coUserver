library constants;

import 'dart:convert';

import 'package:redstone/redstone.dart' as app;

@app.Group("/constants")
class Constants {

	int get quoinLimit => 100;

	num get quoinMultiplierLimit => 73; // prime

	int get changeUsernameCost => 1000;

	@app.Route("/json")
	String getAll() {
		return jsonEncode({
			"quoinLimit": quoinLimit,
			"quoinMultiplierLimit": quoinMultiplierLimit,
			"changeUsernameCost": changeUsernameCost
		});
	}

}

// Redstone doesn't like static
final Constants constants = new Constants();
