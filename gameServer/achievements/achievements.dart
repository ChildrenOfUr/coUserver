part of coUserver;

class Achievement {
	static Map<String, Achievement> ACHIEVEMENTS = {};

	static Future load() async {
		String directory = Platform.script.toFilePath();
		directory = directory.substring(0, directory.lastIndexOf("/"));

		await new Directory("$directory/gameServer/achievements/json").list().forEach((File category) async {
			await JSON.decode(await category.readAsString()).forEach((String name, Map data) async {
				ACHIEVEMENTS[name] = data;
			});
		});
	}

	String _id;
	String _title;
	String _description;
	String _category;
	String _imageUrl;
	List<Achievement> _related;

	String get id => _id;
	String get title => _title;
	String get description => _description;
	String get category => _category;
	String get imageUrl => _imageUrl;
	List<Achievement> get related => _related;

	Future<bool> playerHas(String email) {
		log("Does $email have $id?");
	}

	Future<bool> award(String email) {
		log("Awarding $id to $email");
	}
}