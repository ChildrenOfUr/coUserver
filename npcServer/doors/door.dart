part of coUserver;

class Door extends Entity {
  String id, type, toLocation;
  bool outside;
  Spritesheet currentState;

  Door(String id, String streetName, int x, int y) {
    type = "Door";
  }

  void enter({WebSocket userSocket, String email}) {
    useDoor(userSocket:userSocket, email:email);
  }

  void exit({WebSocket userSocket, String email}) {
    useDoor(userSocket:userSocket, email:email);
  }

  void useDoor({WebSocket userSocket, String email}) {
    Map map = {}
      ..["gotoStreet"] = "true"
      ..["tsid"] = toLocation;
    userSocket.add(JSON.encode(map));
  }
}