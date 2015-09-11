part of coUserver;

@app.Group("/report")
class Report {
	static String issuesUrl = "ChildrenOfUr/cou-issues/issues";

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

		if (data["title"] == null) {
			data["title"] = "Untitled issue";
		}

		Map assembleData = {
			"title": data["title"],
			"body": body,
			"labels": ["status: pending"]
		};

		if (data["category"] != null) {
			(assembleData["labels"] as List<String>).insert(0, data["category"]);
		}

		String sendData = JSON.encode(assembleData);

		// Send the data to GitHub

		Map<String, String> headers = {
			"Authorization": "token $githubToken"
		};

		http.Response ghReturn = await http.post("https://api.github.com/repos/$issuesUrl", headers: headers, body: sendData);

		int newIssueId = JSON.decode(ghReturn.body)["number"];

		// Notify in Slack

		slack.Slack slackWebhook = new slack.Slack(slackReportWebhook);
		slack.Message slackMessage = new slack.Message(
			"New ${data["category"]}: ${data["title"]}"
			"\nhttps://github.com/$issuesUrl/${newIssueId.toString()}"
		);
		slackWebhook.send(slackMessage);
	}
}