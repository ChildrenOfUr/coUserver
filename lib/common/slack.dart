library slackreporter;

import "package:coUserver/API_KEYS.dart";
import "package:slack/io/slack.dart";

class SlackReporter {
	/// userfeedback
	static final Slack SLACK = new Slack(slackReportWebhook);

	/// Send a text message
	static void sendMessage({
		String text,
		String username: "Server",
		String iconEmoji: ":control_knobs:",
		String iconUrl
	}) {
		Message message = new Message(text, username: username, icon_emoji: iconEmoji, icon_url: iconUrl);
		SLACK.send(message);
	}

	/// Send a formatted bug report link
	static void sendBugReport({
		String fallback: "Server Message",
		String title,
		String titleLink,
		String color,
		String iconUrl,
		String username: "Server"
	}) {
		Attachment attachment = new Attachment(
			fallback, title: title, title_link: titleLink, color: color
		);

		Message message = new Message("")
			..icon_url = iconUrl
			..username = username
			..attachments = [attachment];

		SLACK.send(message);
	}
}
