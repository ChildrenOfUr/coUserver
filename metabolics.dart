part of coUserver;

class Metabolics
{
	@Field()
	int id;

	@Field()
	int mood = 50;

	@Field()
	int max_mood = 100;

	@Field()
	int energy = 50;

	@Field()
	int max_energy = 100;

	@Field()
	int currants = 0;

	@Field()
	int img = 0;

	@Field()
	int lifetime_img = 0;

	@Field()
	String current_street = 'LA58KK7B9O522PC';

	@Field()
	num current_street_x = 1.0;

	@Field()
	num current_street_y = 0.0;

	@Field()
	int user_id = -1;
}

class MetabolicsEndpoint
{
	static bool simulateMood = false, simulateEnergy = false;
	static Timer moodTimer = new Timer.periodic(new Duration(seconds: 60), (Timer timer) => simulateMood = true);
	static Timer energyTimer = new Timer.periodic(new Duration(seconds: 90), (Timer timer) => simulateEnergy = true);
    static Timer simulateTimer = new Timer.periodic(new Duration(seconds: 5), (Timer timer) => simulate());
	static Map<String,WebSocket> userSockets = {};
	static Random rand = new Random();

	static void handle(WebSocket ws)
	{
		moodTimer.isActive; energyTimer.isActive; simulateTimer.isActive;

		ws.listen((message) => processMessage(ws,message),
		onError: (error) => cleanupList(ws),
		onDone: () => cleanupList(ws));
	}

	static void cleanupList(WebSocket ws)
	{
		String leavingUser;

		userSockets.forEach((String username, WebSocket socket)
		{
			if(ws == socket)
			{
				socket = null;
				leavingUser = username;
			}
		});

		userSockets.remove(leavingUser);
	}

	static void processMessage(WebSocket ws, String message)
	{
		Map map = JSON.decode(message);
		String username = map['username'];

		if(!userSockets.containsKey(username))
			userSockets[username] = ws;
	}

	static void simulate()
	{
		userSockets.forEach((String username, WebSocket ws) async
		{
			Metabolics m = await getMetabolics(username:username);

			if(simulateMood)
			{
				int max_mood = m.max_mood;
				num moodRatio = m.mood/max_mood;

				//determine how much mood they should lose based on current percentage of max
				//https://web.archive.org/web/20130106191352/http://www.glitch-strategy.com/wiki/Mood
				if(moodRatio < .5)
					m.mood -= (max_mood*.005).ceil();
				else if(moodRatio >= .5 && moodRatio < .81)
					m.mood -= (max_mood*.01).ceil();
				else
					m.mood -= (max_mood*.015).ceil();

				simulateMood = false;
			}
			if(simulateEnergy)
			{
				int energy = m.energy;
    			int max_energy = m.max_energy;

    			//players lose .8% of their max energy every 90 seconds
    			//https://web.archive.org/web/20120805062536/http://www.glitch-strategy.com/wiki/Energy
    			m.energy -= (max_energy*.008).ceil();

    			simulateEnergy = false;
			}

			//store current street and position
			Identifier userIdentifier = PlayerUpdateHandler.users[username];
			m.current_street = userIdentifier.tsid;
			m.current_street_x = userIdentifier.currentX;
			m.current_street_y = userIdentifier.currentY;

			//store the metabolics back to the database
			int result = await setMetabolics(m);
			if(result > 0)
			{
				//send the metabolics back to the user
				ws.add(JSON.encode(encode(m)));
			}
		});
	}

	static addQuoin(Quoin q, String username) async
	{
		int amt = rand.nextInt(4)+1;
		int quoinMultiplier = 1;
		// TODO: change 1 to the real quoin multiplier
		amt = amt * quoinMultiplier;

		if(q.type == "quarazy")
			amt *= 7;

		Metabolics m = await getMetabolics(username:username);

		if(q.type == 'currant')
			m.currants += amt;
		if(q.type == 'img' || q.type == 'quarazy')
		{
			m.img += amt;
			m.lifetime_img += amt;
		}
		if(q.type == 'mood')
			m.mood += amt;
		if(q.type == 'energy')
			m.energy += amt;

		int result = await setMetabolics(m);
		if(result > 0)
		{
			Map map = {'collectQuoin':'true',
			           'id':q.id,
			           'amt':amt,
			           'quoinType':q.type};

			q.setCollected();

			userSockets[username].add(JSON.encode(map));
			userSockets[username].add(JSON.encode(encode(m)));
		}
	}
}

@app.Route('/getMetabolics')
@Encode()
Future<Metabolics> getMetabolics({@app.QueryParam() String username, String email}) async
{
	PostgreSql dbConn = await dbManager.getConnection();

	String whereClause = "WHERE users.username = @username";
	if(email != null)
		whereClause = "WHERE users.email = @email";
	String query = "SELECT * FROM metabolics JOIN users ON users.id = metabolics.user_id " + whereClause;
	List<Metabolics> metabolics = await dbConn.query(query, Metabolics, {'username':username,'email':email});

	Metabolics metabolic;

	if(metabolics.length > 0)
		metabolic = metabolics[0];
	else
	{
		query = "SELECT * FROM users " + whereClause;
		var results = await dbConn.query(query, int, {'username':username,'email':email});

		metabolic = new Metabolics();
		if(results.length > 0)
			metabolic.user_id=results[0]['id'];
	}

	dbManager.closeConnection(dbConn);
	return metabolic;
}

@app.Route('/setMetabolics', methods:const[app.POST])
Future<int> setMetabolics(@Decode() Metabolics metabolics) async
{
	PostgreSql dbConn = await dbManager.getConnection();

	//if the user already exists, update their data, otherwise insert them
	String query = "SELECT user_id FROM metabolics WHERE user_id = @user_id";
	List<int> results = await dbConn.query(query, int, metabolics);

	if(results.length > 0) //user exists
		query = "UPDATE metabolics SET img = @img, currants = @currants, mood = @mood, energy = @energy, lifetime_img = @lifetime_img, current_street = @current_street, current_street_x = @current_street_x, current_street_y = @current_street_y, max_energy = @max_energy, max_mood = @max_mood WHERE user_id = @user_id";
	else //user does not exist
		query = "INSERT INTO metabolics (img,currants,mood,energy,lifetime_img,user_id,current_street,current_street_x,current_street_y,max_energy,max_mood) VALUES(@img,@currants,@mood,@energy,@lifetime_img,@user_id,@current_street,@current_street_x,@current_street_y,@max_energy,@max_mood);";

	int result = await dbConn.execute(query,metabolics);
	dbManager.closeConnection(dbConn);
	return result;
}