part of coUserver;

class AchievementCheckers {
	static Achievement getCompletistIdForhub(String hubId) {
		switch (hubId) {
			case "76":	return Achievement.find("alakol_completist");
			case "89":	return Achievement.find("andra_completist");
			case "101":	return Achievement.find("aranna_completist");
			case "128":	return Achievement.find("balzare_completist");
			case "86":	return Achievement.find("baqala_completist");
			case "98":	return Achievement.find("besara_completist");
			case "75":	return Achievement.find("bortola_completist");
			case "112":	return Achievement.find("brillah_completist");
			case "107":	return Achievement.find("callopee_completist");
			case "120":	return Achievement.find("cauda_completist");
			case "72":	return Achievement.find("chakra_phool_completist");
			case "90":	return Achievement.find("choru_completist");
			case "141":	return Achievement.find("drifa_completist");
			case "123":	return Achievement.find("fenneq_completist");
			case "114":	return Achievement.find("firozi_completist");
			case "119":	return Achievement.find("folivoria_completist");
			case "56":	return Achievement.find("groddle_forest_completist");
			case "64":	return Achievement.find("groddle_heights_completist");
			case "58":	return Achievement.find("groddle_meadow_completist");
			case "131":	return Achievement.find("haoma_completist");
			case "116":	return Achievement.find("haraiva_completist");
			case "50":	return Achievement.find("ilmenskie_caverns_completist");
			case "78":	return Achievement.find("ilmenskie_deeps_completist");
			case "27":	return Achievement.find("ix_completist");
			case "136":	return Achievement.find("jal_completist");
			case "71":	return Achievement.find("jethimadh_completist");
			case "85":	return Achievement.find("kajuu_completist");
			case "99":	return Achievement.find("kalavana_completist");
			case "88":	return Achievement.find("karnata_completist");
			case "133":	return Achievement.find("kloro_completist");
			case "105":	return Achievement.find("lida_completist");
			case "110":	return Achievement.find("massadoe_completist");
			case "97":	return Achievement.find("muufo_completist");
			case "40":	return Achievement.find("naraka_completist");
			case "137":	return Achievement.find("nottis_completist");
			case "102":	return Achievement.find("ormonos_completist");
			case "106":	return Achievement.find("pollokoo_completist");
			case "109":	return Achievement.find("rasana_completist");
			case "126":	return Achievement.find("roobrik_completist");
			case "93":	return Achievement.find("salatu_completist");
			case "140":	return Achievement.find("samudra_completist");
			case "63":	return Achievement.find("shimla_mirch_completist");
			case "121":	return Achievement.find("sura_completist");
			case "113":	return Achievement.find("tahli_completist");
			case "92":	return Achievement.find("tamila_completist");
			case "51":	return Achievement.find("uralia_completist");
			case "100":	return Achievement.find("vantalu_completist");
			case "95":	return Achievement.find("xalanga_completist");
			case "91":	return Achievement.find("zhambu_completist");
			default:	return new Achievement();
			// The default achievement (for hubs without one) will have null data, but it will
			// silently refuse to run .awardTo() and .awardedTo() (immediately returns false)
		}
	}

	// Checks if the addedTsid completes a hub
	static bool hubCompletion(List<String> locationHistory, String email, String addedTsid) {
		bool _checkStreetsInHub(String hubId) {
			List<Map<String, dynamic>> streetsInHub = mapdata_streets.values.where((
			  Map streetData) {
				if (streetData["hub_id"] == null) {
					if (streetData["tsid"] != null) {
						log("Missing hub id for street with TSID ${streetData["tsid"]}");
					}
					return false;
				} else {
					return (streetData["hub_id"].toString() == hubId);
				}
			}).toList();

			for (Map<String, dynamic> data in streetsInHub) {
				String tsid = data["tsid"] ?? "";
				String tsidG = (tsid.startsWith("L") ? tsid.replaceFirst("L", "G") : tsid);
				String tsidL = (tsid.startsWith("G") ? tsid.replaceFirst("G", "L") : tsid);

				if (!(locationHistory.contains(tsidG) || locationHistory.contains(tsidL))) {
					// Neither TSID version visited
					return false;
				}
			}

			// Visited every street in hub
			return true;
		}

		String addedTsidHubId = mapdata_streets.values.singleWhere((Map streetData) {
			return (streetData["tsid"] != null && streetData["tsid"] == addedTsid);
		})["hub_id"].toString();

		if (addedTsidHubId == null) {
			log("Missing hub id for street with TSID $addedTsid");
			return false;
		} else {
			if (_checkStreetsInHub(addedTsidHubId)) {
				AchievementCheckers.getCompletistIdForhub(addedTsidHubId).awardTo(email);
				return true;
			} else {
				return false;
			}
		}
	}
}