part of log;

abstract class LogSettings {
	/// Get the value of a setting as a String
	static String getString(String setting, {String fallback}) => getSetting(setting, fallback);

	/// Get the value of a setting as a bool
	static bool getBool(String setting, {bool fallback}) => getSetting(setting, fallback);

	/// Get the value of a setting as an int
	static int getInt(String setting, {int fallback}) => getSetting(setting, fallback);

	/// Get the value of a setting as a LogLevel
	static LogLevel getLogLevel(String setting, {LogLevel fallback}) {
		try {
			String value = getSetting(setting, fallback);
			return LogLevel.values.singleWhere((LogLevel l) => l.toString() == value);
		} catch (_) {
			return fallback;
		}
	}

	/// Get the value of any type of setting
	static dynamic getSetting(String setting, [dynamic fallback]) {
		return _cache[setting]		// 1. Check cache to reduce filesystem accesses
			?? _settings[setting]	// 2. Read from JSON file
			?? fallback;			// 3. Default to provided fallback
	}

	/// Initialize or change a setting
	static void setSetting(String setting, dynamic value) {
		if (value != null) {
			if (value is String) {
				if (value == 'true') {
					value = true;
				} else if (value == 'false') {
					value = false;
				} else {
					try {
						value = int.parse(value);
					} catch (_) {}
				}
			}

			// Add or change setting
			_cache[setting] = value;
			_settings = new Map.from(_settings)
				..[setting] = (value is LogLevel ? value.toString() : value);
		} else {
			// Clear setting
			_cache.remove(setting);
			_settings = new Map.from(_settings)
				..remove(setting);
		}
	}

	/// Set the setting only if it is not already set
	/// Returns whether it was changed
	static bool setDefault(String setting, dynamic value) {
		if (getSetting(setting) == null) {
			setSetting(setting, value);
			return true;
		} else {
			return false;
		}
	}

	/// Save file accesses
	static Map<String, dynamic> _cache = new Map();

	/// Open config file and decode to JSON
	static Map<String, dynamic> get _settings {
		// Read
		String json;
		try {
			json = _file.readAsStringSync();
			if (json.trim() == '') {
				json = '{}';
			}
		} catch (_) {
			json = '{}';
		}

		// Decode
		return JSON.decode(json);
	}

	/// Encode to JSON and save to the config file
	static void set _settings (Map<String, dynamic> newSettings) {
		// Encode
		String json;
		try {
			json = JSON.encode(newSettings);
		} catch (_) {
			json = '{}';
		}

		// Write
		try {
			if (!_file.existsSync()) {
				_file.createSync();
			}

			_file.writeAsStringSync(json);
		} catch (e, st) {
			Log.error('Log config JSON not written', e, st);
		}
	}

	/// Reference to settings file
	static File get _file {
		Directory parent = new Directory(path.joinAll([serverDir.path, 'lib', 'common', 'log']));
		return new File(path.joinAll([parent.path, 'logsettings.json']));
	}
}
