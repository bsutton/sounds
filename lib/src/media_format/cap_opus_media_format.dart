import '../../sounds.dart';
import 'native_media_format.dart';

/// The native opus/caff media format.
///
/// MediaFormat: caf/opus
/// Codec: opus
/// Format/Container: Caf
/// iOS Only
class CafOpusMediaFormat extends NativeMediaFormat {
  /// ctor
  const CafOpusMediaFormat({
    int sampleRate = 16000,
    int numChannels = 1,
    int bitRate = 16000,
  }) : super.detail(
          name: 'caf/opus',
          sampleRate: 16000,
          numChannels: 1,
          bitRate: 16000,
        );
  @override
  String get extension => 'caf';

  // CAF is not supported on android
  @override
  int get androidEncoder =>
      throw MediaFormatException('Opus is not supported on android');

  @override
  int get androidFormat =>
      throw MediaFormatException('Caf is not supported on android');

  @override
  // kAudioFormatOpus
  int get iosFormat => 1869641075;
}
