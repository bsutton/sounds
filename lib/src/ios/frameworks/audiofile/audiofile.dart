import 'dart:ffi';

import 'package:dart_native/dart_native.dart';
import 'package:sounds/src/ios/frameworks/avfoundation/cfurl.dart';

class AudioFileTypeID extends Struct {
  @Uint32()
  final int id;
  AudioFileTypeID(this.id);
}

class AudioFilePropertyID {
  final String value;
  AudioFilePropertyID(this.value);
  static AudioFilePropertyID kAudioFilePropertyEstimatedDuration =
      AudioFilePropertyID('edur');
}

class AudioFileID extends Struct {}

class AudioFilePermissions {
  @Int8()
  final int value;
  AudioFilePermissions(this.value);
  static AudioFilePermissions kAudioFileReadPermission =
      AudioFilePermissions(0x01);
  static AudioFilePermissions kAudioFileReadWritePermission =
      AudioFilePermissions(0x03);
  static AudioFilePermissions kAudioFileWritePermission =
      AudioFilePermissions(0x02);
}

//Dont like that this is extending NSObject
// class AudioFileMethods extends NSObject {
//   ///Returns an OSStatus which is just an error code hence the cast to an int

//   int AudioFileOpenURL(CFURLRef inFileRef, AudioFilePermissions inPermissions,
//       AudioFileTypeID inFileTypeHint, AudioFileID outAudioFileDef) {
//     return perform(SEL('AudioFileOpenURL'), args: <dynamic>[
//       inFileRef,
//       inPermissions,
//       inFileTypeHint,
//       outAudioFileDef.addressOf
//     ]) as int;
//   }
// }

// AudioFileOpenURL (	CFURLRef							inFileRef,
// 					AudioFilePermissions				inPermissions,
// 					AudioFileTypeID						inFileTypeHint,
// 					AudioFileID	__nullable * __nonnull	outAudioFile)
