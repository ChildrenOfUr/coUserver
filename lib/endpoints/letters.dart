library letters;

import 'dart:math' hide log;

import 'package:redstone/redstone.dart' as app;

@app.Group("/letters")
class Letters {
	static Random rand = new Random();

	/// Contains usernames and assigned letters
	static Map<String, String> letterAssignments = {};

	/// Returns a random letter a-z. Set `heart` to true to include a chance (1/27) for _heart
	static String randomLetter([bool heart = false]) {
		List<String> letters = ["a", "b", "c", "d", "e", "f", "g", "h", "i", "j", "k", "l", "m", "n", "o", "p", "q", "r", "s", "t", "u", "v", "w", "x", "y", "z"];
		if (heart) {
			letters.add("_heart");
		}
		return letters[rand.nextInt(letters.length)];
	}

	/// Returns the player's assigned letter
	@app.Route("/getPlayerLetter")
	String getPlayerLetter(@app.QueryParam("username") String username) {
		return letterAssignments[username] ?? newPlayerLetter(username);
	}

	/// Changes the player's assigned letter to a random letter. Used on street change
	@app.Route("/newPlayerLetter")
	String newPlayerLetter(@app.QueryParam("username") String username) {
		letterAssignments[username] = randomLetter(true);
		return getPlayerLetter(username);
	}
}

Letters PLAYER_LETTERS = new Letters();