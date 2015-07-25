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

List<String> streetsToParse = ['GA58KK7B9O522PC'];
List<String> streetsParsed = [];

Future parseStreets() async {
  while (streetsToParse.isNotEmpty) {
    String currentTsid = streetsToParse.removeLast();
    streetsParsed.add(currentTsid);
    Map street = await getStreet(currentTsid);
    String currentLabel = street['label'];

    List<Map> signposts = street['dynamic']['layers']['middleground']['signposts'];
    signposts.forEach((Map signpost) {
      List<Map> connects = signpost['connects'];
      connects.forEach((Map connection) {
        String tsid = connection['tsid'];
        String label = connection['label'];
        if (!streetsParsed.contains(tsid) && !streetsToParse.contains(tsid)) {
          streetsToParse.add(tsid);
          print('queuing up $label');
        }
      });
    });
  }
}

Future<Map> getStreet(String tsid) async {
  if(tsid.startsWith('L')) {
    tsid = tsid.replaceFirst('L','G');
  }
  String url = "http://RobertMcDermot.github.io/CAT422-glitch-location-viewer/locations/$tsid.json";
  http.Response response = await http.get(url);
  Map street = JSON.decode(response.body);
  return street;
}