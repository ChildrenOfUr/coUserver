part of coUserver;

abstract class ItemUser {
	static Random rand = new Random();

	static Future<bool> trySetMetabolics(String identity, {int energy:0, int mood:0, int img:0, int currants:0}) async {
		Metabolics m = new Metabolics();
		if (identity.contains("@")) {
			m = await getMetabolics(email:identity);
		} else {
			m = await getMetabolics(username:identity);
		}
		m.energy += energy;
		m.mood += mood;
		m.img += img;
		m.lifetime_img += img;
		m.currants += currants;
		int result = await setMetabolics(m);
		if (result < 1) {
			return false;
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