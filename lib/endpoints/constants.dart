library constants;

import 'dart:convert';

import 'package:redstone/redstone.dart' as app;

@app.Group("/constants")
class Constants {

	int get quoinLimit => 100;

	num get quoinMultiplierLimit => 73; // prime

	@app.Route("/json")
	String getAll() {
		return JSON.encode({
			"quoinLimit": quoinLimit,
			"quoinMultiplierLimit": quoinMultiplierLimit
		});
	}

}

// Redstone doesn't like static
final Constants constants = new Constants();