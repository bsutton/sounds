// AUTOMATICALLY GENERATED. DO NOT EDIT.

import 'dart:ffi' as ffi;

import 'audiofile.dart';

/// Dynamic library
final ffi.DynamicLibrary _dynamicLibrary = ffi.DynamicLibrary.open(
  '/home/tsutton/Projects/swift/sounds_ios/AudioToolbox.framework/Headers/AudioFile.h',
);

/// C function `AudioFileClose`.
int AudioFileClose(
  AudioFileID arg0,
) {
  return _AudioFileClose(arg0);
}

final _AudioFileClose_Dart _AudioFileClose =
    _dynamicLibrary.lookupFunction<_AudioFileClose_C, _AudioFileClose_Dart>(
  'AudioFileClose',
);
typedef _AudioFileClose_C = ffi.Int16 Function(
  AudioFileID arg0,
);
typedef _AudioFileClose_Dart = int Function(
  AudioFileID arg0,
);
