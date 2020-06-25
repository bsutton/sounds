import 'package:sounds_common/sounds_common.dart';

import '../sound_player.dart';

/// Provides a method to determine the duration of a natively supported
/// audio file.
class NativeDurationProvider implements DurationProvider {
  @override
  MediaFormat mediaFormat;

  @override
  String package;

  @override
  int priority;

  @override
  Future<Duration> getDuration(String path) async {
    if (!await mediaFormat.isNativeDecoder) {
      throw MediaFormatNotSupportedException(
          'This format is not native on this OS/SDK version');
    }
    return SoundPlayer.noUI().duration(path);
  }
}
