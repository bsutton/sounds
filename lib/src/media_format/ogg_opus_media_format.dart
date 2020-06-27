import 'native_media_format.dart';

/// The native Ogg/Opus media format.
class OpusOggMediaFormat extends NativeMediaFormat {
  /// ctor
  const OpusOggMediaFormat({
    int sampleRate = 16000,
    int numChannels = 1,
    int bitRate = 16000,
  }) : super.detail(
          name: 'ogg/opus',
          sampleRate: 16000,
          numChannels: 1,
          bitRate: 16000,
        );

  @override
  String get extension => 'opus';

  // MediaRecorder.AudioEncoder.OPUS
  @override
  int get androidCodec => 7;

  @override

  /// MediaRecorder.OutputFormat.OGG
  int get androidFormat => 11;

  @override
  int get iosFormat =>
      throw UnsupportedError('Ogg/Opus recording is not supported on iOS');
}
