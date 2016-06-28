library weather;

import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';

enum WeatherState {
	CLEAR, RAINING, SNOWING, WINDY
}

class WeatherEndpoint
{
	static Timer simulateTimer = new Timer.periodic(new Duration(seconds: 5), (Timer timer) => simulate());
	static Map<String,WebSocket> userSockets = {};
	static Random rand = new Random();
	static WeatherState currentState = WeatherState.CLEAR;
	static DateTime respawn = new DateTime.now();

	static void handle(WebSocket ws)
	{
		simulateTimer.isActive;

		ws.listen((message) => processMessage(ws,message),
		onError: (error) => cleanupList(ws),
		onDone: () => cleanupList(ws));
	}

	static void cleanupList(WebSocket ws)
	{
		String leavingUser;

		userSockets.forEach((String username, WebSocket socket) {
			if(ws == socket) {
				socket = null;
				leavingUser = username;
			}
		});

		userSockets.remove(leavingUser);
	}

	static void processMessage(WebSocket ws, String message)
	{
		Map map = JSON.decode(message);
		String username = map['username'];

		if(!userSockets.containsKey(username))
			userSockets[username] = ws;

		//send the current weather to the just connected user
		ws.add(JSON.encode({'state':currentState.index}));
	}

	static void simulate() {
		//decide what kind of weather should happen
		//once we've picked one, we should set a timeout so that we don't change it for a while
		//maybe 240 in-game minutes to 600 in-game minutes before we decide again
		//75% chance of clear skies, 25% chance of rain/snow
		if(respawn == null || respawn.compareTo(new DateTime.now()) > 0) {
			return;
		}

		int result = rand.nextInt(100);
		if(result >= 75) {
			currentState = WeatherState.RAINING;
		} else {
			currentState = WeatherState.CLEAR;
		}

		int numGameMinutes = rand.nextInt(360)+240;
		respawn = new DateTime.now().add(new Duration(seconds:numGameMinutes*10));

		//once we've decided what to do, send the current weather to all the connected users
		userSockets.forEach((String username, WebSocket ws) {
			ws.add(JSON.encode({'state':currentState.index}));
		});
	}
}
