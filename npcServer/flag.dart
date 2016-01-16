part of coUserver;

class PlayerPosition extends harvest.Message {
	String email;
	num x,y;

	PlayerPosition(this.email, this.x, this.y);
}

class Flag {
	String id;
	num x,y;

	Flag(this.id, this.x, this.y) {
		print("I'm a flag at $x,$y");
		messageBus.subscribe(PlayerPosition, (PlayerPosition position) {
			if(_approx(x,position.x) && _approx(y,position.y)) {
				messageBus.publish(new RequirementProgress('flag', position.email));
			} else {
				print('not close enough: ${position.x},${position.y}');
			}
		});
	}

	bool _approx(num compare, num to) {
		return (compare - to).abs() < 10;
	}
}