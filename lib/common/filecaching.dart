part of util;

class FileCache {
	static final Duration INTERVAL = new Duration(seconds: 30);

	static Map<String, int> heightsCache;
	static Map<String, String> headsCache;

	static void loadCaches() {
		// Make trees speech bubbles appear where they should
		heightsCache = loadCacheFromDisk('heightsCache.json');
		headsCache = loadCacheFromDisk('headsCache.json');

		// Save the cache to the disk
		new Timer.periodic(INTERVAL, (_) {
			try {
				saveCacheToDisk('headsCache.json', headsCache);
			} catch (e) {
				log('Problem writing headsCache.json: $e');
			}

			try {
				saveCacheToDisk('heightsCache.json', heightsCache);
			} catch (e) {
				log('Problem writing heightsCache.json: $e');
			}
		});
	}

	static Map loadCacheFromDisk(String filename) {
		File file = new File(filename);
		if (!file.existsSync()) {
			return new Map();
		}

		try {
			return JSON.decode(file.readAsStringSync());
		} catch (e) {
			// The file is corrupted, reset it during the next write
			log('Could not load cache $filename: $e');
			return new Map();
		}
	}

	static void saveCacheToDisk(String filename, Map cache) {
		File file = new File(filename);
		if (!file.existsSync()) {
			file.createSync(recursive: true);
		}

		try {
			file.writeAsStringSync(JSON.encode(cache), flush: true);
		} catch (e) {
			// Filesystem error
			log('Could not save $cache to $filename: $e');
		}
	}
}
