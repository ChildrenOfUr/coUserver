library map_data;

import 'dart:convert';
import 'dart:io';

import 'package:coUserver/API_KEYS.dart';
import 'package:coUserver/common/util.dart';

import 'package:path/path.dart' as path;
import 'package:redstone/redstone.dart' as app;

part 'mapdata_api.dart';

abstract class MapData {
	static Map<String, Map<String, dynamic>> _hubs;
	static Map<String, Map<String, dynamic>> _streets;
	static Map<String, Map<String, Map<String, dynamic>>> _render;

	static Map<String, Map<String, dynamic>> get hubs => new Map.from(_hubs);
	static Map<String, Map<String, dynamic>> get streets => new Map.from(_streets);

	/// Load from JSON
	static void load() {
		try {
			// Find mapdata directory
			String parent = path.joinAll([serverDir.path, 'lib', 'common', 'mapdata', 'json']);

			// Load hubs
			File hubdata = new File(path.join(parent, 'hubdata.json'));
			_hubs = JSON.decode(hubdata.readAsStringSync());

			// Load streets
			File streetdata = new File(path.join(parent, 'streetdata.json'));
			_streets = JSON.decode(streetdata.readAsStringSync());

			// Load map positions
			File renderdata = new File(path.join(parent, 'renderdata.json'));
			_render = JSON.decode(renderdata.readAsStringSync());

			// Compile into API data
			MapdataEndpoint.init(_hubs, _streets, _render);
		} catch (e, st) {
			Log.error('Error loading map data', e, st);
			throw e;
		}
	}

	/// Find a street map by tsid (either G or L form)
	static Map<String, dynamic> getStreetByTsid(String tsid) {
		Map<String, dynamic> street = null;
		_streets.forEach((String label, Map<String, dynamic> data) {
			if (street == null && data["tsid"] != null && tsidL(data["tsid"]) == tsidL(tsid)) {
				street = data..addAll({"label": label});
			}
		});
		return street ?? getStreetFile(tsid);
	}

	/// Find a street map by label
	static Map<String, dynamic> getStreetByName(String name) {
		return _streets[name];
	}

	/// List all streets in a hub
	static List<Map<String, dynamic>> getStreetsInHub(String hubId) {
		return _streets.values.where((Map<String, dynamic> street) {
			if (street["hub_id"] == null) {
				return false;
			} else {
				return street["hub_id"] == hubId;
			}
		}).toList();
	}

	/// Get street assets file from CAT422 repo
	static Map<String, dynamic> getStreetFile(String tsid) {
		if (tsid == null) {
			throw new ArgumentError('TSID cannot be null if you expect me to find a street file');
		}

		tsid = tsidG(tsid);
		Map<String, dynamic> streetData = {};

		// Find street JSON file
		Directory locations = new Directory(path.join(serverDir.path, 'CAT422', 'locations'));
		File streetFile = new File(path.join(locations.path, '$tsid.json'));

		// Read street JSON file
		if (streetFile.existsSync()) {
			streetData = JSON.decode(streetFile.readAsStringSync());
		} else {
			Log.warning('Street <tsidG=$tsid> not found in CAT422 files');
		}

		return streetData;
	}
}
