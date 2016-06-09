part of log;

abstract class LogSettings {
	/// Get the value of a setting as a String
	static String getString(String setting, {String fallback}) {
		return getSetting(setting, type: String, fallback: fallback);
	}

	/// Get the value of a setting as a bool
	static bool getBool(String setting, {bool fallback}) {
		return getSetting(setting, type: bool, fallback: fallback);
	}

	/// Get the value of a setting as an int
	static int getInt(String setting, {int fallback}) {
		return getSetting(setting, type: int, fallback: fallback);
	}

	/// Get the value of a setting as a LogLevel
	static LogLevel getLogLevel(String setting, {LogLevel fallback}) {
		return getSetting(setting, type: LogLevel, fallback: fallback);
	}

	/// Get the value of any type of setting
	static dynamic getSetting(String setting, {Type type: String, dynamic fallback}) {
		String value = _cache[setting] ?? _settings[setting];

		if (type == String) {
			if (value != null) {
				return value;
			} else {
				return fallback;
			}
		} else if (type == int) {
			try {
				return int.parse(value);
			} catch (_) {
				return fallback;
			}
		} else if (type == bool) {
			if (value == 'true') {
				return true;
			} else if (value == 'false') {
				return false;
			} else {
				return fallback;
			}
		} else if (type == LogLevel) {
			try {
				return LogLevel.values.singleWhere((LogLevel level) => level.toString() == value);
			} catch (_) {
				return fallback;
			}
		} else {
			throw new ArgumentError('Cannot parse setting to unsupported type $type');
		}
	}

	/// Initialize or change a setting
	static void setSetting(String setting, dynamic value) {
		if (value != null) {
			// Add or change setting
			_cache[setting] = value;
			_settings = new Map.from(_settings)
				..[setting] = value.toString();
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
			if (json == '') {
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
