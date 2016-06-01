part of coUserver;

/**
 * Username colors are always represented as 7-character strings.
 * They must include the #, followed by 6 digits in base 16.
 *
 * A value of # without any following digits indicates an unset value,
 * and the algorithm for generating colors based on username character
 * codes should be used instead.
 */

@app.Group("/usernamecolors")
class UsernameColors {
  /// Returns the color in form #FFFFFF for a user with the provided username.
  @app.Route("/get/:username")
  Future<String> get(String username) async {
    // Handle URL encodings (eg. " " is "%20" in the string)
    username = Uri.decodeComponent(username);

    // Default value
    String hex = "#";

    // Connect to database
    try {
      // Find username_color for username
      String query = "SELECT username_color FROM users WHERE lower(username) = lower(@username)";

      // Results
      List<Map<String, dynamic>> hexes = await dbConn.query(query, String, {
        "username": username
      });

      // At least 1 row (should only be 1)
      if (hexes.length >= 1) {
        String returnedHex = hexes.first["username_color"];
        // Return result
        if (returnedHex.trim() != "#") {
          // Value provided
          hex = returnedHex;
        } else {
          // No value provided (default # present)
          // Revert to old color generator
          hex = getByChars(username);
        }
      } else {
        // Nothing returned
        // Revert to old color generator
        hex = getByChars(username);
      }
    } catch (e) {
      // Log error message for investigation
      log("Unable to get username color for $username: $e");
    } finally {
      // Return result (all uppercase)
      return hex.trim().toUpperCase();
    }
  }

  /// Updates the color (provided in form 0xFFFFFF) for the user with the provided email.
  /// Returns whether it was successful (bool)
  @app.Route("/set/:email/:hex")
  Future<bool> set(String email, String hex) async {
    // Validate hex input
    if (!hex.trim().startsWith("0x") || hex.trim().length != 8) {
      // Invalid hex (must be in form 0xFFFFFF,
      // not starting with # because of page ID hashes)
      return false;
    }

    // Only the numbers, all upper case, no prefixes
    String nekkidHex = hex.replaceFirst("0x", "").toUpperCase();

    try {
      // Try to parse int to prevent injection risks
      int.parse(nekkidHex, radix: 16);
    } on FormatException catch (e) {
      log("Cannot use invalid hex $nekkidHex as username color for <email=$email>: $e");
      // Invalid hex value (possibly a malicious SQL command?)
      return false;
    } catch (e) {
      // Unknown error
      return false;
    }

    // Connect to database
    bool success = false;
    try {
      // Update username_color for user with email
      String query = "UPDATE users SET username_color = @hex WHERE email = @email";

      // Results
      int result = await dbConn.execute(query, {
        "hex": "#$nekkidHex",
        "email": email
      });

      // 1 row changed?
      success = (result == 1);
    } catch (e) {
      // Log error message for investigation
      log("Unable to set username color to $nekkidHex for <email=$email>: $e");
    } finally {
      // Return result
      return success;
    }
  }

  /// Returns the HTML color name for the provided username.
  /// Used if their hex color is not set.
  @app.Route("/getbychars/:username")
  String getByChars(String username) {
    final List<String> COLORS = [
      "blue",
      "deepskyblue",
      "fuchsia",
      "gray",
      "green",
      "olivedrab",
      "maroon",
      "navy",
      "olive",
      "orange",
      "purple",
      "red",
      "teal"
    ];

    int index = 0;
    for (int i = 0; i < username.length; i++) {
      index += username.codeUnitAt(i);
    }

    return COLORS[index % (COLORS.length - 1)];
  }
}
