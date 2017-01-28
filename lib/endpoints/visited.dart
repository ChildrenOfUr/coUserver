library visited;

import 'dart:async';
import 'dart:convert';

import 'package:redstone/redstone.dart' as app;

import 'package:coUserver/common/util.dart';
import 'package:coUserver/endpoints/metabolics/metabolics.dart';
import 'package:coUserver/common/mapdata/mapdata.dart';

@app.Route("/getLocationHistory/:email")
Future<List<String>> getLocationHistory(String email) async {
	Metabolics metabolics = await getMetabolics(email: email);
	String lhJson = metabolics.locationHistory;
	List<String> lhList = JSON.decode(lhJson);
	return lhList;
}

@app.Route("/getLocationHistoryInverse/:email")
Future<List<String>> getLocationHistoryInverse(
	String email, [@app.QueryParam("skipHidden") bool skipHidden = false]
) async {
	List<String> history = [];

	try {
		history = await getLocationHistory(email);
	} catch (e) {
		Log.warning('Error getting location history for <email=$email>', e);
	}

	List<String> allTsids = new List();
	MapData.streets.values.forEach((Map<String, dynamic> streetData) {
		if (
			// TSID available
			(streetData["tsid"] != null) &&
			// Either returning hidden streets or the street is not hidden
			(!skipHidden || !streetIsHidden(streetData))
		) {
			allTsids.add(streetData["tsid"]);
		}
	});
	return allTsids.where((String tsid) => !history.contains(tsid)).toList();
}

Future<String> randomUnvisitedTsid(String email, {bool inclHidden: true}) async {
	try {
		List<String> unvisited = await getLocationHistoryInverse(email, true);

		if (unvisited.length > 0) {
			return unvisited[rand.nextInt(unvisited.length)];
		} else {
			return 'ALL_VISITED';
		}
	} catch (e) {
		Log.warning('Could not find unvisited TSID for <email=$email>', e);
		return null;
	}
}

bool streetIsHidden(Map streetData) {
	try {
		// Street level
		if (streetData['map_hidden']) {
			return true;
		}

		// Hub level
		if (MapData.hubs[streetData['hub_id']]['map_hidden']) {
			return true;
		}

		return false;
	} catch(_) {
		// Missing data
		return false;
	}
}
