part of coUserver;

class Identifier
{
	List<String> channelList = [];
	String username, email, currentStreet, tsid;
	//String undeadTSID;
	num currentX = 1.0, currentY = 0.0;
	WebSocket webSocket;
	//bool dead = false, outOfHell = true;
	Identifier (this.username,this.currentStreet,this.tsid,this.webSocket) {
		//getEmail(username);
	}

//	getEmail(String username) async {
//		PostgreSql db = await dbManager.getConnection();
//		await db.query("SELECT email FROM users WHERE username='$username'", String).then((List<String> rows) => email = rows.first["email"]);
//		dbManager.closeConnection(db);
//	}
}