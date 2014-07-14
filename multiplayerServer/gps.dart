part of coUserver;

List<String> findRoute(String startTsid, String endTsid)
{
	List<String> path = [];
	List<String> visitedNodes = [];
	List<String> stack = [];
	Map<String,String> parentMap = {};
	
	http.get('http://RobertMcDermot.github.io/CAT422-glitch-location-viewer/locations/$startTsid.json')
		.then((response)
		{
			Map _data = JSON.decode(response.body);
			for(Map layer in new Map.from(_data['dynamic']['layers']).values)
			{
				for (Map signpost in layer['signposts'])
				{
					List signposts = signpost['connects'] as List;
					for(Map<String,String> exit in signposts)
					{
						String tsid = exit['tsid'];
						parentMap[tsid] = _data['tsid'].replaceFirst("G","L");
					}
				}
			}
		});
	
	return path;
}