part of coUserver;

abstract class Entity
{
	List<Map> actions;
	
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
}