import '../../sounds.dart';
import 'native_media_format.dart';

/// The native mp3 media format.
class MP3MediaFormat extends NativeMediaFormat {
  /// ctor
  MP3MediaFormat({
    int sampleRate = 16000,
    int numChannels = 1,
    int bitRate = 16000,
  }) : super.detail(
          name: 'mp3',
          sampleRate: 16000,
          numChannels: 1,
          bitRate: 16000,
        );
  @override
  String get extension => 'mp3';

  // mp3 not supported on android.
  @override
  int get androidEncoder =>
      throw MediaFormatException('MP3 recording is not supported on android');

  @override
  int get androidFormat =>
      throw MediaFormatException('MP3 recording is not supported on android');

  @override
  int get iosFormat =>
      throw MediaFormatException('MP3 recording is not supported on iOS');
}
