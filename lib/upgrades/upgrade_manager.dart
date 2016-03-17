library upgrades;

import 'dart:io';
import 'dart:convert';
import 'dart:async';

import 'package:coUserver/common/util.dart';

import 'package:redstone_mapper/mapper.dart';
import 'package:path/path.dart' as path;

part 'upgrade.dart';

class UpgradeManager {
	static Map<String, Upgrade> _upgrades;
	static Map<String, Upgrade> get upgrades => _upgrades;

	static List<Upgrade> get upgradesList => _upgrades.values;

	static Future loadUpgrades() async {
		try {
			// Find the upgrades file
			String directory = Platform.script.toFilePath();
			directory = directory.substring(0, directory.lastIndexOf(Platform.pathSeparator));
			File upgradesFile = new File(path.join(directory, 'lib', 'upgrades', 'upgrades.json'));

			// Read the file
			List<Upgrade> upgrades = decode(JSON.decode(await upgradesFile.readAsString()), Upgrade);

			// Clear old upgrades data, then save the new
			_upgrades = new Map();
			upgrades.forEach((Upgrade upgrade) => _upgrades[upgrade.id] = upgrade);
		} catch (e) {
			log("Problem loading upgrades: $e");
		}
	}
}