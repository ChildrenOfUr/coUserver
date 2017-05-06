part of coUserver;

@app.Group('/report')
class Report {
	static String issuesUrl = 'ChildrenOfUr/cou-issues/issues';
	static final bool SendToGithub = true;
	static final bool SendToImgur = true;

	@app.Route('/add', methods: const [app.POST], allowMultipartRequest: true)
	Future addReport(@app.Body(app.FORM) Map data) async {
		// Build the body of the report

		String body = '### ${data['username']}';

		if (data['description'] != null && data['description'] != '') {
			body += '\n${data['description']}\n';
		}

		if (data['useragent'] != null && data['useragent'] != '') {
			body += '\n### User Agent\n```\n${data['useragent']}\n```';
		}

		if (data['ping'] != null && data['ping'] != '') {
			body += '\n### Ping\n${data['ping']}\n';
		}

		if (data['screen'] != null && data['screen'] != null) {
			body += '\n### Window\n${data['screen']}\n';
		}

		if (data['log'] != null && data['log'] != '') {
			body += '\n### Log\n```\n${data['log']}\n```';
		}

		// Get ready to send the data to GitHub

		if (data['title'] == null) {
			data['title'] = 'Untitled issue';
		}

		Map assembleData = {
			'title': data['title'],
			'body': body,
			'labels': ['pending']
		};

		if (data['category'] != null) {
			(assembleData['labels'] as List<String>).insert(0, data['category']);
		}

		if (SendToImgur && data['screenshot'] != null) {
			Map<String, dynamic> image = await uploadToImgur(data['screenshot']);

			if (image['success']) {
				assembleData['body'] += '\n### Screenshot\n![](${image['data']['link']})';
			}
		}

		if (SendToGithub) {
			Map<String, dynamic> issue = await createIssue(assembleData);
			int newIssueId = issue['number'];

			// Print issue number to server log for easier client/server log pairing during investigation
			Log.info('<username=${data['username']}> reported <issue=$newIssueId>');

			// Notify in Slack
			SlackReporter.sendBugReport(
				fallback: 'New ${data['category']}: https://github.com/$issuesUrl/$newIssueId',
				title: data['title'],
				titleLink: 'https://github.com/$issuesUrl/$newIssueId',
				color: '#${issue['labels'][0]['color']}',
				iconUrl: 'data:image/png;base64,${await trimImage(data['username'])}',
				username: data['username']
			);
		} else {
			Log.debug('Test bug report: $assembleData');
		}
	}

	// Submits an issue to GitHub
	Future<Map<String, dynamic>> createIssue(Map<String, dynamic> issue) async {
		String sendData = JSON.encode(issue);

		http.Response ghReturn = await http.post(
			'https://api.github.com/repos/$issuesUrl',
			headers: { 'Authorization': 'token $githubToken' },
			body: sendData
		);

		return JSON.decode(ghReturn.body);
	}

	// Upload screenshot to Imgur
	Future<Map<String, dynamic>> uploadToImgur(String base64image) async {
		http.Response imgurReturn = await http.post(
			'https://api.imgur.com/3/upload',
			headers: { 'Authorization': 'Client-ID ' + imgurClientId },
			body: {
				'image': base64image,
				'type': 'base64'
			}
		);

		Map<String, dynamic> image = JSON.decode(imgurReturn.body);

		if (!image['error']) {
			Log.info('Uploaded screenshot <id=${image['data']['id']}> and <deletehash=${image['data']['deletehash']}>');
		}

		return image;
	}

	// For new bug report form that isn't in the game (yet?)
	/*
	@app.Route('/add', methods: const [app.POST])
	Future addReport(@app.Body(app.JSON) Map data) async {

		// Token
		final Map<String, String> headers = {
			'Authorization': 'token $githubToken'
		};
		// Data used in both cases (new and reply)
		Map assembleData;
		http.Response ghReturn;
		slack.Attachment slackAttachment;

		// Build the body of the report

		String body = '### ${data['username']}';

		if (data['description'] != null && data['description'] != '') {
			body += '\n${data['description']}\n';
		}

		if (data['useragent'] != null && data['useragent'] != '') {
			body += '\n### User Agent\n```\n${data['useragent']}\n```';
		}

		if (data['log'] != null && data['log'] != '') {
			body += '\n### Log\n```\n${data['log']}\n```';
		}

		if (data['image_url'] != null && data['image_url'] != '') {
			body += '\n### Attachment\n![](${data['image_url']})';
		}

		// Build the metadata of the report

		if (data['reply_to_issue'] == null) {
			// New report?
			// Get ready to send the data to GitHub

			// Title
			if (data['title'] == null) {
				data['title'] = 'Untitled issue';
			}

			// JSON
			assembleData = {
				'title': data['title'],
				'body': body,
				'labels': ['status: pending']
			};

			// Labels
			if (data['category'] != null) {
				(assembleData['labels'] as List<String>).insert(0, 'type: ${data['category']}');
			}

			// Send
			String sendData = JSON.encode(assembleData);
			ghReturn = await http.post('https://api.github.com/repos/$issuesUrl', headers: headers, body: sendData);

			// Return
			Map ghReturnData = JSON.decode(ghReturn.body);
			int newIssueId = ghReturnData['number'];

			// Prepare slack message
			slackAttachment = new slack.Attachment(
				'New ${data['category']}: https://github.com/$issuesUrl/${newIssueId.toString()}',
				title: data['title'],
				title_link: 'https://github.com/$issuesUrl/${newIssueId.toString()}',
				color: '#${ghReturnData['labels'][0]['color']}'
			);
		} else {
			// Comment on existing report
			assembleData = {
				'body': body
			};

			// Send
			String sendData = JSON.encode(assembleData);
			ghReturn = await http.post('https://api.github.com/repos/$issuesUrl/${data['reply_to_issue']}/comments', headers: headers, body: sendData);

			// Return
			Map ghReturnData = JSON.decode(ghReturn.body);

			http.Response issueResponse = await http.get('https://api.github.com/repos/$issuesUrl/${data['reply_to_issue']}');
			Map issueData = JSON.decode(issueResponse.body);

			// Prepare slack message
			slackAttachment = new slack.Attachment(
				'New data on ${issueData['title']} https://github.com/$issuesUrl/${issueData['number'].toString()}',
				title: issueData['title'],
				title_link: 'https://github.com/$issuesUrl/${issueData['number'].toString()}',
				color: '#207de5'
			);
		}

		// Notify in Slack

		slack.Message slackMessage = new slack.Message('')
			..icon_url = 'data:image/png;base64,${await trimImage(data['username'])}'
			..username = data['username']
			..attachments = [slackAttachment];

		new slack.Slack(slackReportWebhook).send(slackMessage);
	}
	*/
}
