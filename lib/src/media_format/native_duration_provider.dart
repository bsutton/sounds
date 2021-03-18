import '../sound_player.dart';

/// Provides a method to determine the duration of a natively supported
/// audio file.
class NativeDurationProvider {
  ///
  factory NativeDurationProvider() => _self;

  NativeDurationProvider._internal();

  static final NativeDurationProvider _self =
      NativeDurationProvider._internal();

  /// Returns the duration of the audio file at the given [path]
  /// for natively supported MediaFormats.
  Future<Duration> getDuration(String path) async =>
      SoundPlayer.noUI().duration(path);
}
