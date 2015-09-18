part of coUserver;

abstract class Entity {
	List<Map> actions = [];
	int actionTime = 2500;
	String bubbleText;
	DateTime sayTimeout = null;
	Map<String, List<String>> responses = {};
	Map<String, int> gains = {'energy':0, 'mood':0, 'img':0, 'currants':0};
	Random rand = new Random();

	void setActionEnabled(String action, bool enabled) {
		try {
			for(Map actionMap in actions) {
				if(actionMap['action'] == action) {
					actionMap['enabled'] = enabled;
					return;
				}
			}
		}
		catch(e) {
			log("error enabling/disabling action $action: $e");
		}
	}

	Map getMap() {
		Map map = {};
		if(bubbleText != null) {
			map['bubbleText'] = bubbleText;
			map['gains'] = gains;
		}
		return map;
	}

	Future<bool> trySetMetabolics(String email, {int energy:0, int mood:0, int imgMin:0, int imgRange:0, int currants:0}) async {
		_resetGains();

		Metabolics m = await getMetabolics(email:email);
		if(m.energy != 0 && m.energy < energy.abs()) {
			return false;
		} else {
			m.energy += energy;
			m.mood += mood;
			int baseImg = 0;
			if (imgRange > 0) {
				baseImg = rand.nextInt(imgRange) + imgMin;
			}
			int resultImg = (baseImg * m.mood / m.max_mood)~/1;
			m.img += resultImg;
			m.lifetime_img += resultImg;
			gains['energy'] = energy;
			gains['mood'] = mood;
			gains['img'] = resultImg;
			gains['currants'] = currants;

			int result = await setMetabolics(m);
			if(result < 1) {
				return false;
			}
		}

		return true;
	}

	void _resetGains() {
		gains = {'energy':0, 'mood':0, 'img':0, 'currants':0};
	}

	void say(String message) {
		if(message == null || message.trim() == '')
			return;

		DateTime now = new DateTime.now();
		if(sayTimeout == null || sayTimeout.compareTo(now) < 0) {
			bubbleText = message;
			int timeToLive = message.length * 30 + 3000; //minimum 3s plus 0.3s per character
			if(timeToLive > 10000) //max 10s
				timeToLive = 10000;
			//messages over 10s will only display for 10s

			Duration messageDuration = new Duration(milliseconds:timeToLive);
			sayTimeout = now.add(messageDuration);
			new Timer(messageDuration, () {
				bubbleText = null;
				_resetGains();
			});
		}
	}
}