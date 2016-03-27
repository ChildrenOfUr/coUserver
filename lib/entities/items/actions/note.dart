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

	static Future<Note> find(int id) async {
		try {
			return (await dbConn.query(
				"SELECT * FROM notes WHERE id = @id",
				Note, {"id": id}
			)).single;
		} catch(e) {
			log("Could not find note $id: $e");
		}
	}

	static Future<Note> add(Note note) async {
		if (note.id != null && (await find(note.id)) != null) {
			// Updating an existing note
			try {
				return (await dbConn.query(
					"UPDATE notes SET title = @title, body = @body "
					"WHERE id = @id RETURNING *",
					Note, {"id": note.id, "title": note.title.trim(), "body": note.body}
				)).single;
			} catch(e) {
				log("Could not edit note $note: $e");
			}
		} else {
			// Adding a new note
			try {
				return (await dbConn.query(
					"INSERT INTO notes (username, title, body) "
					"VALUES (@username, @title, @body) RETURNING *",
					Note, {"username": note.username.trim(), "title": note.title.trim(), "body": note.body}
				)).single;
			} catch(e) {
				log("Could not add note $note: $e");
			}
		}
	}

	@app.Route("/find/:id")
	Future<String> _appFind(int id) async => JSON.encode((await find(id)).toMap());
}