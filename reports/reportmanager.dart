part of coUserver;

class ReportManager {
  static DateTime currDate = new DateTime.now();
  static Random rand = new Random();

  static File getReportFile() {
    String reportsDirectory = Platform.script.toFilePath();
    reportsDirectory = reportsDirectory.substring(0, reportsDirectory.lastIndexOf('/'));
    File reportFile = new File("$reportsDirectory/reports/userdata/reports.json");
    return reportFile;
  }

  static File getImageStore(String username, String ext) {
    String reportsDirectory = Platform.script.toFilePath();
    reportsDirectory = reportsDirectory.substring(0, reportsDirectory.lastIndexOf('/'));
    String filename = username + "_" + ReportManager.currDate.day.toString() + "-" + ReportManager.currDate.month.toString() + "-" + ReportManager.currDate.year.toString() + "_" + rand.nextInt(999).toString().padLeft(3);
    File reportFile = new File("$reportsDirectory/reports/userdata/images/$filename.$ext");
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
addReport(@app.Body(app.FORM) Map data) {

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
  if (data["image"] != "") {
    File image = ReportManager.getImageStore(data["username"] as String, (data["image"]).filename.split["."][1]);
    image.writeAsBytesSync(data["image"].content);
  }
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
  if (reports.where((Map reportMap) => reportMap["id"] == id).toList().length > 0) {
    reports.removeWhere((Map reportMap) => reportMap["id"] == id);
    ReportManager.writeReports(reports);
  }
}