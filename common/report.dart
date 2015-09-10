part of coUserver;

@app.Group("/report")
class Report {
	static String reportUrl = "https://api.github.com/repos/ChildrenOfUr/cou-issues/issues";

	@app.Route("/add", methods: const [app.POST], allowMultipartRequest: true)
	Future addReport(@app.Body(app.FORM) Map data) async {

		// Build the body of the report

		String body = "### ${data["username"]}";

		if (data["description"] != null) {
			body += "\n${data["description"]}\n";
		}

		if (data["useragent"] != null) {
			body += "\n### User Agent\n```\n${data["useragent"]}\n```";
		}

		if (data["log"] != null) {
			body += "\n### Log\n```\n${data["log"]}```";
		}

		// Get ready to send the data to GitHub

		Map assembleData = {
			"title": data["title"],
			"body": body,
			"labels": ["type: ${data["category"]}", "status: pending"]
		};

		String sendData = JSON.encode(assembleData);

		// Send the data to GitHub

		Map<String, String> headers = {
			"Authorization": "token $githubToken"
		};

		await http.post(reportUrl, headers: headers, body: sendData);
	}
}