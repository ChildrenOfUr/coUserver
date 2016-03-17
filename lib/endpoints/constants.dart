library constants;

import 'dart:convert';

import 'package:redstone/redstone.dart' as app;

@app.Group("/constants")
class Constants {

	/* * * * * * * * * * *
	 * Daily Quoin Limit *
	 * * * * * * * * * * */

	int get quoinLimit => 100;

	@app.Route("/quoinLimit")
	int getQuoinLimit() {
		return quoinLimit;
	}

	/* * * * * * * * * * * * *
	 * Quoin Multiplier Cap  *
	 * * * * * * * * * * * * */

	num get quoinMultiplierLimit => 73; // prime

	@app.Route("/quoinMultiplierLimit")
	num getQuoinMultiplierLimit() {
		return quoinMultiplierLimit;
	}

	/* * * * * * * * *
	 * All Constants *
	 * * * * * * * * */

	@app.Route("/json")
	String getAll() {
		return JSON.encode({
			"quoinLimit": quoinLimit,
			"quoinMultiplierLimit": quoinMultiplierLimit
		});
	}

}

// Redstone doesn't like static
Constants constants = new Constants();