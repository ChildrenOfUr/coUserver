part of coUserver;

class Report {
	@Field() int id;
	@Field() String title;
	@Field() String description;
	@Field() String log;
	@Field() String useragent;
	@Field() String username;
	@Field() String email;
	@Field() String category;
	@Field() String image;
	@Field() DateTime date;
	@Field() bool done;
	@Field() int merged;
}

class Merge {
	@Field() int id;
	@Field() String title;
	@Field() String description;
	@Field() String category;
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
	Future addReport(@app.Body(app.FORM) Map data) async {

		String title = (data["title"] as String).trim().replaceAll("'", "''");
		String description = (data["description"] as String).trim().replaceAll("'", "''");
		String log = (data["log"] as String).trim().replaceAll("'", "''");
		String useragent = (data["useragent"] as String).trim().replaceAll("'", "''");
		String username = (data["username"] as String).trim().replaceAll("'", "''");
		String email = (data["email"] as String).trim().toLowerCase().replaceAll("'", "''");
		String category = (data["category"] as String).trim().toLowerCase().replaceAll("'", "''");
		String image = "";

		if (data["image"] != null && data["image"] != "") {
			image = CryptoUtils.bytesToBase64(data["image"].content);
		}

		String query = "INSERT INTO reports (title, description, log, useragent, username, email, category)";
		query += "VALUES('$title', '$description', '$log', '$useragent', '$username', '$email', '$category')";

		return await dbConn.execute(query);
	}

	// Get existing reports

	@app.Route('/list')
	Future listReports() async {
		return await dbConn.query("SELECT * FROM reports", Report);
	}

	// Mark a report as done

	@app.Route('/markDone')
	Future markReportDone(@app.QueryParam('id') int id) async {
		return await dbConn.execute("UPDATE reports SET done=true WHERE id=$id", String);
	}

	// Permanently delete a report

	@app.Route('/delete')
	Future deleteReport(@app.QueryParam('id') int id) async {
		return await dbConn.execute("DELETE FROM reports WHERE id=$id", String);
	}

	// Get existing merges

	@app.Route('/merge/list')
	Future<List<Map>> listMerges() async {
		return await dbConn.query("SELECT * FROM mergedreports", Map);
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
	Future markMergeDone(@app.QueryParam('id') int id) async {
		return await dbConn.execute("UPDATE mergedreports SET done=true WHERE id=$id");
	}

	@app.Route('/merge/delete')
	Future deleteMerge(@app.QueryParam('id') int id) async {
		return await dbConn.execute("DELETE FROM reports WHERE id=$id");
	}
}