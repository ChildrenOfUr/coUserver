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

`coUserver` is written in [Dart](https://www.dartlang.org/), so the first thing you'll need to do (if you haven't already) is to install it.

### Set up a development environment

#### Install Dart

- [Linux](https://www.dartlang.org/install/linux)
- [Windows](https://www.dartlang.org/install/windows)
- [Mac OS](https://www.dartlang.org/install/mac)

#### Install an IDE of your choice

- [Atom](https://atom.io/) is free, just make sure to install the [dartlang](https://atom.io/packages/dartlang) package.
- [WebStorm](https://www.jetbrains.com/webstorm/) is not free, but includes Dart support.

### Get dependencies

You'll only need to do this when you first get the code, and later on if we update the dependencies (pubspec.yaml changes).

1. Run `pub get` from the server directory.
2. Sit back and wait a few minutes.

### Run locally

The server requires some configuration to be able to attach to external services in a file named `lib/API_KEYS.dart`. There's a non-working example in the `lib` directory named `API_KEYS.dart.example`. Contact someone on the development team for working values.

`dart declarations.dart --no-load-cert`

#### But is it really running?

Load http://localhost:8181/serverStatus in a browser or using `curl` and you should see output like

```json
{"numPlayers":0,"playerList":[],"numStreetsLoaded":0,"streetsLoaded":[],"bytesUsed":0,"cpuUsed":29.4,"uptime":"0:00:29"}
```
