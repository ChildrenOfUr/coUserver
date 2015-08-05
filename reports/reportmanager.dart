part of coUserver;

//TODO: use a database, not a JSON file
@app.Group('/report')
class ReportManager {

	// Globals

	DateTime currDate = new DateTime.now();
	Random rand = new Random();

	// Get Directory

	String get directory => Platform.script.toFilePath();
	String get reportsDirectory => directory.substring(0, directory.lastIndexOf('/'));

	// Access Files

	File get reportFile => new File("$reportsDirectory/reports/userdata/reports.json");

	File get mergeFile =>  new File("$reportsDirectory/reports/userdata/merged.json");

	// Read File Data

	Future<List<Map>> getReports() async {
		String json = await reportFile.readAsString();
		if (json == "" || json == null) {
			json = "[]";
		}
		return JSON.decode(json);
	}

	Future<List<Map>> getMerges() async {
		String json = await mergeFile.readAsString();
		if (json == "" || json == null) {
			json = "[]";
		}
		return JSON.decode(json);
	}

	// Write File Data

	Future writeReports(List<Map> reports) async {
		reportFile.writeAsString(JSON.encode(reports));
	}

	Future writeMerges(List<Map> merges) async {
		reportFile.writeAsString(JSON.encode(merges));
	}

	// Insert a report

	@app.Route("/add", methods: const [app.POST], allowMultipartRequest: true)
	Future addReport(@app.Body(app.FORM) Map data) async {

		// Get existing reports
		List<Map> existingReports = await getReports();

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
				"year": currDate.year,
				"month": currDate.month,
				"day": currDate.day
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
		await writeReports(existingReports);
	}

	// Get existing reports

	@app.Route('/list')
	Future<List<Map>> listReports() async {
		return await getReports();
	}

	// Mark a report as done

	@app.Route('/markDone')
	Future markReportDone(@app.QueryParam('id') int id) async {
		List<Map> reports = await getReports();
		if (reports.where((Map reportMap) => reportMap["id"] == id).toList().length > 0) {
			Map report = reports.where((Map reportMap) => reportMap["id"] == id).toList().first;
			report["done"] = true;
			reports.removeWhere((Map reportMap) => reportMap["id"] == id);
			reports.add(report);
			reports.sort((Map a, Map b) => (a["id"] as int).compareTo(b["id"] as int));
			writeReports(reports);
		}
	}

	// Permanently delete a report

	@app.Route('/delete')
	Future deleteReport(@app.QueryParam('id') int id) async {
		List<Map> reports = await getReports();
		List<Map> report = reports.where((Map reportMap) => reportMap["id"] == id).toList();
		if (report.length > 0) {
			reports.removeWhere((Map reportMap) => reportMap["id"] == id);
			await writeReports(reports);
		}
	}

	// Get existing merges

	@app.Route('/merge/list')
	Future<List<Map>> listMerges() async {
		return await getMerges();
	}

	// Merge reports

	@app.Route('/merge/add')
	Future mergeReport(
		@app.QueryParam('ids') String idList,
		@app.QueryParam('title') String title,
		@app.QueryParam('description') String description
		) async {

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
		List<Map> merges = await getMerges();

		// Read existing reports
		List<Map> allReports = await getReports();

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
		await writeReports(allReports);

		// Add merge to merge list
		merges.add(merge);

		// Sort list by id (asc)
		merges.sort((Map a, Map b) => (a["id"] as int).compareTo(b["id"] as int));

		// Save new merges data to disk
		await writeMerges(merges);
	}
}