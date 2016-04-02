part of item;

class Note {
	@Field() int id;
	@Field() String username;
	@Field() String title;
	@Field() String body;
	@Field() DateTime timestamp;

	Note();
	Note.create(this.username, String title, this.body, [this.id]) {
		title = title.trim();
		if (title.length > NoteManager.title_length_max) {
			title = title.substring(0, NoteManager.title_length_max - 1);
		}
		this.title = title;
	}

	Map<String, dynamic> toMap() => {
		"id": id,
		"username": username,
		"title": title,
		"body": body,
		"timestamp": timestamp.toString()
	};

	@override
	String toString() => "<Note '$title' by '$username'>";
}

@app.Group("/note")
class NoteManager {
	static final int title_length_max = 30; // Also set by HTML in client
	static final String tool_id = "quill";
	static final String paper_id = "paper";
	static final String note_id = "note";

	static Future<Note> find(int id) async {
		try {
			return (await dbConn.query(
				"SELECT * FROM notes WHERE id = @id",
				Note, {"id": id}
			)).single;
		} catch(e) {
			log("Could not find note $id: $e");
			return null;
		}
	}

	static Future<Note> add(Note note) async {
		PostgreSql dbConn = await dbManager.getConnection();

		if (note.id == null || note.id == -1) {
			// Adding a new note
			try {
				return (await dbConn.query(
					"INSERT INTO notes (username, title, body) "
						"VALUES (@username, @title, @body) RETURNING *",
					Note, {"username": note.username.trim(), "title": note.title.trim(), "body": note.body}
				)).single;
			} catch(e) {
				log("Could not add note $note: $e");
				return null;
			} finally {
				dbManager.closeConnection(dbConn);
			}
		} else {
			// Updating an existing note
			try {
				return (await dbConn.query(
					"UPDATE notes SET title = @title, body = @body "
						"WHERE id = @id RETURNING *",
					Note, {"id": note.id, "title": note.title.trim(), "body": note.body}
				)).single;
			} catch(e) {
				log("Could not edit note $note: $e");
				return null;
			} finally {
				dbManager.closeConnection(dbConn);
			}
		}
	}

	static Future<Map> addFromClient(Map noteData) async {
		try {
			// Add data to database
			Note created = new Note.create(noteData["username"], noteData["title"], noteData["body"], noteData["id"]);
			Note added = await add(created);

			// Add item to inventory
			String email = await User.getEmailFromUsername(noteData["username"]);

			if (await InventoryV2.takeAnyItemsFromUser(email, paper_id, 1) != 1) {
				// Ran out of paper somehow, stop
				return ({"error": "You ran out of paper!"});
			}

			Item newNoteItem = new Item.clone(note_id)
				..metadata.addAll({"note_id": added.id});

			if (await InventoryV2.addItemToUser(email, newNoteItem.getMap(), 1) != 1) {
				// No empty slot, refund paper
				await InventoryV2.addItemToUser(email, items["paper"].getMap(), 1);
				return ({"error": "There's no room for this note in your inventory!"});
			}

			// Send OK to client
			return added.toMap();
		} catch(e) {
			log("Couldn't create note with $noteData: $e");
			return ({"error": "Something went wrong :("});
		}
	}

	@app.Route("/find/:id")
	Future<String> _appFind(int id) async => JSON.encode((await find(id)).toMap());
}