part of coUserver;

@app.Route("/uploadStreetRender", methods: const [app.POST])
Future<String> uploadStreetRender(@app.Body(app.JSON) Map street) async {
	print('got ${street['tsid']}');
	String tsid = street['tsid'];
	if (tsid.startsWith('G')) {
		tsid = 'L' + tsid.substring(1);
	}
	Map<String, String> layers = street['layers'];
	Directory streetDir = new Directory('streetLayers/$tsid');
	await streetDir.create(recursive: true);

	List<Future> futures = [];
	layers.forEach((String layerName, String dataUri) => futures.add(writeLayerToFile(tsid, layerName, dataUri)));
	await Future.wait(futures);

	print('finished ${street['tsid']}');
	return 'saved';
}

Future writeLayerToFile(String tsid, String layerName, String dataUri) async {
	layerName = layerName.replaceAll(' ', '_');
	File layer = new File('streetLayers/$tsid/$layerName.png');
	if (await layer.exists()) {
		await layer.delete();
	}
	await layer.create();

	dataUri = dataUri.substring(dataUri.indexOf(',') + 1);
	Image image = decodePng(CryptoUtils.base64StringToBytes(dataUri));
	await layer.writeAsBytes(encodePng(image));

	print('saved $layerName for $tsid');
}