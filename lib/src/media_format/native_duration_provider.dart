import 'package:sounds_common/sounds_common.dart';

import '../sound_player.dart';

/// Provides a method to determine the duration of a natively supported
/// audio file.
class NativeDurationProvider implements DurationProvider {
  static final _self = NativeDurationProvider._internal();
  @override
  MediaFormat mediaFormat;

  @override
  String package;

  @override
  int priority;

  /// Provides support for obtaining the durations of an Natively
  /// supported MediaFormat.
  factory NativeDurationProvider() => _self;

  NativeDurationProvider._internal()
  {
    _register();
  }

  @override
  Future<Duration> getDuration(String path) async {
    if (!await mediaFormat.isNativeDecoder) {
      throw MediaFormatException(
          'This format is not native on this OS/SDK version');
    }
    return SoundPlayer.noUI().duration(path);
  }

  void _register() {
    DurationProviders().registerProvider(NativeDurationProvider());
  }
}
