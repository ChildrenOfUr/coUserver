part of util;

class FileCache {
	static final Duration INTERVAL = new Duration(seconds: 30);

	static Map<String, int> heightsCache;
	static Map<String, String> headsCache;

	static Future loadCaches() async {
		// Make trees speech bubbles appear where they should
		heightsCache = await loadCacheFromDisk('heightsCache.json');
		headsCache = await loadCacheFromDisk('headsCache.json');

		// Save the cache to the disk
		new Timer.periodic(INTERVAL, (_) async {
			try {
				await saveCacheToDisk('headsCache.json', headsCache);
			} catch (e, st) {
				Log.error('Problem writing headsCache.json', e, st);
			}

			try {
				await saveCacheToDisk('heightsCache.json', heightsCache);
			} catch (e, st) {
				Log.error('Problem writing heightsCache.json', e, st);
			}
		});

		Log.verbose('[FileCache] Caches loaded');
	}

	static Future<Map> loadCacheFromDisk(String filename) async {
		File file = new File(filename);
		if (!(await file.exists())) {
			return new Map();
		}

		try {
			return JSON.decode(await file.readAsString());
		} catch (e, st) {
			// The file is corrupted, reset it during the next write
			Log.error('Could not load cache $filename', e, st);
			return new Map();
		}
	}

	static Future saveCacheToDisk(String filename, Map cache) async {
		File file = new File(filename);
		if (!(await file.exists())) {
			await file.create(recursive: true);
		}

		try {
			await file.writeAsString(JSON.encode(cache), flush: true);
		} catch (e, st) {
			// Filesystem error
			Log.error('Could not save $cache to $filename', e, st);
		}
	}
}
