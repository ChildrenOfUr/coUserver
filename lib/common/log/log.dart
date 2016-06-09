library log;

import 'dart:convert';
import 'dart:io';

import 'package:path/path.dart' as path;

import 'package:coUserver/common/util.dart';

part 'settings.dart';

enum LogLevel {
	ALL, VERBOSE, INFO, COMMAND, WARNING, ERROR, NONE
}

abstract class Log {
	// Configuration
	static void init() {
		LogSettings.setDefault('printLevel', LogLevel.ALL);
		LogSettings.setDefault('printErrors', true);
		LogSettings.setDefault('printStackTraces', true);
		LogSettings.setDefault('printLinesBetween', 0);
	}

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
		LogLevel level: LogLevel.INFO, dynamic error, StackTrace stackTrace
	}) {
		assert(error == null || error is Error || error is Exception);
		String time = new DateTime.now().toString().padRight(26, '0');
		String message = '[${levelString(level)} ($time)] $object';

		// Print errors?
		if (LogSettings.getBool('printErrors') && error != null) {
			message += '\n$error';
		}

		// Print stack traces?
		if (LogSettings.getBool('printStackTraces') && stackTrace != null) {
			message += '\n$stackTrace';
		}

		message = message.trimRight();

		// Print to console if it fits the log level
		if (levelValue(level) >= levelValue(LogSettings.getLogLevel('printLevel'))) {
			print(message + _getBlankLines(LogSettings.getInt('printLinesBetween')));
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

	static String warning(dynamic object, [dynamic error]) {
		return log(object, level: LogLevel.WARNING, error: error);
	}

	static String error(dynamic object, dynamic error, StackTrace stackTrace) {
		return log(object, level: LogLevel.ERROR, error: error, stackTrace: stackTrace);
	}

	static String _getBlankLines(int count) {
		StringBuffer lines = new StringBuffer();
		for (int i = 0; i < count; i++) {
			lines.writeln();
		}
		return lines.toString();
	}
}
