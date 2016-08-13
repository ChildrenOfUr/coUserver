part of coUserver;

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

	//don't clog up the dev server with layer files. Those are only needed on the fatcow server
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
	await Process.run('optipng', ['$layerName.png'], workingDirectory: '/home/cou/streetLayers/$tsid');
	await uploadToServer(layer, tsid, layerName);

	Log.verbose('uploaded $layerName for $tsid to http://childrenofur.com/assets/streetLayers/dev/$tsid/$layerName.png');
}

Future uploadToServer(File layer, String tsid, String layerName) async {
	http.MultipartRequest request = new http.MultipartRequest("POST",
		Uri.parse("http://childrenofur.com/assets/upload_street_layer.php"));
	String filename = 'streetLayers/dev/$tsid/$layerName.png';
	http.MultipartFile multipartFile = new http.MultipartFile.fromBytes(
		'file', layer.readAsBytesSync(), filename: filename);
	request.files.add(multipartFile);
	request.fields['tsid'] = tsid;
	request.fields['filename'] = filename;
	request.fields['redstoneToken'] = redstoneToken;
	await request.send();
}