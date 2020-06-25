import 'codec.dart';
import 'native_media_format.dart';

/// A native media format
/// Codec: AAC
/// Format/Container: ADTS in an MPEG container.
///
/// Support by both ios and android
class AACADTSMediaFormat extends NativeMediaFormat {
  /// ctor
  const AACADTSMediaFormat({
    int sampleRate = 16000,
    int numChannels = 1,
    int bitRate = 16000,
  }) : super.detail(
          name: 'aac/adts',
          codec: Codec.AAC,
          sampleRate: 16000,
          numChannels: 1,
          bitRate: 16000,
        );

  @override
  String get extension => 'aac';

  // Whilst the actual index is MediaRecorder.AudioEncoder.AAC (3)
  // by using 0 (the default) we get around a bug in some older
  // versions of android. The default (0) equates to AAC.
  @override
  int get androidCodec => 0;

  /// MediaRecorder.OutputFormat.AAC_ADTS
  @override
  int get androidFormat => 6;

  /// kAudioFormatMPEG4AAC
  @override
  int get iosFormat => 1633772320;
}
