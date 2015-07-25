part of coUserver;

@app.Route("/uploadStreetRender", methods: const [app.POST])
uploadStreetRender(@app.Body(app.JSON) Map street) {
  String tsid = street['tsid'];
  if(tsid.startsWith('G')) {
    tsid = 'L' + tsid.substring(1);
  }
  Map<String,String> layers = street['layers'];
  new Directory('streetLayers/$tsid')..create(recursive: true);
  layers.forEach((String layerName, String dataUri) async {
    layerName = layerName.replaceAll(' ','_');
    print('creating $tsid');
    File layer = new File('streetLayers/$tsid/$layerName.png');
    if(await layer.exists()) {
      layer.delete();
    }
    layer.create();

    dataUri = dataUri.substring(dataUri.indexOf(',')+1);
    Image image = decodePng(CryptoUtils.base64StringToBytes(dataUri));
    layer.writeAsBytes(encodePng(image));
  });
}