part of coUserver;

@app.Group("/report")
class Report {
	static String issuesUrl = "ChildrenOfUr/cou-issues/issues";

	/// For new bug report form that isn't in the game (yet?)
//	@app.Route("/add", methods: const [app.POST])
//	Future addReport(@app.Body(app.JSON) Map data) async {
//
//		// Token
//		final Map<String, String> headers = {
//			"Authorization": "token $githubToken"
//		};
//		// Data used in both cases (new and reply)
//		Map assembleData;
//		http.Response ghReturn;
//		slack.Attachment slackAttachment;
//
//		// Build the body of the report
//
//		String body = "### ${data["username"]}";
//
//		if (data["description"] != null && data["description"] != "") {
//			body += "\n${data["description"]}\n";
//		}
//
//		if (data["useragent"] != null && data["useragent"] != "") {
//			body += "\n### User Agent\n```\n${data["useragent"]}\n```";
//		}
//
//		if (data["log"] != null && data["log"] != "") {
//			body += "\n### Log\n```\n${data["log"]}\n```";
//		}
//
//		if (data["image_url"] != null && data["image_url"] != "") {
//			body += "\n### Attachment\n![](${data["image_url"]})";
//		}
//
//		// Build the metadata of the report
//
//		if (data["reply_to_issue"] == null) {
//			// New report?
//			// Get ready to send the data to GitHub
//
//			// Title
//			if (data["title"] == null) {
//				data["title"] = "Untitled issue";
//			}
//
//			// JSON
//			assembleData = {
//				"title": data["title"],
//				"body": body,
//				"labels": ["status: pending"]
//			};
//
//			// Labels
//			if (data["category"] != null) {
//				(assembleData["labels"] as List<String>).insert(0, "type: ${data["category"]}");
//			}
//
//			// Send
//			String sendData = JSON.encode(assembleData);
//			ghReturn = await http.post("https://api.github.com/repos/$issuesUrl", headers: headers, body: sendData);
//
//			// Return
//			Map ghReturnData = JSON.decode(ghReturn.body);
//			int newIssueId = ghReturnData["number"];
//
//			// Prepare slack message
//			slackAttachment = new slack.Attachment(
//				"New ${data["category"]}: https://github.com/$issuesUrl/${newIssueId.toString()}",
//				title: data["title"],
//				title_link: "https://github.com/$issuesUrl/${newIssueId.toString()}",
//				color: "#${ghReturnData["labels"][0]["color"]}"
//			);
//		} else {
//			// Comment on existing report
//			assembleData = {
//				"body": body
//			};
//
//			// Send
//			String sendData = JSON.encode(assembleData);
//			ghReturn = await http.post("https://api.github.com/repos/$issuesUrl/${data["reply_to_issue"]}/comments", headers: headers, body: sendData);
//
//			// Return
//			Map ghReturnData = JSON.decode(ghReturn.body);
//
//			http.Response issueResponse = await http.get("https://api.github.com/repos/$issuesUrl/${data["reply_to_issue"]}");
//			Map issueData = JSON.decode(issueResponse.body);
//
//			// Prepare slack message
//			slackAttachment = new slack.Attachment(
//				"New data on ${issueData["title"]} https://github.com/$issuesUrl/${issueData["number"].toString()}",
//				title: issueData["title"],
//				title_link: "https://github.com/$issuesUrl/${issueData["number"].toString()}",
//				color: "#207de5"
//			);
//		}
//
//		// Notify in Slack
//
//		slack.Message slackMessage = new slack.Message("")
//			..icon_url = "data:image/png;base64,${await trimImage(data["username"])}"
//			..username = data["username"]
//			..attachments = [slackAttachment];
//
//		new slack.Slack(slackReportWebhook).send(slackMessage);
//	}

	@app.Route("/add", methods: const [app.POST], allowMultipartRequest: true)
	Future addReport(@app.Body(app.FORM) Map data) async {

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
			"Authorization": "token $githubToken"
		};

		http.Response ghReturn = await http.post(
			"https://api.github.com/repos/$issuesUrl",
			headers: headers,
			body: sendData
		);

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