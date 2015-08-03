part of coUserver;

//TODO: use a database, not a JSON file
class ReportManager {

  // Globals

  static DateTime currDate = new DateTime.now();
  static Random rand = new Random();

  // Get Directory

  static String directory = Platform.script.toFilePath();
  static String reportsDirectory = directory.substring(0, directory.lastIndexOf('/'));

  // Access Files

  static File getReportFile() {
    File reportFile = new File("$reportsDirectory/reports/userdata/reports.json");
    return reportFile;
  }

  static File getMergeFile() {
    File reportFile = new File("$reportsDirectory/reports/userdata/merged.json");
    return reportFile;
  }

  // Read File Data

  static List<Map> getReports() {
    String json = getReportFile().readAsStringSync();
    if (json == "" || json == null) json = "[]";
    List<Map> reportData = JSON.decode(json);
    return reportData;
  }

  static List<Map> getMerges() {
    String json = getMergeFile().readAsStringSync();
    if (json == "" || json == null) json = "[]";
    List<Map> mergeData = JSON.decode(json);
    return mergeData;;
  }

  // Write File Data

  static writeReports(List<Map> reports) {
    getReportFile().writeAsStringSync(JSON.encode(reports));
  }

  static writeMerges(List<Map> merges) {
    getMergeFile().writeAsStringSync(JSON.encode(merges));
  }

}

// Insert a report

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
    "done": false,
    "merged": -1
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

// Get existing reports

@app.Route('/report/list') Future<List<Map>> listReports() async {
  return ReportManager.getReports();
}

// Mark a report as done

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

// Permanently delete a report

@app.Route('/report/delete')
deleteReport(@app.QueryParam('id') int id) async {
  List<Map> reports = ReportManager.getReports();
  List<Map> report = reports.where((Map reportMap) => reportMap["id"] == id).toList();
  if (report.length > 0) {
    reports.removeWhere((Map reportMap) => reportMap["id"] == id);
    ReportManager.writeReports(reports);
  }
}

// Get existing merges

@app.Route('/report/merge/list') Future<List<Map>> listMerges() async {
  return ReportManager.getMerges();
}

// Merge reports

@app.Route('/report/merge/add')
mergeReport(
    @app.QueryParam('ids') String idList,
    @app.QueryParam('title') String title,
    @app.QueryParam('description') String description
    ) {

  // Read the id list
  List<int> ids = new List();
  try {
    ids = JSON.decode(idList);
  } catch (e) {
    // Don't crash the server if the id list is empty
    print("[ReportManagerInterface] $e");
    return;
  }

  // Read existing merges
  List<Map> merges = ReportManager.getMerges();

  // Read existing reports
  List<Map> allReports = ReportManager.getReports();

  // Find the ones we are merging
  List<Map> reports = allReports.where((Map report) => ids.contains(report["id"]));

  // Figure out which category to use (majority of the reports, or bug if equal)
  int bug = 0, suggestion = 0;
  String category;
  reports.forEach((Map report) {
    if (report["category"] == "bug") bug++;
    if (report["category"] == "suggestion") suggestion++;
  });
  if (suggestion > bug) {
    category = "suggestion";
  } else {
    category = "bug";
  }

  // Pick the next id
  List<int> existingIds = [];
  int newId = 0;
  if (merges.isNotEmpty) {
    merges.forEach((Map mergeMap) => ids.add((mergeMap["id"] as int)));
    ids.sort();
    newId = ids.last + 1;
  } else {
    newId = 1;
  }

  // Create a new merge
  Map<String, dynamic> merge = {
    "id": newId,
    "title": title,
    "description": description,
    "category": category,
    "reports": ids
  };

  // Update the reports list
  allReports.forEach((Map report) {
    if (ids.contains(report["id"])) {
      report["merged"] = newId;
    }
  });

  // Save new reports data to disk
  ReportManager.writeReports(allReports);

  // Add merge to merge list
  merges.add(merge);

  // Sort list by id (asc)
  merges.sort((Map a, Map b) => (a["id"] as int).compareTo(b["id"] as int));

  // Save new merges data to disk
  ReportManager.writeMerges(merges);
}