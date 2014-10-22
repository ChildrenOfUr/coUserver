part of coUserver;

@app.Group('/auth')
class AuthService
{
	@app.Route('/login', methods: const[app.POST])
    Future<Map> loginUser(@app.Body(app.JSON) Map parameters)
    {
		print("got request: $parameters");
		Random rand = new Random();
    	Completer c = new Completer();

    	String audience = 'http://play.childrenofur.com:80';
    	if(parameters['testing'] != null)
    		audience = 'http://localhost:8080';

    	Map body = {'assertion':parameters['assertion'],
    				'audience':audience};

    	http.post('https://verifier.login.persona.org/verify',body:body).then((response)
		{
			Map responseMap = JSON.decode(response.body);
			print('responseMap: $responseMap');
			if(responseMap['status'] == 'okay')
				c.complete({'ok':'yes',
							'playerName':'testUser${rand.nextInt(1000000)}',
							'playerStreet':'LA58KK7B9O522PC'});
			else
				c.complete({'ok':'no'});
		});

    	return c.future;
    }

	@app.Route('/logout', methods: const[app.POST])
    Map logoutUser(@app.Body(app.JSON) Map parameters)
    {
		//does nothing at the moment
		//should remove any session key associated with parameters['session-key']

		return {'ok':'yes'};
    }
}