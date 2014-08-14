part of coUserver;

Map getStreetEntities(String tsid)
{
	if(tsid == null)
		return null;
	
	if(tsid.startsWith("G"))
		tsid = tsid.replaceFirst("G", "L");
	Map entities = null;
	File file = new File('./streetEntities/$tsid');
	if(file.existsSync())
		entities = JSON.decode(file.readAsStringSync());
	
	return entities;
}
saveStreetData(Map params)
{
	String tsid = params['tsid'];
	if(tsid.startsWith("G"))
		tsid = tsid.replaceFirst("G", "L");
	
	List entities = JSON.decode(params['entities']);
	File file = new File('./streetEntities/$tsid');
	if(file.existsSync())
	{
		Map oldFile = JSON.decode(file.readAsStringSync());
		//backup the older file and replace it with this new file
    	File backup = new File('./streetEntities/$tsid.bak');
    	if(backup.existsSync())
    	{
    		Map oldData = JSON.decode(backup.readAsStringSync());
    		List backups = oldData['backups'];
    		backups.add({new DateTime.now().toIso8601String():oldFile});
    		backup.writeAsStringSync(JSON.encode({'backups':backups}));
    	}
    	else
    	{
    		backup.createSync(recursive:true);
	    	Map oldData = {'backups':[{new DateTime.now().toIso8601String():oldFile}]};
	    	backup.writeAsStringSync(JSON.encode(oldData));
    	}
    }
	else
		file.createSync(recursive:true);
	
	file.writeAsStringSync(JSON.encode({'entities':entities}));
	
	
	//save a list of finished and partially finished streets
	File finished = new File('./streetEntities/finished.json');
	if(!finished.existsSync())
	{
		finished.createSync(recursive:true);
		//insert any streets that were finished before this file was created
		finished.writeAsStringSync(JSON.encode({}));
	}
	Map finishedMap = JSON.decode(finished.readAsStringSync());
	int required = params['required'];
	int complete = params['complete'];
	bool streetFinished = (required-complete == 0) ? true : false;
	finishedMap[tsid] = {"entitiesRequired":params['required'],
	                     "entitiesComplete":params['complete'],
	                     "streetFinished":streetFinished};
	finished.writeAsStringSync(JSON.encode(finishedMap));
}

String getTsidOfUnfilledStreet()
{
	String tsid = null;
	
	File file = new File('./web/streets.json');
	File finished = new File('./streetEntities/finished.json');
	Map streets = JSON.decode(file.readAsStringSync());
	Map finishedMap = JSON.decode(finished.readAsStringSync());
	
	//loop through streets to find one that is not finished
	//if they are all finished, take one that is not complete
	String incomplete = null;
	for(String t in streets.keys)
	{
		if(!finishedMap.containsKey(t))
		{
			tsid = t;
			break;
		}
		else if(!finishedMap[t]['streetFinished'])
			incomplete = t;
	}
	
	//tsid may still be null after this
	if(tsid == null)
		tsid = incomplete;
	
	return tsid;
}

/**
 * Taken from https://stackoverflow.com/questions/20207855/in-dart-given-a-type-name-how-do-you-get-the-type-class-itself/20450672#20450672
 * 
 * This method will return a ClassMirror for a class whose name 
 * exactly matches the string provided.
 * 
 * In the event that a class matching that name does not exist, it will throw
 * an ArgumentError
 **/
ClassMirror findClassMirror(String name) 
{
	for (LibraryMirror lib in currentMirrorSystem().libraries.values) 
	{
        DeclarationMirror mirror = lib.declarations[MirrorSystem.getSymbol(name)];
        if (mirror != null)
        	return mirror;
  	}
  	throw new ArgumentError("Class $name does not exist");
}

String createId(num x, num y, String type, String tsid)
{
	return (type+x.toString()+y.toString()+tsid).hashCode.toString();
}

/**
 * 
 * Log a message out to the console (and possibly a log file through redirection)
 * 
 **/
void log(String message)
{
	print("(${new DateTime.now().toString()}) $message");
}