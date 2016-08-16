part of item;

abstract class Quill {
	static void openNote(WebSocket userSocket, int noteId) {
		userSocket.add(JSON.encode({
			"note_read": noteId.toString() //client is expecting to parse an int from a string
		}));
	}

	static void openNoteEditor(WebSocket userSocket) {
		userSocket.add(JSON.encode({
			"note_write": true
		}));
	}

	// Note

	Future writeNote({WebSocket userSocket, Map map, String streetName, String email, String username}) async {
		openNoteEditor(userSocket);
	}

	Future readNote({WebSocket userSocket, Map map, String streetName, String email, String username}) async {
		int noteId;

		//if this action is coming from a ground item
		if (map['id'] != null && map['streetName'] != null &&
			StreetUpdateHandler.streets[map['streetName']].entityMaps['groundItem'][map['id']] != null) {
			Item note = StreetUpdateHandler.streets[map['streetName']].entityMaps['groundItem'][map['id']];
			noteId = int.parse(note.metadata['note_id']);
		} else {
			noteId = int.parse(map['itemdata']['note_id'].toString());
		}

		openNote(userSocket, noteId);
	}

	// Fortune

	Future readFortune({WebSocket userSocket, Map map, String streetName, String email, String username}) async {
		openNote(userSocket, map["itemdata"]["note_id"]);
	}

	// Fortune Cookie

	Future insertNote({WebSocket userSocket, Map map, String streetName, String email, String username}) async {
		if (map["itemdata"]["note_id"] != null) {
			toast("That cookie already has a note in it!", userSocket);
		} else {
			userSocket.add(JSON.encode({
				"action": "insertNote2",
				"id": "fortune_cookie",
				"openWindow": "itemChooser",
				"filter": "itemType=note",
				"windowTitle": "Which note do you want to insert?"
			}));
		}
	}

	Future insertNote2({WebSocket userSocket, Map map, String streetName, String email, String username}) async {
		// Find info about the note to put in the cookie
		Item noteTaken = await InventoryV2.takeItemFromUser(email, map["slot"], map["subSlot"], 1);
		assert (noteTaken != null && noteTaken.itemType == NoteManager.note_item);
		int noteId = int.parse(noteTaken.metadata["note_id"]);

		// Add the note id to the cookie
		Item cookieItem = new Item.clone(NoteManager.fortune_cookie_withfortune_item)
			..metadata["note_id"] = noteId.toString()
			..metadata["title"] = (await NoteManager.find(noteId)).title;

		// Replace the empty cookie with the new cookie in their inventory
		if ((await InventoryV2.takeAnyItemsFromUser(email, NoteManager.fortune_cookie_item, 1)) != null) {
			InventoryV2.addItemToUser(email, cookieItem.getMap(), 1);
		}
	}

	Future breakCookie({WebSocket userSocket, Map map, String streetName, String email, String username}) async {
		if (map["itemdata"]["note_id"] == null) {
			toast("That cookie is empty!", userSocket);
		} else {
			// Find info about the note inside the cookie
			int noteId = map["itemdata"]["note_id"];

			// Create a fortune item
			Item fortuneItem = new Item.clone(NoteManager.fortune_item)
				..metadata["note_id"] = noteId.toString()
				..metadata["title"] = (await NoteManager.find(noteId)).title;

			// Replace the cookie with the fortune in their inventory
			if ((await InventoryV2.takeItemFromUser(email, map["slot"], map["subSlot"], 1)) != null) {
				InventoryV2.addItemToUser(email, fortuneItem.getMap(), 1);
			}

			// Open the note in the client
			openNote(userSocket, noteId);
		}
	}
}