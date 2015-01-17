#Children of Ur Web Server#

##What is this?##
This repository contains the source code for Children of Ur's Dart-based application server.
The project is currently hosted at <a href="http://childrenofur.com" target="_blank">childrenofur.com</a>.

Children of Ur is based on Tiny Speck's browser-based game, Glitch™. The original game's elements have been released into the public domain.
For more information on the original game and its licensing information, visit <a href="http://www.glitchthegame.com" target="_blank">glitchthegame.com</a>.

##Getting Started##
1. Download the <a href="https://www.dartlang.org/">Dart Editor</a>
2. In the Dart Editor, go to File -> "Open Existing Folder" and open this project folder
3. Make sure you have the required dependencies specified in pubspec.yaml. If you're missing
any of these, try selecting a file in the project, and then running Tools > Pub Get.

##Testing##
To test the project, you will have to build an 'API_KEYS.dart' file in the top-level
folder. Directions can be found in the developer docs <a href="https://github.com/ChildrenOfUr/coUclient/blob/master/doc/api.md" target="_blank">here.</a>

In order to echo global messages to our Slack channel, the server expects an environment variable called "irc_pass" to be set up in 
~/.profile. This password should correspond to the one given on this page: https://cou.slack.com/account/gateways 

[ ![Codeship Status for ChildrenOfUr/coUserver](https://www.codeship.io/projects/161f1540-0eea-0132-5580-469557c864a2/status)](https://www.codeship.io/projects/32531)
