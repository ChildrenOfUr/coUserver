part of coUserver;

class KeepAlive {
	static List<WebSocket> pingList = [];
	static List<WebSocket> notResponded = [];

	static void start() {
		new Timer.periodic(new Duration(seconds: 15), (_) {
			notResponded = [];

			pingList.forEach((WebSocket websocket) {
				notResponded.add(websocket);
				Map pingMap = new Map();
				pingMap["statusMessage"] = "ping";
				pingMap['channel'] = 'Local Chat';
				websocket.add(JSON.encode(pingMap));
			});

			new Timer(new Duration(seconds: 10), () {
				notResponded.forEach((WebSocket websocket) =>
					ChatHandler.cleanupLists(websocket, reason: 'no response to ping'));
			});
		});
	}
}