part of coUserver;

@app.Group('/auth')
class AuthService
{
	@app.Route('/login', methods: const[app.POST])
    Future<Map> loginUser(@app.Body(app.JSON) Map parameters)
    {
		Random rand = new Random();
    	Completer c = new Completer();

    	Map body = {'assertion':parameters['assertion'],
    				'audience':'play.childrenofur.com'};

    	http.post('https://verifier.login.persona.org/verify',body:body).then((response)
		{
			Map responseMap = JSON.decode(response.body);
			if(responseMap['status'] == 'okay')
				c.complete({'ok':'yes',
							'playerName':'testUser ${rand.nextInt(1000000)}',
							'playerStreet':'LA58KK7B9O522PC'});
			else
				c.complete({'ok':'no'});
		});

    	return c.future;
    }
}