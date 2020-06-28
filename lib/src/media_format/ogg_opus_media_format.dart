import 'package:sounds_common/sounds_common.dart';

import 'native_media_format.dart';

/// The native Ogg/Opus media format.
class OggOpusMediaFormat extends NativeMediaFormat {
  /// ctor
  const OggOpusMediaFormat({
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
  int get androidEncoder => 7;

  @override

  /// MediaRecorder.OutputFormat.OGG
  int get androidFormat => 11;

  @override
  int get iosFormat =>
      throw MediaFormatException('Ogg/Opus recording is not supported on iOS');
}
