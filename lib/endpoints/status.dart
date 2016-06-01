library serverStatus;

import 'dart:async';
import 'dart:io';

import 'package:intl/intl.dart';
import 'package:redstone/redstone.dart' as app;

import 'package:coUserver/API_KEYS.dart';
import 'package:coUserver/street.dart';
import 'package:coUserver/street_update_handler.dart';
import 'package:coUserver/common/util.dart';
import 'package:coUserver/endpoints/chat_handler.dart';

@app.Group('/status')
class ServerStatus {
	/// Count uptime
	static DateTime _serverStart = new DateTime.now();

	/// List online players
	static List<String> get onlinePlayers {
		try {
			List<String> players = new List();
			players = ChatHandler.users.keys.where((String username) {
				// Prevent duplicates
				return !players.contains(username);
			}).toList();
			return players;
		} catch (e) {
			log('Error getting online players: $e');
			return new List();
		}
	}

	/// Count online players
	static int get numOnlinePlayers => onlinePlayers.length;

	/// List streets in memory
	static List<String> get streetsLoaded {
		try {
			List<String> streets = new List();
			StreetUpdateHandler.streets.values.forEach((Street street) {
				streets.add('${street.label} (${street.tsid}');
			});
			return streets..sort();
		} catch (e) {
			log('Error getting streets loaded: $e');
			return new List();
		}
	}

	/// Count streets in memory
	static int get numStreetsLoaded => streetsLoaded.length;

	/// Memory usage (bytes)
	static Future<int> get bytesUsed async {
		try {
			return int.parse(await _getScript('getMemoryUsage')) * 1024;
		} catch (e) {
			log('Error getting memory usage: $e');
			return 0;
		}
	}

	/// CPU usage (percent)
	static Future<double> get cpuUsed async {
		try {
			return double.parse(await _getScript('getCpuUsage'));
		} catch (e) {
			log('Error getting CPU usage: $e');
			return 0.0;
		}
	}

	/// Get time since server start (end of main method)
	static Duration get uptime {
		try {
			return new DateTime.now().difference(_serverStart);
		} catch (e) {
			log('Error getting uptime: $e');
			return new Duration();
		}
	}

	/// Get server log
	static Future<dynamic> getServerLog({bool removeEmails: false, bool list: false}) async {
		try {
			DateFormat format = new DateFormat('MM_dd_yy');
			String filename = 'serverLogs/${format.format(startDate)}-server.log';
			ProcessResult result = await Process.run('tail',
				['-n', '200', filename]);
			String log = result.stdout.toString().trim();

			// Remove player email addresses if not authenticated
			// This is why emails should always be logged as <email=$email>
			if (removeEmails) {
				log = log.replaceAll(new RegExp(r'<email=(.*?)>'), '<email>');
			}

			return (list ? log.split('\n') : log);
		} catch (e) {
			log('Error getting server log: $e');
			return new List();
		}
	}

	/// Run a bash script
	static Future<String> _getScript(String filename) async {
		ProcessResult proc = await Process.run("/bin/sh", ["$filename.sh"]);
		return proc.stdout.toString().trim();
	}
}

@app.Route('/serverStatus')
Future<Map<String, dynamic>> getServerStatus() async => {
	'numPlayers': ServerStatus.numOnlinePlayers,
	'playerList': ServerStatus.onlinePlayers,
	'numStreetsLoaded': ServerStatus.numStreetsLoaded,
	'streetsLoaded': ServerStatus.streetsLoaded,
	'bytesUsed': await ServerStatus.bytesUsed,
	'cpuUsed': await ServerStatus.cpuUsed,
	'uptime': ServerStatus.uptime.toString().split('.').first
};

// Get the server log
@app.Route('/serverLog')
Future<Map> getServerLog(@app.QueryParam('token') String token) async {
	bool authed = (token != null && token == redstoneToken);
	return {
		'authed': authed,
		'serverLog': (await ServerStatus.getServerLog(
			list: false, removeEmails: !authed))
	};
}
