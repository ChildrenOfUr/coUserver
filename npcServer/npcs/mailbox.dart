part of coUserver;

class Mailbox extends NPC {
	Mailbox(String id, int x, int y) : super(id, x, y) {
		actionTime = 0;
		actions..add({"action":"check mail",
			             "timeRequired":actionTime,
			             "enabled":true,
			             "actionWord":""})..add({"action":"view inbox",
				                                    "timeRequired":actionTime,
				                                    "enabled":true,
				                                    "actionWord":""});

		type = "Mailbox";
		speed = 0;

		states = {
			"add_done":new Spritesheet(
				"all_done",
				'http://childrenofur.com/assets/entityImages/npc_mailbox_variant_mailboxLeft_x1_all_done_png_1354832237.png',
				776,
				438,
				97,
				146,
				22,
				false),
			"has_mail":new Spritesheet(
				"has_mail",
				'http://childrenofur.com/assets/entityImages/npc_mailbox_variant_mailboxLeft_x1_has_mail_png_1354832234.png',
				970,
				1168,
				97,
				146,
				73,
				true),
			"interract":new Spritesheet(
				"interract",
				'http://childrenofur.com/assets/entityImages/npc_mailbox_variant_mailboxLeft_x1_interact_png_1354832236.png',
				873,
				146,
				97,
				146,
				9,
				false),
			"idle":new Spritesheet(
				"idle",
				'http://childrenofur.com/assets/entityImages/npc_mailbox_variant_mailboxLeft_x1_idle_png_1354832232.png',
				97,
				146,
				97,
				146,
				1,
				false),
			"has_mail_idle":new Spritesheet(
				"has_mail_idle",
				'http://childrenofur.com/assets/entityImages/npc_mailbox_variant_mailboxLeft_x1_has_mail_idle_png_1354832235.png',
				97,
				146,
				97,
				146,
				1,
				false)
		};
		currentState = states['idle'];
		respawn = new DateTime.now();
	}

	void update() {
		DateTime now = new DateTime.now();
		if (respawn != null && respawn.compareTo(now) < 0) {
			//check for new mail

			//check again in 1 minute
			respawn = now.add(new Duration(minutes: 1));
		}
	}

	Future checkMail({WebSocket userSocket, String email}) async {
		String query = "SELECT * FROM messages JOIN users ON username = to_user WHERE email = @email AND read = FALSE";
		PostgreSql dbConn = await dbManager.getConnection();
		List<Message> messages = await dbConn.query(query, Message, {'email':email});
		if (messages.length > 0) {
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
	user = user.toLowerCase(); // case-insensitive search

	List<Message> messages = [];

	String query = "SELECT * FROM messages WHERE lower(to_user) = @user";
	List<Row> rows = await dbConn.innerConn.query(query, {'user':user}).toList();
	rows.forEach((Row row) {
		Message m = new Message()
			..id = row.id
			..to_user = row.to_user
			..from_user = row.from_user
			..subject = row.subject
			..body = row.body
			..read = row.read
			..currants = row.currants
			..currants_taken = row.currants_taken;
		if(row.item1 != null) {
			m.item1 = jsonx.decode(row.item1, type: Item);
		}
		if(row.item2 != null) {
			m.item1 = jsonx.decode(row.item2, type: Item);
		}
		if(row.item3 != null) {
			m.item1 = jsonx.decode(row.item3, type: Item);
		}
		if(row.item4 != null) {
			m.item1 = jsonx.decode(row.item4, type: Item);
		}
		if(row.item5 != null) {
			m.item1 = jsonx.decode(row.item5, type: Item);
		}
		messages.add(m);
	});

	return messages;
}

@app.Route('/sendMail', methods: const[app.POST])
Future<String> sendMail(@app.Body(app.JSON) Map parameters) async {
	Message message = jsonx.decode(JSON.encode(parameters), type: Message);

	String email = await User.getEmailFromUsername(message.from_user);

	if (message.currants > 0) {
		Metabolics m = await getMetabolics(username: message.from_user);
		if (m.currants < message.currants) {
			return "Not enough currants";
		} else {
			m.currants -= message.currants;
			setMetabolics(m);
		}
	}

	List<Item> items = [message.item1, message.item2, message.item3, message.item4, message.item5];
	items.removeWhere((Item i) => i == null);

	//do we have all the items?
	Future.forEach(items, (Item item) async {
		if(!(await InventoryV2.hasItem(email, item.itemType, 1))) {
			return "Invalid items";
		}
	});

	//take the items
	Future.forEach(items, (Item item) async {
		await InventoryV2.takeAnyItemsFromUser(email, item.itemType, 1);
	});

	try {
		String query = "INSERT INTO messages(to_user, from_user, subject, body, currants, item1, item2, item3, item4, item5) VALUES(@to_user,@from_user,@subject,@body,@currants,@item1,@item2,@item3,@item4,@item5)";
		int result = await dbConn.execute(query, message);

		if (result > 0) {
			String type = 'sendMail_${message.to_user}';
			type += '_containingItems_$items';
			type += '_currants_${message.currants}';
			messageBus.publish(new RequirementProgress(type, email));
			return "OK";
		} else {
			return "Error";
		}
	} catch (err) {
		return "Error";
	}
}

@app.Route('/collectItem', methods: const[app.POST])
Future collectItem(@app.Body(app.JSON) Map parameters) async {
	int index = parameters['index'];
	int id = parameters['id'];
	String email = parameters['email'];

	if (index < 1 || index > 5) {
		return 'Error';
	}

	String query = 'SELECT item$index FROM messages where id = @id';
	try {
		Row row = (await dbConn.innerConn.query(query, {'id':id}).toList()).first;
		Item item = jsonx.decode(row.toMap()['item$index'], type: Item);
		bool success = (await InventoryV2.addItemToUser(email, encode(item), 1)) == 1;
		if(!success) {
			return 'Error';
		}
	} catch(e) {
		return 'Error';
	}

	return 'Success';
}

@app.Route('/collectCurrants', methods: const[app.POST])
Future collectCurrants(@app.Body(app.JSON) Map parameters) async {
	Message message = jsonx.decode(JSON.encode(parameters), type: Message);
	//mark the currants as already taken so they can't be taken again
	String query = "UPDATE messages set currants_taken = true where id = @id AND currants_taken = false";
	int result = await dbConn.execute(query, message);

	if (result < 1) {
		return "Error";
	}

	//give the currants to the user
	Metabolics m = await getMetabolics(username: message.to_user);
	m.currants += message.currants;
	setMetabolics(m);
}

@app.Route('/deleteMail', methods: const[app.POST])
Future<String> deleteMail(@app.Body(app.JSON) Map parameters) async
{
	String query = "DELETE FROM messages WHERE id = @id";
	int result = await dbConn.execute(query, {'id':parameters['id']});

	if (result > 0)
		return "OK";
	else
		return "Error";
}

@app.Route('/readMail', methods: const[app.POST])
readMail(@app.Body(app.JSON) Map parameters) async {
	Message message = jsonx.decode(JSON.encode(parameters), type: Message);
	String query = "UPDATE messages SET read = TRUE WHERE id = @id";
	await dbConn.execute(query, message);
}

class Message {
	@Field() int id, currants = 0;
	@Field() String to_user, from_user, subject = '', body = '';
	@Field() bool read = false, currants_taken = false;
	@Field() Item item1, item2, item3, item4, item5;
}