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
			..currants_taken = row.currants_taken
			..item1 = row.item1
			..item1_taken = row.item1_taken
			..item2 = row.item2
			..item2_taken = row.item2_taken
			..item3 = row.item3
			..item3_taken = row.item3_taken
			..item4 = row.item4
			..item4_taken = row.item4_taken
			..item5 = row.item5
			..item5_taken = row.item5_taken;
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

	List<String> itemSlots = [message.item1_slot, message.item2_slot, message.item3_slot,
							  message.item4_slot, message.item5_slot];
	List<Item> items = new List<Item>(5);

	int i=0;
	List<int> toUse = [];
	for(String s in itemSlots) {
		if (s != null) {
			toUse.add(i);
		}
		i++;
	}

	//take the items
	await Future.forEach(toUse, (int index) async {
		String slot = itemSlots[index];
		int barSlot = int.parse(slot.split('.').elementAt(0));
		int bagSlot = int.parse(slot.split('.').elementAt(1));
		items[index] = await InventoryV2.takeItemFromUser(email, barSlot, bagSlot, 1);
	});

	message.item1 = encode(items[0]);
	message.item2 = encode(items[1]);
	message.item3 = encode(items[2]);
	message.item4 = encode(items[3]);
	message.item5 = encode(items[4]);

	try {
		String query = "INSERT INTO messages(to_user, from_user, subject, body, currants, item1, item2, item3, item4, item5) VALUES(@to_user,@from_user,@subject,@body,@currants,@item1,@item2,@item3,@item4,@item5)";
		int result = await dbConn.execute(query, message);

		List<String> itemNames = [];
		for (Item item in items) {
			if(item == null) {
				continue;
			}
			itemNames.add(item.itemType);
		}

		if (result > 0) {
			String type = 'sendMail_${message.to_user}';
			type += '_containingItems_$itemNames';
			type += '_currants_${message.currants}';
			messageBus.publish(new RequirementProgress(type, email));
			return "OK";
		} else {
			return "Error";
		}
	} catch (err) {
		return "Error: $err";
	}
}

@app.Route('/collectItem', methods: const[app.POST])
Future collectItem(@app.Body(app.JSON) Map parameters) async {
	int index = parameters['index'];
	int id = parameters['id'];
	String email = await User.getEmailFromUsername(parameters['to_user']);

	if (index < 1 || index > 5) {
		return 'Error, index is invalid';
	}

	String query = 'SELECT item$index, item${index}_taken FROM messages WHERE id = @id';
	try {
		Row row = (await dbConn.innerConn.query(query, {'id':id}).toList()).first;
		String itemString = row.toMap()['item$index'];
		if (itemString == null) {
			return 'Error, item is null';
		}
		if (row.toMap()['item${index}_taken'] == true) {
			return 'Error, item already taken';
		}
		Item item = jsonx.decode(itemString, type: Item);
		bool success = (await InventoryV2.addItemToUser(email, encode(item), 1)) == 1;
		if (!success) {
			return 'Error, could not give ${item.itemType} to $email';
		} else {
			//mark the item as taken
			query = 'UPDATE messages SET item${index}_taken = true WHERE id = @id';
			await dbConn.execute(query, {'id':id});
		}
	} catch (e) {
		return 'Error, $e';
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
	@Field() String to_user, from_user,	subject = '', body = '';
	@Field() bool read = false,	currants_taken = false,
		item1_taken = false, item2_taken = false, item3_taken = false,
		item4_taken = false, item5_taken = false;
	@Field() String item1, item2, item3, item4, item5;
	@Field() String item1_slot, item2_slot, item3_slot, item4_slot, item5_slot;
}