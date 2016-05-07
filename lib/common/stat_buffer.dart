library stat_buffer;

import 'dart:async';
import 'dart:io';
import 'dart:convert';

import 'package:redstone/redstone.dart' as app;

//I'm not sure writing directly to a file everytime something changes would be very
//efficient so this will serve as a buffer and be written out to a file every x seconds
class StatBuffer
{
	static Map<String,num> statMap = {};

	static void resetStatMap()
	{
		statMap = {};
	}

	static void incrementStat(String name, [num amount = 1])
	{
		if(statMap.containsKey(name))
			statMap[name] += amount;
		else
			statMap[name] = amount;
	}

	static Future writeStatsToFile()
	{
		File statsFile = new File("./stats.json");
		Map<String,num> existingStats;
		if(!statsFile.existsSync())
		{
			statsFile.createSync();
			existingStats = {};
		}
		else
			existingStats = JSON.decode(statsFile.readAsStringSync());

		statMap.forEach((String key, num value)
		{
			if(existingStats.containsKey(key))
				existingStats[key] += value;
			else
				existingStats[key] = value;
		});

		resetStatMap();
		return statsFile.writeAsString(JSON.encode(existingStats));
	}
}

@app.Route("/getGameStats")
Future<Map<String,num>> getGameStats()
{
	Completer c = new Completer();
	File statsFile = new File('./stats.json');

	if(!statsFile.existsSync())
		c.complete({});
	else
	{
		try
		{
			statsFile.readAsString().then((String result)
			{
				Map<String,num> existingStats = JSON.decode(result);
				StatBuffer.statMap.forEach((String key, num value)
	    		{
	    			if(existingStats.containsKey(key))
	    				existingStats[key] += value;
	    			else
	    				existingStats[key] = value;
	    		});
				c.complete(existingStats);
			});
		}
		catch(e){c.complete({});}
	}

	return c.future;
}