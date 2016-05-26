library map_data;

import 'dart:convert';

import 'package:coUserver/API_KEYS.dart';
import 'package:coUserver/common/util.dart';

import 'package:redstone/redstone.dart' as app;

part 'hubdata.dart';
part 'streetdata.dart';

Map<String, Map<String, dynamic>> mapdata;

@app.Route("/getMapData")
String getMapData(@app.QueryParam("token") String token) {
	if (token == redstoneToken) {
		// Only assemble the data the first time it is requested,
		// for future requests use the pre-assembled version
		if(mapdata == null) {
			mapdata = {
				"hubs": mapdata_hubs,
				"streets": mapdata_streets
			};
		}
		return JSON.encode(mapdata);
	} else {
		return "Invalid token";
	}
}

Map<String, dynamic> getStreetByTsid(String tsid) {
	for (Map<String, dynamic> testStreet in mapdata_streets.values) {
		if (testStreet["tsid"] != null) {
			String testTsid = tsidL(testStreet["tsid"]);
			if (testTsid == tsid) {
				return testStreet;
			}
		}
	}

	return null;
}

Map<String, dynamic> getStreetByName(String name) {
	return mapdata_streets[name];
}

List<Map<String, dynamic>> getStreetsInHub(String hubId) {
	return mapdata_streets.values.where((Map<String, dynamic> street) {
		if (street["hub_id"] == null) {
			return false;
		} else {
			return street["hub_id"] == hubId;
		}
	}).toList();
}
