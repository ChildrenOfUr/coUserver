part of coUserver;

class UpgradeManager {
	static Map<String, Upgrade> _upgrades;
	static Map<String, Upgrade> get upgrades => _upgrades;

	static List<Upgrade> get upgradesList => _upgrades.values;

	static Future loadUpgrades() async {
		try {
			// Find the upgrades file
			String directory = Platform.script.toFilePath();
			directory = directory.substring(0, directory.lastIndexOf(Platform.pathSeparator));
			File upgradesFile = new File(path.join(directory, 'gameServer', 'upgrades', 'upgrades.json'));

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