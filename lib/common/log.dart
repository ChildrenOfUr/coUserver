library logging;

enum LogLevel {
	ALL, VERBOSE, INFO, COMMAND, WARNING, ERROR, NONE
}

abstract class Log {
	// Configuration
	static LogLevel printLevel = LogLevel.ALL;
	static bool printErrors = true;
	static bool printStackTraces = true;
	static bool printLinesBetween = false;

	static String levelString(LogLevel level, [bool pad = true]) {
		String levelStr = level.toString().split('.')[1];
		return levelStr.padRight(7); // Match longest level string length
	}

	static int levelValue(LogLevel level) => {
		LogLevel.ALL: 0,
		LogLevel.VERBOSE: 100,
		LogLevel.INFO: 200,
		LogLevel.COMMAND: 300,
		LogLevel.WARNING: 400,
		LogLevel.ERROR: 500,
		LogLevel.NONE: 1000
	}[level] ?? 0;

	static String log(dynamic object, {
		LogLevel level: LogLevel.INFO, Error error, StackTrace stackTrace
	}) {
		String time = new DateTime.now().toString();
		String message = '[${levelString(level)} ($time)] $object';

		// Print errors?
		if (printErrors && error != null) {
			message += '\n$error';
		}

		// Print stack traces?
		if (printStackTraces && stackTrace != null) {
			message += '\n$stackTrace';
		}

		message = message.trimRight();

		// Print to console if it fits the log level
		if (levelValue(level) >= levelValue(printLevel)) {
			print(message + (printLinesBetween ? '\n' : ''));
		}

		return message;
	}

	static String verbose(dynamic object) {
		return log(object, level: LogLevel.VERBOSE);
	}

	static String info(dynamic object) {
		return log(object, level: LogLevel.INFO);
	}

	static String command(dynamic object) {
		return log(object, level: LogLevel.COMMAND);
	}

	static String warning(dynamic object, [Error error]) {
		return log(object, level: LogLevel.WARNING, error: error);
	}

	static String error(dynamic object, Error error, StackTrace stackTrace) {
		return log(object, level: LogLevel.ERROR, error: error, stackTrace: stackTrace);
	}
}
