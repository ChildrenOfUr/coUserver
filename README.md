# `coUserver`

> Children of Ur's Dart-based web server

This repository contains the source code for Children of Ur's Dart-based web server.

[![Codeship Status for ChildrenOfUr/coUserver](https://codeship.com/projects/161f1540-0eea-0132-5580-469557c864a2/status?branch=master)](https://codeship.com/projects/32531)
[![codecov.io](https://codecov.io/github/ChildrenOfUr/coUserver/coverage.svg?branch=dev)](https://codecov.io/github/ChildrenOfUr/coUserver?branch=dev)

## License

Children of Ur is based on Tiny Speck's browser-based game, Glitch&trade;. The original game's elements have been released into the public domain.
For more information on the original game and its licensing information, visit <a href="http://www.glitchthegame.com" target="_blank">glitchthegame.com</a>.

License information for other assets used in Children of Ur can be found in `ATTRIBUTION.md`.

## Usage

The code is live at <a href="http://childrenofur.com" target="_blank">childrenofur.com</a>.

If you want to run it locally or on your own server, you'll need to have an environment with [Dart](https://www.dartlang.org/) installed. Note that this repository does not currently contain any prebuilt files, so you'll also need a development environment. See [Contributing](#contributing) below.

## Contributing

`coUserver` is based on [Dart](https://www.dartlang.org/), so the first thing you'll need to do (if you haven't already) is to install it.

### Setting up a development environment

#### Mac OS X / macOS via `homebrew`

1. `brew update`
2. `brew tap dart-lang/dart`
3. `brew install dart --with-content-shell --with-dartium`

#### Windows

1. Download the <a href="https://www.dartlang.org/">Dart Editor</a>.

### Building

#### In Dart Editor

1. Go to File -> "Open Existing Folder" and open this project folder.
2. Make sure you have the required dependencies specified in pubspec.yaml. If you're missing
   any of these, try selecting a file in the project, and then running Tools -> Pub Get.

#### Command line

1. `pub get`
2. `pub build`

### Running local

The server requires some configuration to be able to attach to external services
in a file named `lib/API_KEYS.dart`. There's a non-working example in the `lib`
directory named `API_KEYS.dart.example`. Contact one of the development team
for working values.

#### In Dart Editor

1. Right-click on `declarations.dart` and select Run.

If you do not have a signed cert and cert password, you will have to supply the
`--no-load-cert` option in the Dart Editor run configuration.

#### Command line

    dart declarations.dart

If you do not have a signed cert and cert password, you will have to add the
`--no-load-cert` option:

    dart declarations.dart --no-load-cert

#### But is it really running?

Load http://localhost:8181/serverStatus in a browser or using `curl` and you should see output like

    {"numPlayers":0,"playerList":[],"numStreetsLoaded":0,"streetsLoaded":[],"bytesUsed":0,"cpuUsed":29.4,"uptime":"0:00:29"}
