part of coUserver;

@app.Route('/uploadNewSceneryImage', methods: const [app.POST], allowMultipartRequest: true)
Future<String> uploadNewSceneryImage(@app.Body(app.FORM) form) async {
	if (form['token'] != redstoneToken) {
		return 'authorization failed';
	}

	var f = form['newSceneryFile'];
	File file = new File('/home/cou/www/scenery/${f.filename}');
	await file.writeAsBytes(f.content);

	Directory streetDir = new Directory('/home/cou/www/scenery_resized');
	await Future.forEach(streetDir.listSync(), (FileSystemEntity file) async {
		if (file is File && file.path.contains(f.filename)) {
			await file.delete();
		}
	});

	return 'success';
}

@app.Route("/uploadStreetRender", methods: const [app.POST])
Future<String> uploadStreetRender(@app.Body(app.JSON) Map street) async {
	if (street['redstoneToken'] != redstoneToken) {
		return 'authorization failed';
	}

	String tsid = street['tsid'];
	if (tsid.startsWith('G')) {
		tsid = 'L' + tsid.substring(1);
	}
	Map<String, String> layers = street['layers'];
	Directory streetDir = new Directory('/home/cou/streetLayers/$tsid');
	await streetDir.create(recursive: true);

	await Future.forEach(layers.keys, (String layerName) => writeLayerToFile(tsid, layerName, layers[layerName]));

	//don't clog up the dev server with what should be an empty directory
	await streetDir.delete(recursive: true);

	return 'saved';
}

Future writeLayerToFile(String tsid, String layerName, String dataUri) async {
	layerName = layerName.replaceAll(' ', '_');
	File layer = new File('/home/cou/streetLayers/$tsid/$layerName.png');
	if (await layer.exists()) {
		await layer.delete();
	}
	await layer.create();

	dataUri = dataUri.substring(dataUri.indexOf(',') + 1);
	await layer.writeAsBytes(new Base64Decoder().convert(dataUri));
//	await Process.run('optipng', ['$layerName.png'], workingDirectory: '/home/cou/streetLayers/$tsid');

	//put it in the web root
	Directory streetDir = new Directory('/home/cou/www/streetLayers/$tsid');
	await streetDir.create(recursive: true);
	await layer.rename('/home/cou/www/streetLayers/$tsid/$layerName.png');
}

@app.Route("/confirmStreetRender", methods: const [app.POST])
Future confirmStreetRender(@app.Body(app.JSON) Map street) async {
	if (street['redstoneToken'] != redstoneToken) {
		return 'authorization failed';
	}

	String tsid = street['tsid'];
	if (tsid.startsWith('G')) {
		tsid = 'L' + tsid.substring(1);
	}

	Directory streetDir = new Directory('/home/cou/www/streetLayers/$tsid');
	await Future.forEach(streetDir.listSync(), (FileSystemEntity layerFile) async {
		if (layerFile is File) {
			String layerName = basename(layerFile.path);
			String filename = 'streetLayers/dev/$tsid/$layerName';
			http.MultipartRequest request = new http.MultipartRequest("POST",
				Uri.parse("http://childrenofur.com/assets/upload_street_layer.php"));
			http.MultipartFile multipartFile = new http.MultipartFile.fromBytes(
				'file', layerFile.readAsBytesSync(), filename: filename);
			request.files.add(multipartFile);
			request.fields['tsid'] = tsid;
			request.fields['filename'] = filename;
			request.fields['redstoneToken'] = redstoneToken;
			await request.send();
			Log.verbose('uploaded $layerName for $tsid to http://childrenofur.com/assets/streetLayers/dev/$tsid/$layerName');
		}
	});

	//now transfer the street from the dev folder to the live folder
	String url = 'http://childrenofur.com/assets/make_street_layers_live.php';
	http.Response response = await http.post(url, body:
		{'redstoneToken': redstoneToken, 'tsid': tsid});
	print(response.body);
}