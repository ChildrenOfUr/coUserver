// Used for more verbose logging from redstone
/*
// Open a file for writing logs to
File logFile = new File('redstone_log_file');
if (!(await logFile.exists())) {
	await logFile.create();
}

IOSink sink = logFile.openWrite(mode: FileMode.APPEND);
sink.writeln('\n=====================================');
sink.writeln("Server started at ${new DateTime.now()}");
sink.writeln('=====================================\n');

// Write all messages to the iosink
Logger.root.level = Level.ALL;
Logger.root.onRecord.listen((LogRecord rec) {
	sink.writeln(rec);
});
*/
