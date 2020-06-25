import 'codec.dart';
import 'native_media_format.dart';

/// The native ogg/vorbis media format.
class OGGVorbisMediaFormat extends NativeMediaFormat {
  /// ctor
  OGGVorbisMediaFormat({
    int sampleRate = 16000,
    int numChannels = 1,
    int bitRate = 16000,
  })
      : super.detail(
          name: 'ogg/vorbis',
          codec: Codec.OGG,
          sampleRate: 16000,
          numChannels: 1,
          bitRate: 16000,
        );
  @override
  String get extension => 'ogg';

  // MediaRecorder.AudioEncoder.VORBIS
  @override
  int get androidCodec => 6;

  @override
  // MediaRecorder.OutputFormat.OGG added in API level 29
  int get androidFormat => 11;

  @override
  int get iosFormat =>
      throw UnsupportedError('Ogg/Vorbise recording is not supported on iOS');
}
