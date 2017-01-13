part of coUserver;

@app.Group("/report")
class Report {
	static String issuesUrl = "ChildrenOfUr/cou-issues/issues";

	@app.Route("/add", methods: const [app.POST], allowMultipartRequest: true)
	Future addReport(@app.Body(app.FORM) Map data) async {
		if (KEYCHAIN.keys['githubToken'] == null) return;

		// Build the body of the report

		String body = "### ${data["username"]}";

		if (data["description"] != null && data["description"] != "") {
			body += "\n${data["description"]}\n";
		}

		if (data["useragent"] != null && data["useragent"] != "") {
			body += "\n### User Agent\n```\n${data["useragent"]}\n```";
		}

		if (data["log"] != null && data["log"] != "") {
			body += "\n### Log\n```\n${data["log"]}\n```";
		}

		if (data["image_url"] != null && data["image_url"] != "") {
			body += "\n### Attachment\n![](${data["image_url"]})";
		}

		// Get ready to send the data to GitHub

		if (data["title"] == null) {
			data["title"] = "Untitled issue";
		}

		Map assembleData = {
			"title": data["title"],
			"body": body,
			"labels": ["pending"]
		};

		if (data["category"] != null) {
			(assembleData["labels"] as List<String>).insert(0, data["category"]);
		}

		String sendData = JSON.encode(assembleData);

		// Send the data to GitHub

		Map<String, String> headers = {
			"Authorization": "token " + KEYCHAIN.keys['githubToken']
		};

		http.Response ghReturn = await http.post(
			"https://api.github.com/repos/$issuesUrl",
			headers: headers,
			body: sendData
		);

		Map ghReturnData = JSON.decode(ghReturn.body);
		int newIssueId = ghReturnData["number"];

		// Notify in Slack

		SlackReporter.sendBugReport(
			fallback: "New ${data["category"]}: https://github.com/$issuesUrl/${newIssueId.toString()}",
			title: data["title"],
			titleLink: "https://github.com/$issuesUrl/${newIssueId.toString()}",
			color: "#${ghReturnData["labels"][0]["color"]}",
			iconUrl: "data:image/png;base64,${await trimImage(data["username"])}",
			username: data["username"]
		);
	}
}
