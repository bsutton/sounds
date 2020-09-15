import '../../sounds.dart';
import 'native_media_format.dart';

/// The native ogg/vorbis media format.
class OggVorbisMediaFormat extends NativeMediaFormat {
  /// ctor
  OggVorbisMediaFormat({
    int sampleRate = 16000,
    int numChannels = 1,
    int bitRate = 16000,
  }) : super.detail(
          name: 'ogg/vorbis',
          sampleRate: sampleRate,
          numChannels: numChannels,
          bitRate: bitRate,
        );
  @override
  String get extension => 'ogg';

  // MediaRecorder.AudioEncoder.VORBIS
  @override
  int get androidEncoder => 6;

  @override
  // MediaRecorder.OutputFormat.OGG added in API level 29
  int get androidFormat => 11;

  @override
  int get iosFormat => throw MediaFormatException(
      'Ogg/Vorbise recording is not supported on iOS');
}
