import 'package:sounds/src/plugins/sound_player_plugin.dart';
import 'package:sounds_common/sounds_common.dart';

import '../sound_player.dart';

/// Base class for all Native Codecs.
abstract class NativeMediaFormat extends MediaFormat {
  NativeMediaFormat.detail({
    Codec codec,
    int sampleRate = 16000,
    int numChannels = 1,
    int bitRate = 16000,
  }) : super.detail(
          codec: codec,
          sampleRate: sampleRate,
          numChannels: numChannels,
          bitRate: bitRate,
        );

  /// gets the duration of a native codec.
  Future<Duration> _getNativeDuration(String path) {
    return SoundPlayer.noUI().duration(path);
  }

  /// A common media format supported by all platforms.
  /// You should use this format unless you have a specific
  /// reason to use an alternate format.
  ///
  /// Sounds only records/playbacks using natively supported codecs.
  /// Use the sounds_codec package for utilities to convert to/from
  /// other codecs.
  static MediaFormat common = AACMediaFormat();
}

/// The native aac media format.
class AACMediaFormat extends NativeMediaFormat {
  /// ctor
  AACMediaFormat() : super.detail(codec: Codec('aac'));
  @override
  Future<Duration> getDuration(String path) {
    return _getNativeDuration(path);
  }

  @override
  bool get isNative => true;
}
