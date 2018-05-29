part of util;

@app.Route('/setCustomAvatar')
Future<bool> setCustomAvatar(
	@app.QueryParam('username') String username,
	@app.QueryParam('avatar') String avatar
) async {
	try {
		if (avatar == username) {
			// Reset to default
			avatar = null;
		}

		int result = await dbConn.execute(
			'UPDATE users SET custom_avatar = @avatar WHERE username = @username',
			{'username': username, 'avatar': avatar});
		assert(result == 1);

		FileCache.headsCache
			..remove(username)
			..remove('$username.fullheight');
		return true;
	} catch (e) {
		Log.warning('setCustomAvatar <username=$username> <avatar=$avatar>', e);
		return false;
	}
}

@app.Route('/getSpritesheets')
Future<Map> getSpritesheets(
	@app.QueryParam('username') String username,
	[@app.QueryParam('noCustomAvatars') bool noCustomAvatars = false]
) async {
	if (username == null) {
		return {};
	}

	// Check to see if this player has selected a different avatar
	if (noCustomAvatars == null || !noCustomAvatars) {
		try {
			List<User> dbRows = await dbConn.query(
				'SELECT custom_avatar FROM users WHERE username = @username',
				User, {'username': username});
			if (dbRows.length == 1 && dbRows.single.custom_avatar != null) {
				username = dbRows.single.custom_avatar;
			}
		} catch (e) {
			Log.warning('getSpritesheets failed to check custom avatar for <username=$username>', e);
		}
	}

	Map<String, String> spritesheets = {};
	File cache = new File('./spineSkins/${username.toLowerCase()}.json');
	if (!(await cache.exists())) {
		try {
			await cache.create(recursive: true);
			spritesheets = await _getSpritesheetsFromWeb(username);
			await cache.writeAsString(jsonEncode(spritesheets));
			return spritesheets;
		} catch (_) {
			return {};
		}
	} else {
		try {
			return jsonDecode(cache.readAsStringSync());
		} catch (_) {
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
Future<String> trimImage(
	@app.QueryParam('username') String username,
	[@app.QueryParam('noCustomAvatars') bool noCustomAvatars = false,
	@app.QueryParam('fullHeight') bool fullHeight = false]
) async {
	String cacheKey = ((fullHeight != null && fullHeight) ? '${username}.fullheight' : username);

	if (FileCache.headsCache[cacheKey] != null) {
		return FileCache.headsCache[cacheKey];
	} else {
		Map<String, String> spritesheet = await getSpritesheets(username, noCustomAvatars);
		String imageUrl = spritesheet['base'];
		if (imageUrl == null) {
			return '';
		}

		http.Response response = await http.get(imageUrl);

		Image image = decodeImage(response.bodyBytes);
		int frameWidth = image.width ~/ 15;
		int frameHeightScl = ((fullHeight != null && fullHeight)
			? image.height // full height
			: image.height ~/ 1.5); // head only
		image = copyCrop(image, image.width - frameWidth, 0, frameWidth, frameHeightScl);
		List<int> trimRect = findTrim(image, mode: TRIM_TRANSPARENT);
		Image trimmed = copyCrop(image, trimRect[0], trimRect[1], trimRect[2], trimRect[3]);

		String str = base64Encode(encodePng(trimmed));
		FileCache.headsCache[cacheKey] = str;
		return str;
	}
}
