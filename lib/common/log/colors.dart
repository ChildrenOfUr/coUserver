part of log;

abstract class AnsiColors {
	/// Format the given text in a color
	static String color(String str, String color) {
		return color + str + clear;
	}

	/// Get color by LogLevel
	static String getColor(LogLevel level) => {
		LogLevel.DEBUG: blue,
		LogLevel.VERBOSE: green,
		LogLevel.INFO: cyan,
		LogLevel.COMMAND: purple,
		LogLevel.WARNING: yellow,
		LogLevel.ERROR: red
	}[level] ?? clear;

	/// Reset sequence
	static String get clear => _esc(0);

	static String get blue => _esc(34);

	static String get green => _esc(32);

	static String get cyan => _esc(36);

	static String get purple => _esc(35);

	static String get yellow => _esc(33);

	static String get red => _esc(31);

	/// Escape a color code
	static String _esc(int color) => '\x1B[${color}m';
}
