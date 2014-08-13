part of coUserver;

abstract class Tree extends Plant
{
	int maturity;
	
	Tree(String id, int x, int y) : super(id,x,y)
	{
		actions..add({"action":"harvest",
					  "timeRequired":actionTime,
					  "enabled":true,
					 "actionWord":"harvesting"})
			   ..add({"action":"water",
					  "timeRequired":actionTime,
					  "enabled":true,
					  "actionWord":"watering"})
			   ..add({"action":"pet",
					  "timeRequired":actionTime,
					  "enabled":true,
					  "actionWord":"petting"});
	}
	
	void update()
	{
		super.update();
		
		if(state > 0)
			setActionEnabled("harvest",true);
		else
			setActionEnabled("harvest",false);
	}
	
	harvest({WebSocket userSocket})
	{
		if(state == 0)
			return;
		
		respawn = new DateTime.now().add(new Duration(seconds:30));
		state--;
		
		if(state < 0)
			state = 0;
	}
	
	water({WebSocket userSocket})
	{
		if(state == maxState)
			return;
		
		respawn = new DateTime.now().add(new Duration(seconds:30));
		state++;
		
		if(state > maxState)
			state = maxState;
	}
	
	pet({WebSocket userSocket}) {}
}