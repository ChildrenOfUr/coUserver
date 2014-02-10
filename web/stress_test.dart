part of coUserver;

class StressTest
{
	StressTest(HttpRequest request)
	{
		getResults(request);
	}
	
	getResults(HttpRequest request)
	{
		int numPackets = 0;
		List<WebSocket> sockets = new List();
		for(int i=0; i<100; i++)
		{
			WebSocket.connect("ws://couserver.herokuapp.com/playerUpdate").then((WebSocket socket)
			{
				sockets.add(socket);
				new Timer.periodic(new Duration(milliseconds: 17), (Timer timer)
				{
					Map map = new Map();
					map["test"] = "test";
					socket.add(JSON.encode(map));
					numPackets++;
				});
			});
		}
		new Timer.periodic(new Duration(seconds:5), (Timer timer)
		{
			timer.cancel();
			sockets.forEach((WebSocket socket) => socket.close());
			request.response.write("no errors. sent $numPackets packets");
			request.response.close();
		});
	}
}