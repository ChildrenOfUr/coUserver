# Map Data JSON

## Street & Hub data options

These can be used in both `streetdata.json` and `hubdata.json`. If a street specifies the same key as the hub containing it, the street's value is used.

### Required

- `music` `(string, example = "forest")` The song to play from SoundCloud.
- `physics` `(string, example = "plexus")` The type of physics to use. Physics are defined in the client.

### Optional

- `broken` `(bool, default = false)` Adds a "Rescue Me" button to the client in this location.
- `disable_weather` `(bool, default = false)` Prevents rain/snow from rendering.
- `map_hidden` `(bool, default = false)` Skip rendering this on the map.
- `players_have_letters` `(bool, default = false)` Displays a random letter over players in the location.
- `snowy_weather` `(bool, default = false)` When it rains, it snows.

## Street data options

These can be used in `streetdata.json`.

### Required

- `hub_id` `(int, example = 113)` The ID of the hub containing the street.
- `tsid` (string, example = "LA5101HF7F429V5")` The TSID of the street, in L/TS form.

### Optional

- `bureaucratic_hall` `(bool, default = false)` Displays a gavel on the hub map.
- `disallow_bound_expansion` `(bool, default = false)` Shrinks the game viewport to the minimum size, rather than fitting to the browser window.
- `in_game` `(bool, default = true)` Whether asset files exist for the street, allowing it to be visited.
- `machine_room` `(bool, default = false)` Displays a machine symbol on the hub map.
- `mailbox` `(bool, default = false)` Displays an envelope on the hub map.
- `minimap_expand` `(bool, default = true)` Allows the client minimap to expand.
- `minimap_objects` `(bool, default = true)` Allows the client to display entity locations on the minimap.
- `shrine` `(string, example = "Lem")` Displays a shrine icon on the hub map with the name of the giant.
- `subway_station` `(bool, default = false)` Displays a subway icon on the hub map.
- `vendor` `(string, example = "Tool")` Displays a currant icon on the hub map with the name of the vendor.

## Hub data options

These can be used in `hubdata.json`.

### Required

- `name` `(string, example = "Alakol")` The name of the hub.

### Optional

- `color` `(string, example = "#591f73")` The color to use for the GO circles on the hub map.
- `color_btm` `(string, example = "#464949")` The bottom of the loading screen gradient.
- `color_top` `(string, example = "#9eaa9c")` The top of the loading screen gradient.
- `img_bg` `(string, url)` The background image of the hub map, displayed behind the streets.
- `img_fg` `(string, url)` The foreground image of the hub map, displayed in front of the streets.
- `mote_id` `(int, example = 10)` The Tiny Speck realm ID.
- `mote_name` `(string, example = "Ur")` The Tiny Speck realm name.
- `owm_city_id` `(int, example = 1259813)` The OpenWeatherMap city ID to use for game weather.
- `savanna` `(bool, default = false)` Enables a time limit and buff/debuff for the region.
- `x` `(int, required if !map_hidden && in_game)` The X coordinate of the hitbox on the world map.
- `y` `(int, required if !map_hidden && in_game)` The Y coordinate of the hitbox on the world map.