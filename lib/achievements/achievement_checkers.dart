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
					Log.warning('Missing TSID for $data');
					continue;
				}
				if (!(data['in_game'] ?? true)) {
					// Not possible to visit
					continue;
				}
				if (!locationHistory.contains(tsidL(data['tsid']))) {
					// Not visited
					return false;
				}
			}

			// Visited every street in hub
			return true;
		}

		String addedTsidHubId;
		try {
			addedTsidHubId = MapData.getStreetByTsid(addedTsid)['hub_id'].toString();
			if (addedTsidHubId == 'null') {
				throw new Exception('addedTsidHubId may not be null');
			}
		} catch (_) {
			Log.warning('Cannot find hub id for $addedTsid');
			return false;
		}

		if (_checkStreetsInHub(addedTsidHubId)) {
			try {
				AchievementCheckers.getCompletistIdForhub(addedTsidHubId).awardTo(email);
				return true;
			} catch (_) {
				Log.warning('Awarding completist <addedTsidHubId=$addedTsidHubId> to <email=$email> failed');
				return false;
			}
		} else {
			return false;
		}
	}
}
