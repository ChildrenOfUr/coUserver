part of coUserver;

class Mailbox extends NPC {
	Mailbox(String id, int x, int y) : super(id, x, y) {
		actionTime = 0;
		actions
			..add({"action":"check mail",
				      "timeRequired":actionTime,
				      "enabled":true,
				      "actionWord":""})
			..add({"action":"view inbox",
				      "timeRequired":actionTime,
				      "enabled":true,
				      "actionWord":""});

		type = "Mailbox";
		speed = 0;

		states = {
			"add_done":new Spritesheet("all_done", 'http://c2.glitch.bz/items/2012-12-06/npc_mailbox_variant_mailboxLeft_x1_all_done_png_1354832237.png', 776, 438, 97, 146, 22, false),
			"has_mail":new Spritesheet("has_mail", 'http://c2.glitch.bz/items/2012-12-06/npc_mailbox_variant_mailboxLeft_x1_has_mail_png_1354832234.png', 970, 1168, 97, 146, 73, true),
			"interract":new Spritesheet("interract", 'http://c2.glitch.bz/items/2012-12-06/npc_mailbox_variant_mailboxLeft_x1_interact_png_1354832236.png', 873, 146, 97, 146, 9, false),
			"idle":new Spritesheet("idle", 'http://c2.glitch.bz/items/2012-12-06/npc_mailbox_variant_mailboxLeft_x1_idle_png_1354832232.png', 97, 146, 97, 146, 1, false),
			"has_mail_idle":new Spritesheet("has_mail_idle", 'http://c2.glitch.bz/items/2012-12-06/npc_mailbox_variant_mailboxLeft_x1_has_mail_idle_png_1354832235.png', 97, 146, 97, 146, 1, false)
		};
		currentState = states['idle'];
		respawn = new DateTime.now();
	}

	void update() {
		DateTime now = new DateTime.now();
		if(respawn != null && respawn.compareTo(now) < 0) {
			//check for new mail

			//check again in 1 minute
			respawn = now.add(new Duration(minutes:1));
		}
	}

	Future checkMail({WebSocket userSocket, String email}) async {
		String query = "SELECT * FROM messages JOIN users ON username = to_user WHERE email = @email AND read = FALSE";
		PostgreSql dbConn = await dbManager.getConnection();
		List<Message> messages = await dbConn.query(query, Message, {'email':email});
		if(messages.length > 0) {
			say("${messages.length} New Messages");
		}
		else {
			say("No Mail");
		}
		dbManager.closeConnection(dbConn);
	}

	void viewInbox({WebSocket userSocket, String email}) {
		Map map = {};
		map['id'] = id;
		map['openWindow'] = 'mailbox';
		userSocket.add(JSON.encode(map));
	}
}

@app.Route('/getMail', methods: const[app.POST])
@Encode()
Future<List<Message>> getMail(@app.Body(app.JSON) Map parameters) async
{
	String user = parameters['user'];

	String query = "SELECT * FROM messages WHERE to_user = @user";
	List<Message> messages = await dbConn.query(query, Message, {'user':user});

	return messages;
}

@app.Route('/sendMail', methods: const[app.POST])
Future<String> sendMail(@Decode() Message message) async
{
	if(message.currants > 0) {
		Metabolics m = await getMetabolics(username:message.from_user);
		if(m.currants < message.currants) {
			return "Not enough currants";
		} else {
			m.currants -= message.currants;
			setMetabolics(m);
		}
	}

	if(message.subject == null) {
		message.subject = '';
	}
	if(message.body == null) {
		message.body = '';
	}
	try {
		String query = "INSERT INTO messages(to_user, from_user, subject, body, currants) VALUES(@to_user,@from_user,@subject,@body,@currants)";
		int result = await dbConn.execute(query, message);

		if (result > 0) {
			return "OK";
		} else {
			return "Error";
		}
	} catch(err) {
		return "Error";
	}
}

@app.Route('/collectCurrants', methods: const[app.POST])
Future collectCurrants(@Decode() Message message) async {
	//mark the currants as already taken so they can't be taken again
	String query = "UPDATE messages set currants_taken = true where id = @id AND currants_taken = false";
	int result = await dbConn.execute(query, message);

	if(result < 1) {
		return "Error";
	}

	//give the currants to the user
	Metabolics m = await getMetabolics(username:message.to_user);
	m.currants += message.currants;
	setMetabolics(m);
}

@app.Route('/deleteMail', methods: const[app.POST])
Future<String> deleteMail(@app.Body(app.JSON) Map parameters) async
{
	String query = "DELETE FROM messages WHERE id = @id";
	int result = await dbConn.execute(query, {'id':parameters['id']});

	if(result > 0)
		return "OK";
	else
		return "Error";
}

@app.Route('/readMail', methods: const[app.POST])
readMail(@Decode() Message message) async
{
	String query = "UPDATE messages SET read = TRUE WHERE id = @id";
	await dbConn.execute(query, message);
}

class Message {
	@Field()
	int id;
	@Field()
	String to_user;
	@Field()
	String from_user;
	@Field()
	String subject;
	@Field()
	String body;
	@Field()
	bool read;
	@Field()
	int currants;
	@Field()
	bool currants_taken;
}