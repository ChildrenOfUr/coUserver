part of coUserver;

class Report {
	@Field() int id,merged;
	@Field() String title,description,log,useragent;
	@Field() String username,email,category,image;
	@Field() DateTime date;
	@Field() bool done;

	Report();
	Report.fromData(this.title, this.description, this.log, this.useragent, this.username, this.email, this.category, this.image, this.date, [this.done = false, this.merged = -1]);
}

class MergeModel {
	@Field() int id;
	@Field() String title,description,category;
	@Field() String reports;
	@Field() bool done;
}

class MergeView {
	MergeView.fromModel(MergeModel model) {
		this.id = model.id;
		this.title = model.title;
		this.description = model.description;
		this.category = model.category;
		this.reports = JSON.decode(model.reports);
		this.done = model.done;
	}
	@Field() int id;
	@Field() String title,description,category;
	@Field() List<int> reports;
	@Field() bool done;
}

@app.Group('/report')
class ReportManager {

	// Globals

	DateTime currDate = new DateTime.now();

	Random rand = new Random();

	// Insert a report

	@app.Route("/add", methods: const [app.POST], allowMultipartRequest: true)
	Future<int> addReport(@app.Body(app.FORM) Map data) async {
		if (data["image"] != null && data["image"] != "") {
			data['image'] = CryptoUtils.bytesToBase64(data["image"].content);
		}

		String query = "INSERT INTO reports (title, description, log, useragent, username, email, category, image)";
		query += "VALUES(@title, @description, @log, @useragent, @username, @email, @category, @image)";

		return await dbConn.execute(query,data);
	}

	// Get existing reports

	@app.Route('/list')
	@Encode()
	Future<List<Report>> listReports() async {
		return await dbConn.query("SELECT * FROM reports", Report);
	}

	// Mark a report as done

	@app.Route('/markDone')
	Future<int> markReportDone(@app.QueryParam('id') int id) async {
		return await dbConn.execute("UPDATE reports SET done=true WHERE id=$id");
	}

	// Permanently delete a report

	@app.Route('/delete')
	Future<int> deleteReport(@app.QueryParam('id') int id) async {
		return await dbConn.execute("DELETE FROM reports WHERE id=$id");
	}

	// Get existing merges

	@app.Route('/merge/list')
	@Encode()
	Future<List<MergeView>> listMerges() async {
		List<MergeModel> merges = await dbConn.query("SELECT * FROM mergedreports", MergeModel);
		List<MergeView> views = [];
		merges.forEach((MergeModel merge) {
			views.add(new MergeView.fromModel(merge));
		});
		return views;
	}

	// Merge reports

	@app.Route('/merge/add')
	Future<int> mergeReport(
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
			return -1;
		}

		// Figure out which category to use (majority of the reports, or bug if equal)
		List<String> categories = await dbConn.query("SELECT category FROM reports WHERE ", String);
		// TODO: WHERE ids (above) contains report id in row
		int bug = 0, suggestion = 0;
		String category;
		categories.forEach((String category) {
			if (category == "bug") bug++;
			if (category == "suggestion") suggestion++;
		});
		if (suggestion > bug) {
			category = "suggestion";
		} else {
			category = "bug";
		}

		String query = "INSERT INTO mergedreports (title, description, category, reports)";
		query += " VALUES('$title', '$description', '$category', '$ids'";
		return dbConn.execute(query);

		// TODO: set the value of 'merged' for each report to the new id of this merge
	}

	@app.Route('/merge/markDone')
	Future<int> markMergeDone(@app.QueryParam('id') int id) async {
		return await dbConn.execute("UPDATE mergedreports SET done=true WHERE id=$id");
	}

	@app.Route('/merge/delete')
	Future<int> deleteMerge(@app.QueryParam('id') int id) async {
		return await dbConn.execute("DELETE FROM reports WHERE id=$id");
	}

	@app.Route('/convertToDB')
	Future convertToDB() async {
		String directory = Platform.script.toFilePath();
		String reportsDirectory = directory.substring(0, directory.lastIndexOf('/'));
		File reportFile = new File("$reportsDirectory/reports/userdata/reports.json");
		List<Map> reports = JSON.decode(reportFile.readAsStringSync());
		reports.forEach((Map report) async {
			Report reportObj = new Report.fromData(
				report["title"],
				report["description"],
				report["log"],
				report["useragent"],
				report["username"],
				report["email"],
				report["category"],
				report["image"],
				new DateTime(report["date"]["year"], report["date"]["month"], report["date"]["day"]),
				report["done"],
				-1
			);
			String query = "INSERT INTO reports (title, description, log, useragent, username, email, category, image, date, done)";
			query += "VALUES(@title, @description, @log, @useragent, @username, @email, @category, @image, @date, @done)";
			await dbConn.execute(query, reportObj);
		});
	}
}