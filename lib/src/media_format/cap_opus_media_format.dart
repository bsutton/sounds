import 'native_media_format.dart';

/// The native opus/caff media format.
///
/// MediaFormat: opus
/// Format/Container: Caf
/// iOS Only
class OpusCafMediaFormat extends NativeMediaFormat {
  /// ctor
  const OpusCafMediaFormat({
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
  int get androidCodec =>
      throw UnsupportedError('Opus is not supported on android');

  @override
  int get androidFormat =>
      throw UnsupportedError('Caf is not supported on android');

  @override
  // kAudioFormatOpus
  int get iosFormat => 1869641075;
}
