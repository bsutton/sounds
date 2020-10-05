#! /usr/bin/env dcli

import 'package:dcli/dcli.dart';

/// Script to regenerate the pigeon interfaces.
void main() {
  var project = DartProject.fromPath('.', search: true);
  print(green('Generating platform api'));
  'pub get'.start(workingDirectory: project.pathToProjectRoot);
  'pub run pigeon --input pigeon/sounds_platform_api.dart'
      .start(workingDirectory: project.pathToProjectRoot);
  print(orange('Generating complete'));
}
