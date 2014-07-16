part of coUserver;

getMapFillerData(HttpRequest request)
{
	Map data = request.uri.queryParameters;	
	String tsid = data['tsid'];
	http.get('http://glitchthegame.com/locations/$tsid').then((response)
	{
		Map map = {};
		
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
			..write(map)..close();
	});
}