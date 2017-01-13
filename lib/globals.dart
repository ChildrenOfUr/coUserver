library globals;
import 'dart:io';
import 'dart:async';
import 'dart:convert';

// TODO REPLACE ME with a per-client token Andy.
// currently hard coded on the client.
String clientToken = 'ud6He9TXcpyOEByE944g';

class KEYCHAIN {
  // Map of loaded keys.
  static Map keys = {};
  
  static bool loaded = false;

  static Future load() async {
    if (!loaded) {
      String json = await new File('API_KEYS.json').readAsString();
      Map jsonMap = JSON.decode(json);
      for (String key in jsonMap.keys) {
        keys[key] = jsonMap[key];
      }
      loaded = true;
    }
  }
}
