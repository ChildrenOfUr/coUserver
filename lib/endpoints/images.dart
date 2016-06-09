part of util;

@app.Route('/getSpritesheets')
Future<Map> getSpritesheets(@app.QueryParam('username') String username) async {
	if (username == null) {
		return {};
	}

	Map<String, String> spritesheets = {};
	File cache = new File('./playerSpritesheets/${username.toLowerCase()}.json');
	if (!(await cache.exists())) {
		try {
			await cache.create(recursive: true);
			spritesheets = await _getSpritesheetsFromWeb(username);
			await cache.writeAsString(JSON.encode(spritesheets));
			return spritesheets;
		} catch (e) {
			return {};
		}
	} else {
		try {
			return JSON.decode(cache.readAsStringSync());
		} catch (err) {
			return {};
		}
	}
}

Future<Map> _getSpritesheetsFromWeb(String username) async {
	Map spritesheets = {};

	String url = 'http://www.glitchthegame.com/friends/search/?q=${Uri.encodeComponent(username)}';
	String response = await http.read(url);

	RegExp regex = new RegExp('\/profiles\/(.+)\/" class="friend-name">$username', caseSensitive: false);
	if (regex.hasMatch(response)) {
		String tsid = regex.firstMatch(response).group(1);

		response = await http.read('http://www.glitchthegame.com/profiles/$tsid');

		List<String> sheets = [
			'base', 'angry', 'climb', 'happy', 'idle1', 'idle2', 'idle3', 'idleSleepy', 'jump', 'surprise'];
		sheets.forEach((String sheet) {
			RegExp regex = new RegExp('"(.+$sheet\.png)"');
			spritesheets[sheet] = regex.firstMatch(response).group(1);
		});

		return spritesheets;
	} else {
		return _getSpritesheetsFromWeb('Hectaku');
	}
}

@app.Route('/getActualImageHeight')
Future<int> getActualImageHeight(@app.QueryParam('url') String imageUrl,
	@app.QueryParam('numRows') int numRows,
	@app.QueryParam('numColumns') int numColumns) async {
	if (FileCache.heightsCache[imageUrl] != null) {
		return FileCache.heightsCache[imageUrl];
	} else {
		http.Response response = await http.get(imageUrl);

		Image image = decodeImage(response.bodyBytes);
		if (image == null) {
			return 0;
		}

		Image singleFrame = copyCrop(image, 0, 0, image.width ~/ numColumns, image.height ~/ numRows);
		int actualHeight = findTrim(singleFrame, mode: TRIM_TRANSPARENT)[3];
		FileCache.heightsCache[imageUrl] = actualHeight;
		return actualHeight;
	}
}

@app.Route('/trimImage')
Future<String> trimImage(@app.QueryParam('username') String username) async {
	if (FileCache.headsCache[username] != null) {
		return FileCache.headsCache[username];
	} else {
		Map<String, String> spritesheet = await getSpritesheets(username);
		String imageUrl = spritesheet['base'];
		if (imageUrl == null) {
			return '';
		}

		http.Response response = await http.get(imageUrl);

		Image image = decodeImage(response.bodyBytes);
		int frameWidth = image.width ~/ 15;
		image = copyCrop(image, image.width - frameWidth, 0, frameWidth, image.height ~/ 1.5);
		List<int> trimRect = findTrim(image, mode: TRIM_TRANSPARENT);
		Image trimmed = copyCrop(image, trimRect[0], trimRect[1], trimRect[2], trimRect[3]);

		String str = CryptoUtils.bytesToBase64(encodePng(trimmed));
		FileCache.headsCache[username] = str;
		return str;
	}
}
