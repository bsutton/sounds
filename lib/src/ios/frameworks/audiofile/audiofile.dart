import 'dart:ffi';

// ignore_for_file: public_member_api_docs
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
