library map_data;

import 'dart:convert';
import 'dart:io';

import 'package:coUserver/API_KEYS.dart';
import 'package:coUserver/common/util.dart';

import 'package:path/path.dart' as path;
import 'package:redstone/redstone.dart' as app;

part 'hubdata.dart';
part 'streetdata.dart';

Map<String, Map<String, dynamic>> mapdata;

@app.Route("/getMapData")
String getMapData(@app.QueryParam("token") String token) {
	if (token == redstoneToken) {
		// Only assemble the data the first time it is requested,
		// for future requests use the pre-assembled version
		if (mapdata == null) {
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
	Map<String, dynamic> street = null;
	mapdata_streets.forEach((String label, Map<String, dynamic> data) {
		if (street == null && data["tsid"] != null && tsidL(data["tsid"]) == tsidL(tsid)) {
			street = data..addAll({"label": label});
		}
	});
	return street ?? getStreetFile(tsid);
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

Map<String, dynamic> getStreetFile(String tsid) {
	if (tsid == null) {
		throw 'TSID cannot be null if you expect me to find a street file';
	}

	tsid = tsidG(tsid);
	Map<String, dynamic> streetData = {};

	// Find CAT422 directory
	String directory;
	if (Platform.script.data != null) {
		directory = Directory.current.path;
	} else {
		directory = Platform.script.toFilePath()
			.substring(0, directory.lastIndexOf(Platform.pathSeparator));
	}
	directory = directory.replaceAll('coUserver/test','coUserver');

	// Find street JSON file
	Directory locations = new Directory(path.join(directory, 'CAT422', 'locations'));
	File streetFile = new File(path.join(locations.path, '$tsid.json'));

	// Read street JSON file
	if (streetFile.existsSync()) {
		streetData = JSON.decode(streetFile.readAsStringSync());
	} else {
		Log.warning('Street <tsidG=$tsid> not found in CAT422 files');
	}

	return streetData;
}
