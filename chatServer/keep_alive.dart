part of coUserver;

class KeepAlive
{		
	start(WebSocket websocket)
	{
		Timer timer;
		timer = new Timer.periodic(new Duration(seconds:50), (_)
		{
			if(websocket.readyState != 1) //not yet ready, closing or closed
				timer.cancel();
			else
			{
				Map pingMap = new Map();
				pingMap["message"] = "ping";
				websocket.add(JSON.encode(pingMap));
			}
		});
	}
}