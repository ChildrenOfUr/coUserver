library serverStatus;

import 'dart:async';
import 'dart:io';

import 'package:intl/intl.dart';
import 'package:redstone/redstone.dart' as app;

import 'package:coUserver/globals.dart';
import 'package:coUserver/streets/street.dart';
import 'package:coUserver/streets/street_update_handler.dart';
import 'package:coUserver/common/util.dart';
import 'package:coUserver/endpoints/chat_handler.dart';

@app.Group('/status')
class ServerStatus {
	/// Count uptime
	static DateTime serverStart;

	/// List online players
	static List<String> get onlinePlayers {
		try {
			List<String> players = new List();
			players = ChatHandler.users.keys.where((String username) {
				// Prevent duplicates
				return !players.contains(username);
			}).toList();
			return players;
		} catch (e, st) {
			Log.error('Getting online players', e, st);
			return new List();
		}
	}

	/// Count online players
	static int get numOnlinePlayers => onlinePlayers.length;

	/// List streets in memory
	static List<Map<String, String>> get streetsLoaded {
		try {
			List<Map<String, String>> streets = new List();
			StreetUpdateHandler.streets.values.forEach((Street street) {
				streets.add({
					'label': street.label,
					'tsid': street.tsid
				});
			});
			return streets;
		} catch (e, st) {
			Log.error('Listing loaded streets', e, st);
			return new List();
		}
	}

	/// Count streets in memory
	static int get numStreetsLoaded => streetsLoaded.length;

	/// Memory usage (bytes)
	static Future<int> get bytesUsed async {
		try {
			return int.parse(await _getScript('getMemoryUsage')) * 1024;
		} catch (e, st) {
			Log.error('Getting memory usage', e, st);
			return 0;
		}
	}

	/// CPU usage (percent)
	static Future<double> get cpuUsed async {
		try {
			return double.parse(await _getScript('getCpuUsage'));
		} catch (e, st) {
			Log.error('Getting CPU usage', e, st);
			return 0.0;
		}
	}

	/// Get time since server start (end of main method)
	static Duration get uptime {
		try {
			return new DateTime.now().difference(serverStart);
		} catch (e, st) {
			Log.error('Getting uptime', e, st);
			return new Duration();
		}
	}

	/// Get server log
	/// Returns either a String or a List<String> depending on the value of the list parameter
	static Future<dynamic> getServerLog({bool removeEmails: false, bool list: false}) async {
		try {
			DateFormat format = new DateFormat('MM_dd_yy');
			String filename = 'serverLogs/${format.format(serverStart)}-server.log';
			ProcessResult result = await Process.run('tail',
				['-n', '200', filename]);
			String log = result.stdout.toString().trim();

			// Remove player email addresses if not authenticated
			// This is why emails should always be logged as <email=$email>
			if (removeEmails) {
				log = log.replaceAll(new RegExp(r'<email=(.*?)>'), '<email>');
			}

			return (list ? log.split('\n') : log);
		} catch (e, st) {
			Log.error('Getting server log', e, st);
			return new List();
		}
	}

	/// Run a bash script
	static Future<String> _getScript(String filename) async {
		ProcessResult proc = await Process.run(
			"/bin/sh", ["$filename.sh", pid.toString()]);
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
	bool authed = (token != null && token == clientToken);
	return {
		'authed': authed,
		'serverLog': (await ServerStatus.getServerLog(
			list: false, removeEmails: !authed))
	};
}
