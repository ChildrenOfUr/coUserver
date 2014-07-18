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
}

getMapFillerData(HttpRequest request)
{
	Map data = request.uri.queryParameters;	
	String tsid = data['tsid'];
	http.get('http://glitchthegame.com/locations/$tsid').then((response)
	{
		Map map = {'tsid':tsid};
		
		//get map preview url
		RegExp regEx = new RegExp(r'class="location-img".+background-image: url\((.+)\)');
		map['previewUrl'] = regEx.firstMatch(response.body).group(1);
		
		//get map region
		regEx = new RegExp(r'Region:.+>(.+)<\/a>');
		map['region'] = regEx.firstMatch(response.body).group(1);
		
		//get map features, if available
		regEx = new RegExp(r'(\d) (.+?(Tree|Plant|Patch|Bog|Growth))s*');
		regEx.allMatches(response.body).forEach((Match match)
		{
			map[match.group(2)] = match.group(1);
		});
		
		//check for firefly swarms - can't have more than 1?
		regEx = new RegExp(r'A Firefly Swarm');
		if(regEx.hasMatch(response.body))
			map['Firefly Swarm'] = 1;
				
		request.response
			..headers.add('Access-Control-Allow-Origin', '*')
			..headers.add('Content-Type', 'application/json')
			..write(JSON.encode(map))..close();
	});
}