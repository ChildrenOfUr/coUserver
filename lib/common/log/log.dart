library log;

import 'dart:convert';
import 'dart:io';

import 'package:path/path.dart' as path;

import 'package:coUserver/common/util.dart';

part 'colors.dart';
part 'settings.dart';

enum LogLevel {
	ALL, DEBUG, VERBOSE, INFO, COMMAND, WARNING, ERROR, NONE
}

abstract class Log {
	/// Default Configuration
	static void init() {
		LogSettings.setDefault('colors', false);
		LogSettings.setDefault('errors', true);
		LogSettings.setDefault('level', LogLevel.ALL);
		LogSettings.setDefault('skipLines', 0);
		LogSettings.setDefault('stackTraces', true);
	}

	/// Convert LogLevel to String
	static String levelString(LogLevel level, [bool pad = true]) {
		String levelStr = level.toString().split('.')[1];
		return levelStr.padRight(7); // Match longest level string length
	}

	/// Convert LogLevel to int
	static int levelValue(LogLevel level) => {
		LogLevel.ALL: 0,
		LogLevel.DEBUG: 50,
		LogLevel.VERBOSE: 100,
		LogLevel.INFO: 200,
		LogLevel.COMMAND: 300,
		LogLevel.WARNING: 400,
		LogLevel.ERROR: 500,
		LogLevel.NONE: 1000
	}[level] ?? 0;

	/// Log a message to the console
	static String log(dynamic object, {
		LogLevel level: LogLevel.INFO, dynamic error, StackTrace stackTrace
	}) {
		assert(error == null || error is Error || error is Exception);

		// Timestamp
		String time = new DateTime.now().toString().padRight(26, '0');

		// Message format
		String message = '[${levelString(level)} ($time)] $object';

		// Print error if enabled and applicable
		if (LogSettings.getBool('errors') && error != null) {
			message += '\n$error';
		}

		// Print stack traces if enabled and applicable
		if (LogSettings.getBool('stackTraces') && stackTrace != null) {
			message += '\n$stackTrace';
		}

		// Remove trailing whitespace (from errors and stack traces)
		message = message.trimRight();

		// Apply colors if enabled
		if (LogSettings.getBool('colors')) {
			message = AnsiColors.color(message, AnsiColors.getColor(level));
		}

		// Print to console if we are logging this level
		if (levelValue(level) >= levelValue(LogSettings.getLogLevel('level'))) {
			print(message + _getBlankLines(LogSettings.getInt('skipLines')));
		}

		// Return formatted string
		return message;
	}

	/// Log only if testing
	static String debug(dynamic object, [dynamic error, StackTrace stackTrace]) {
		return log(object, level: LogLevel.DEBUG, error: error, stackTrace: stackTrace);
	}

	/// Log spam or a fine status message to the console
	static String verbose(dynamic object) {
		return log(object, level: LogLevel.VERBOSE);
	}

	/// Log an information message to the console
	static String info(dynamic object) {
		return log(object, level: LogLevel.INFO);
	}

	/// Log [Command] output to the console
	static String command(dynamic object) {
		return log(object, level: LogLevel.COMMAND);
	}

	/// Log a warning and maybe an [Error] or [Exception] object to the console
	static String warning(dynamic object, [dynamic error]) {
		return log(object, level: LogLevel.WARNING, error: error);
	}

	/// Log an error message, maybe an [Error] or [Exception] object, and maybe a [StackTrace] to the console
	static String error(dynamic object, [dynamic error, StackTrace stackTrace]) {
		return log(object, level: LogLevel.ERROR, error: error, stackTrace: stackTrace);
	}

	/// Make a string consisting of `count` blank lines
	static String _getBlankLines(int count) {
		StringBuffer lines = new StringBuffer();
		for (int i = 0; i < count; i++) {
			lines.writeln();
		}
		return lines.toString();
	}
}
