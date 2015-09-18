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
			(assembleData["labels"] as List<String>).insert(0, "type: ${data["category"]}");
		}

		String sendData = JSON.encode(assembleData);

		// Send the data to GitHub

		Map<String, String> headers = {
			"Authorization": "token $githubToken"
		};

		http.Response ghReturn = await http.post("https://api.github.com/repos/$issuesUrl", headers: headers, body: sendData);

		Map ghReturnData = JSON.decode(ghReturn.body);
		int newIssueId = ghReturnData["number"];

		// Notify in Slack

		slack.Attachment slackAttachment = new slack.Attachment(
			"New ${data["category"]}: https://github.com/$issuesUrl/${newIssueId.toString()}",
			title: data["title"],
			title_link: "https://github.com/$issuesUrl/${newIssueId.toString()}",
			color: "#${ghReturnData["labels"][0]["color"]}"
		);

		slack.Message slackMessage = new slack.Message("")
			..icon_url = "data:image/png;base64,${await trimImage(data["username"])}"
			..username = data["username"]
			..attachments = [slackAttachment];

		new slack.Slack(slackReportWebhook).send(slackMessage);
	}
}