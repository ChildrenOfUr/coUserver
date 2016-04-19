part of item;

abstract class ItemUser {
	static Random rand = new Random();

	static Future<bool> trySetMetabolics(String username, {int energy:0, int mood:0, int img:0, int currants:0}) async {
		// Read in metabolics data
		Metabolics m = await getMetabolics(username: username);

		// Store "before" img
		int oldImg = m.lifetime_img;

		// Update metabolics with new values
		m.energy += energy;
		m.mood += mood;
		m.img += img;
		m.lifetime_img += img;
		m.currants += currants;

		// Write out changes
		int result = await setMetabolics(m);

		// Failed
		if (result < 1) {
			return false;
		}

		// Compare "after" and "before" img
		if (getLevel(m.lifetime_img) > getLevel(oldImg)) {
			// Level up
			MetabolicsEndpoint.userSockets[username].add(JSON.encode({
				"levelUp": getLevel(m.lifetime_img)
			}));
		}

		return true;
	}

	static Future<int> getEnergy(String identity) async {
		Metabolics m = new Metabolics();
		if (identity.contains("@")) {
			m = await getMetabolics(email:identity);
		} else {
			m = await getMetabolics(username:identity);
		}
		return m.energy;
	}

	static Future<int> getMood(String identity) async {
		Metabolics m = new Metabolics();
		if (identity.contains("@")) {
			m = await getMetabolics(email:identity);
		} else {
			m = await getMetabolics(username:identity);
		}
		return m.mood;
	}
}