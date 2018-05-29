library map_data;

import 'dart:async';
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
	static Future load() async {
		Future _loadHubs(String parent) async {
			File hubdata = new File(path.join(parent, 'hubdata.json'));
			_hubs = jsonDecode(await hubdata.readAsString());
			Log.verbose('[MapData] Loaded ${_hubs.length} hub files');
		}

		Future _loadStreets(String parent) async {
			File streetdata = new File(path.join(parent, 'streetdata.json'));
			_streets = jsonDecode(await streetdata.readAsString());
			Log.verbose('[MapData] Loaded ${_streets.length} street files');
		}

		Future _loadRender(String parent) async {
			File renderdata = new File(path.join(parent, 'renderdata.json'));
			_render = jsonDecode(await renderdata.readAsString());
			Log.verbose('[MapData] Loaded ${_render.length} hub render files');
		}

		try {
			// Find mapdata directory
			String parent = path.joinAll([serverDir.path, 'lib', 'common', 'mapdata', 'json']);

			// Wait for all loads to complete
			await Future.wait([
				_loadHubs(parent),
				_loadStreets(parent),
				_loadRender(parent)
			], eagerError: true);

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
	static List<Map<String, dynamic>> getStreetsInHub(dynamic hubId) {
		return _streets.values.where((Map<String, dynamic> street) {
			if (street["hub_id"] == null) {
				return false;
			} else {
				return street["hub_id"].toString() == hubId.toString();
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
			streetData = jsonDecode(streetFile.readAsStringSync());
		} else {
			Log.warning('Street <tsidG=$tsid> not found in CAT422 files');
		}

		return streetData;
	}

	/// Whether a street is in the savanna
	static bool isSavannaStreet(String streetName) {
		try {
			Map<String, dynamic> street = getStreetByName(streetName);
			assert(street != null);
			Map<String, dynamic> hub = hubs[street['hub_id'].toString()];
			assert(hub != null && hub['savanna'] != null);
			return hub['savanna'];
		} catch (_) {
			return false;
		}
	}

	/// Get the "nearest" non-savanna street
	static String savannaEscapeTo(String currentStreetName) {
		final Map<String, String> HUB_TO_TSID = {
			'86': 'LIF18V95I972R96', // Baqala to Tamila
			'90': 'LIFF6BQE33H26JC', // Choru to Vantalu
			'95': 'LDO8NGHIFTQ21CQ', // Xalanga to Folivoria
			'91': 'LHF4QVGL7NI269C', // Zhambu to Tahli
		};

		try {
			String currentTsid = getStreetByName(currentStreetName)['tsid'];
			assert(currentTsid != null);

			String hubId = getStreetByTsid(currentTsid)['hub_id'].toString();
			assert(hubId != 'null');
			assert(HUB_TO_TSID[hubId] != null);
			return HUB_TO_TSID[hubId];
		} catch (_) {
			return 'LIF12PMQ5121D68'; // Default to Cebarkul
		}
	}

	/// Whether a street is hidden
	static bool streetIsHidden(String streetName) {
		Map<String, dynamic> streetData;

		try {
			streetData = streets[streetName];

			// We don't have this street built
			if (streetData['in_game'] == false) {
				return true;
			}
		} catch(_) {
			// Street not found at all
			return true;
		}

		try {
			// Street is hidden
			if (streetData['map_hidden'] == true) {
				return true;
			}

			// Hub is hidden
			if (MapData.hubs[streetData['hub_id'].toString()]['map_hidden'] == true) {
				return true;
			}

			return false;
		} catch (_) {
			// Missing data, assume it's a normal street
			return false;
		}
	}
}
