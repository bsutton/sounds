import '../../sounds.dart';
import 'native_media_format.dart';

/// The native wav media format.
class PCMMediaFormat extends NativeMediaFormat {
  /// ctor
  const PCMMediaFormat({
    int sampleRate = 16000,
    int numChannels = 1,
    int bitRate = 16000,
  }) : super.detail(
          name: 'pcm',
          sampleRate: sampleRate,
          numChannels: numChannels,
          bitRate: bitRate,
        );
  @override
  String get extension => 'pcm';

  /// 2 but not supported
  @override
  int get androidEncoder =>
      throw MediaFormatException('PCM recording is not supported on Android');

  @override
  int get androidFormat =>
      throw MediaFormatException('PCM recording is not supported on Android');

  /// kAudioFormatLinearPCM
  @override
  int get iosFormat => 1819304813;
}
