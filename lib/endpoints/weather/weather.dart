library weather;

import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:redstone_mapper/mapper.dart';

import 'package:coUserver/API_KEYS.dart';
import 'package:coUserver/common/mapdata/mapdata.dart';
import 'package:coUserver/common/util.dart';
import 'package:coUserver/streets/player_update_handler.dart';

part 'weather_data.dart';
part 'weather_location.dart';
part 'weather_service.dart';

/// Handles client communication through WebSockets
class WeatherEndpoint {
	/// Send the data to the client every 5 seconds
	static final Timer updateTimer = new Timer.periodic(
		new Duration(seconds: 5), (_) => update());

	/// Connected clients
	static Map<String, WebSocket> userSockets = {};

	/// Add a new client
	static void handle(WebSocket ws) {
		ws.listen(
			(message) => processMessage(ws, message),
			onError: (_) => cleanupList(ws),
			onDone: () => cleanupList(ws));
	}

	/// Remove disconnected clients
	static void cleanupList(WebSocket ws) {
		String leavingUser;

		userSockets.forEach((String username, WebSocket socket) {
			if (ws == socket) {
				socket = null;
				leavingUser = username;
			}
		});

		userSockets.remove(leavingUser);
	}

	/// Handle incoming messages from clients
	static Future processMessage(WebSocket ws, String message) async {
		Map map = JSON.decode(message);
		String username = map['username'];
		String tsid = map['tsid'].toString();

		// Add reference to user if not already stored
		if (!userSockets.containsKey(username)) {
			userSockets[username] = ws;
		}

		// Send the current weather to the just connected user
		if (tsid != 'null') {
			// Get weather data for location
			ws.add(JSON.encode(await WeatherService.getConditionsMap(tsid)));
		} else {
			// Client will retry when it is done loading
			ws.close(null, 'Street not loaded');
		}
	}

	/// Whether the weather is rainy on a street
	static Future<bool> rainingIn(String tsid) async {
		WeatherLocation weather = await WeatherService.getConditions(tsid);
		return weather.current.weatherMain.toLowerCase().contains('rain');
	}

	/// Send data to all clients
	static Future update() async {
		await Future.forEach(userSockets.keys, (String username) async {
			String tsid = PlayerUpdateHandler.users[username].tsid;
			userSockets[username].add(JSON.encode({
				'current': encode(await WeatherService.getConditions(tsid))
			}));
		});
	}
}

// TODO: maybe use the clock math to convert the real dates in the weather forecast to Ur dates?
