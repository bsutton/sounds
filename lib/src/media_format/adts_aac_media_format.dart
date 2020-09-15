import 'native_media_format.dart';

/// A native media format
/// MediaFormat: adts/aac
/// Format/Container: ADTS in an MPEG container.
///
/// Support by both ios and android
class AdtsAacMediaFormat extends NativeMediaFormat {
  /// ctor
  const AdtsAacMediaFormat({
    int sampleRate = 16000,
    int numChannels = 1,
    int bitRate = 16000,
  }) : super.detail(
          name: 'adts/aac',
          sampleRate: sampleRate,
          numChannels: numChannels,
          bitRate: bitRate,
        );

  @override
  String get extension => 'aac';

  // Whilst the actual index is MediaRecorder.AudioEncoder.AAC (3)
  @override
  int get androidEncoder => 3;

  /// MediaRecorder.OutputFormat.AAC_ADTS
  @override
  int get androidFormat => 6;

  /// kAudioFormatMPEG4AAC
  @override
  int get iosFormat => 1633772320;
}
