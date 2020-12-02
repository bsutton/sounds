import 'dart:ffi';

import 'package:sounds/src/ios/frameworks/avfoundation/cfurl.dart';

import 'audiofile.dart';

/// Dynamic library
final DynamicLibrary _dynamicLibrary = DynamicLibrary.open(
  '/home/tsutton/Projects/swift/sounds_ios/AudioToolbox.framework/Headers/AudioFile.h',
);

/// C function `AudioFileOpenURL`.
int AudioFileOpenURL(
  CFURLRef inFileRef,
  AudioFilePermissions inPermissions,
  AudioFileTypeID inFileTypeHint,
  AudioFileID outAudioFileDef,
) {
  var result = _AudioFileOpenURL(
      inFileRef, inPermissions, inFileTypeHint, outAudioFileDef);
  return result;
}

final _AudioFileOpenURL_Dart _AudioFileOpenURL =
    _dynamicLibrary.lookupFunction<_AudioFileOpenURL_C, _AudioFileOpenURL_Dart>(
  'AudioFileOpenURL',
);

typedef _AudioFileOpenURL_C = Int16 Function(
  CFURLRef inFileRef,
  AudioFilePermissions inPermissions,
  AudioFileTypeID inFileTypeHint,
  AudioFileID outAudioFileDef,
);
typedef _AudioFileOpenURL_Dart = int Function(
  CFURLRef inFileRef,
  AudioFilePermissions inPermissions,
  AudioFileTypeID inFileTypeHint,
  AudioFileID outAudioFileDef,
);
