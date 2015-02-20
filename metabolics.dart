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

@app.Route('/getMetabolics')
@Encode()
Future<Metabolics> getMetabolics(@app.QueryParam() String username)
{
	Completer c = new Completer();

	String query = "SELECT * FROM metabolics JOIN users ON users.id = metabolics.user_id WHERE users.username = @username";
	dbConn.query(query, Metabolics, {'username':username}).then((List<Metabolics> metabolics)
	{
		if(metabolics.length > 0)
			c.complete(metabolics[0]);
		else
		{
			query = "SELECT user_id FROM users WHERE username = @username";
			dbConn.query(query, int, {'username':username}).then((List<int> results)
			{
				Metabolics m = new Metabolics()..user_id=results[0];
				c.complete(m);
			});
		}
	});

	return c.future;
}

@app.Route('/setMetabolics', methods:const[app.POST])
Future<int> setMetabolics(@Decode() Metabolics metabolics)
{
	Completer c = new Completer();

	//if the user already exists, update their data, otherwise insert them
	String query = "SELECT user_id FROM metabolics WHERE user_id = @user_id";
	dbConn.query(query, int, metabolics).then((List<int> results)
	{
		if(results.length > 0) //user exists
			query = "UPDATE metabolics SET img = @img, currants = @currants, mood = @mood, energy = @energy, lifetime_img = @lifetime_img, current_street = @current_street WHERE user_id = @user_id";
		else //user does not exist
			query = "INSERT INTO metabolics (img,currants,mood,energy,lifetime_img,user_id,current_street) VALUES(@img,@currants,@mood,@energy,@lifetime_img,@user_id,@current_street);";

		dbConn.execute(query,metabolics).then((int result) => c.complete(result));
	});

	return c.future;
}