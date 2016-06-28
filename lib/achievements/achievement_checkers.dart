part of achievements;

class AchievementCheckers {
	static Achievement getCompletistIdForhub(String hubId) {
		try {
			String hubName = MapData.hubs[hubId.toString()]['name'];
			hubName = hubName.toLowerCase().replaceAll(' ', '_');
			return Achievement.find('${hubName}_completist');
		} catch (e, st) {
			Log.error('Failed getting completist achv id for <hubId=$hubId>', e, st);
			return new Achievement();
		}
	}

	// Checks if the addedTsid completes a hub
	static bool hubCompletion(List<String> locationHistory, String email, String addedTsid) {
		bool _checkStreetsInHub(String hubId) {
			for (Map<String, dynamic> data in MapData.getStreetsInHub(hubId)) {
				if (data['tsid'] == null) {
					continue;
				}

				bool gVisited = locationHistory.contains(tsidG(data['tsid']));
				bool lVisited = locationHistory.contains(tsidL(data['tsid']));

				if (!gVisited && !lVisited) {
					// Neither TSID version visited
					return false;
				}
			}

			// Visited every street in hub
			return true;
		}

		String addedTsidHubId;
		try {
			addedTsidHubId = MapData.getStreetByTsid(addedTsid)['hub_id'].toString();
		} catch (e) {
			Log.warning('Cannot find hub id for $addedTsid');
			return false;
		}

		if (_checkStreetsInHub(addedTsidHubId)) {
			try {
				AchievementCheckers.getCompletistIdForhub(addedTsidHubId).awardTo(email);
				return true;
			} catch (e) {
				Log.warning('Awarding completist <addedTsidHubId=$addedTsidHubId> to <email=$email>');
				return false;
			}
		} else {
			return false;
		}
	}
}
