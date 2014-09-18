part of coUserver;

abstract class Entity
{
	List<Map> actions;
	String bubbleText;
	DateTime sayTimeout = null;
	Map<String,List<String>> responses = {'harvest':[''],'water':[''],'pet':['']};
	Random rand = new Random();

	void setActionEnabled(String action, bool enabled)
	{
		try
		{
			for(Map actionMap in actions)
			{
				if(actionMap['action'] == action)
				{
					actionMap['enabled'] = enabled;
					return;
				}
			}
		}
		catch(e){log("error enabling/disabling action $action: $e");}
	}

	Map getMap()
	{
		Map map = {};
		if(bubbleText != null)
			map['bubbleText'] = bubbleText;
		return map;
	}

	void say(String message)
	{
		if(message == null || message.trim() == '')
			return;

		DateTime now = new DateTime.now();
		if(sayTimeout == null || sayTimeout.compareTo(now) < 0)
		{
			bubbleText = message;
			int timeToLive = message.length * 30 + 3000; //minimum 3s plus 0.3s per character
    		if(timeToLive > 10000) //max 10s
    			timeToLive = 10000; //messages over 10s will only display for 10s

    		Duration messageDuration = new Duration(milliseconds:timeToLive);
    		sayTimeout = now.add(messageDuration);
    		new Timer(messageDuration,() => bubbleText = null);
		}
	}
}