// AUTOMATICALLY GENERATED. DO NOT EDIT.

import 'dart:ffi';
import 'package:sounds/src/ios/frameworks/audiofile/audiofile.dart';

/// Dynamic library
final DynamicLibrary _dynamicLibrary = DynamicLibrary.open(
  '/home/tsutton/Projects/swift/sounds_ios/AudioToolbox.framework/Headers/AudioFile.h',
);

/// C function `AudioFileGetProperty`.
// int AudioFileGetProperty(
//   AudioFileID arg0,
//   AudioFilePropertyID arg1,
//   Uint32Arg arg2,
//   void arg3,
// ) {
//   return _AudioFileGetProperty(arg0, arg1, arg2.value, arg3);
// }

int AudioFileGetProperty(
  AudioFileID arg0,
  AudioFilePropertyID arg1,
  Pointer<Uint32> arg2,
  Pointer<void> arg3,
) {
  return _AudioFileGetProperty(arg0, arg1, arg2, arg3);
}

final _AudioFileGetProperty_Dart _AudioFileGetProperty = _dynamicLibrary
    .lookupFunction<_AudioFileGetProperty_C, _AudioFileGetProperty_Dart>(
  'AudioFileGetProperty',
);

typedef _AudioFileGetProperty_C = Int16 Function(
  AudioFileID arg0,
  AudioFilePropertyID arg1,
  Pointer<Uint32> arg2,
  Pointer<void> arg3,
);
typedef _AudioFileGetProperty_Dart = int Function(
  AudioFileID arg0,
  AudioFilePropertyID arg1,
  Pointer<Uint32> arg2,
  Pointer<void> arg3,
);

// typedef _AudioFileGetProperty_C = Int16 Function(
//   AudioFileID arg0,
//   AudioFilePropertyID arg1,
//   Uint32 arg2,
//   Void arg3,
// );
// typedef _AudioFileGetProperty_Dart = int Function(
//   AudioFileID arg0,
//   AudioFilePropertyID arg1,
//   int arg2,
//   void arg3,
// );
