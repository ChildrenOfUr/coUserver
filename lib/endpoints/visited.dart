library visited;

import 'dart:async';
import 'dart:convert';

import 'package:coUserver/common/util.dart';
import 'package:coUserver/endpoints/metabolics/metabolics.dart';
import 'package:coUserver/common/mapdata/mapdata.dart';

import 'package:redstone/redstone.dart' as app;

@app.Route("/getLocationHistory/:email")
Future<List<String>> getLocationHistory(String email) async {
	Metabolics metabolics = await getMetabolics(email: email);
	String lhJson = metabolics.location_history;
	List<String> lhList = JSON.decode(lhJson);
	return lhList;
}

@app.Route("/getLocationHistoryInverse/:email")
Future<List<String>> getLocationHistoryInverse(
	String email, [@app.QueryParam("skipHidden") bool skipHidden = false]
) async {
	List<String> history = await getLocationHistory(email);
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
	List<String> unvisited = await getLocationHistoryInverse(email, true);
	if (unvisited.length > 0) {
		return unvisited[rand.nextInt(unvisited.length)];
	} else {
		List<Map> allWithData = MapData.streets.values.where((Map data) {
			if (data["tsid"] == null) {
				// Don't include streets without TSIDs
				return false;
			}

			if (inclHidden) {
				// Include hidden streets
				return true;
			} else {
				// Don't include hidden streets
				// Streets with a null value are not hidden (false)
				return ((data["map_hidden"] ?? false) != true);
			}
		}).toList();
		return allWithData[rand.nextInt(allWithData.length)]["tsid"];
	}
}

bool streetIsHidden(Map streetData) {
	try {
		bool streetLevel = (streetData["map_hidden"] ?? false);
		bool hubLevel = (MapData.hubs[streetData["hub_id"]]["map_hidden"] ?? false);
		return (streetLevel || hubLevel);
	} catch(_) {
		// Missing data
		return false;
	}
}
