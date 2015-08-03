part of coUserver;

//TODO: use a database, not a JSON file
class ReportManager {
  static DateTime currDate = new DateTime.now();
  static Random rand = new Random();

  static String directory = Platform.script.toFilePath();
  static String reportsDirectory = directory.substring(0, directory.lastIndexOf('/'));

  static File getReportFile() {
    File reportFile = new File("$reportsDirectory/reports/userdata/reports.json");
    return reportFile;
  }

  static List<Map> getReports() {
    String json = getReportFile().readAsStringSync();
    if (json == "" || json == null) json = "[]";
    List<Map> reportData = JSON.decode(json);
    return reportData;
  }

  static writeReports(List<Map> reports) {
    getReportFile().writeAsStringSync(JSON.encode(reports));
  }

}

@app.Route("/report/add", methods: const [app.POST], allowMultipartRequest: true)
addReport(@app.Body(app.FORM) Map data) async {

  // Get existing reports
  List<Map> existingReports = ReportManager.getReports();

  // Pick the next id
  List<int> ids = [];
  int newId = 0;
  if (existingReports.isNotEmpty) {
    existingReports.forEach((Map reportMap) => ids.add((reportMap["id"] as int)));
    ids.sort();
    newId = ids.last + 1;
  } else {
    newId = 1;
  }

  // Assemble Data

  Map<String, dynamic> reportMap = {
    "id": newId,
    "title": (data["title"] as String).trim(),
    "description": (data["description"] as String).trim(),
    "log": (data["log"] as String).trim(),
    "useragent": (data["useragent"] as String).trim(),
    "username": (data["username"] as String).trim(),
    "email": (data["email"] as String).trim(),
    "category": (data["category"] as String).trim().toLowerCase(),
    "date": {
      "year": ReportManager.currDate.year,
      "month": ReportManager.currDate.month,
      "day": ReportManager.currDate.day
    },
    "done": false
  };

  if (data["image"] != null) {
    Map fileMap = {
      "image": CryptoUtils.bytesToBase64(data["image"].content)
    };
    reportMap.addAll(fileMap);
  }

  // Write to reports file
  existingReports.add(reportMap);
  ReportManager.writeReports(existingReports);
}

@app.Route('/report/list') Future<List<Map>> listReports() async {
  return ReportManager.getReports();
}

@app.Route('/report/markDone')
markReportDone(@app.QueryParam('id') int id) async {
  List<Map> reports = ReportManager.getReports();
  if (reports.where((Map reportMap) => reportMap["id"] == id).toList().length > 0) {
    Map report = reports.where((Map reportMap) => reportMap["id"] == id).toList().first;
    report["done"] = true;
    reports.removeWhere((Map reportMap) => reportMap["id"] == id);
    reports.add(report);
    reports.sort((Map a, Map b) => (a["id"] as int).compareTo(b["id"] as int));
    ReportManager.writeReports(reports);
  }
}

@app.Route('/report/delete')
deleteReport(@app.QueryParam('id') int id) async {
  List<Map> reports = ReportManager.getReports();
  List<Map> report = reports.where((Map reportMap) => reportMap["id"] == id).toList();
  if (report.length > 0) {
    reports.removeWhere((Map reportMap) => reportMap["id"] == id);
    ReportManager.writeReports(reports);
  }
}