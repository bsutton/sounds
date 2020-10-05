import 'package:sounds_platform_interface/sounds_platform_interface.dart';

/// Used by [AudioPlayer.audioFocus]
/// to control the focus mode.
enum AudioFocus {
  /// request focus and stop all other audio streams
  /// do not resume stream after abandon focus is called.
  stopOthersNoResume,

  /// request focus and stop other audio playing
  /// resume other audio stream abandon focus is called.
  stopOthersWithResume,

  /// request focus and reduce the volume of other players
  /// In the Android world this is know as 'Duck Others'.
  /// Unhush other audio streams when abandon focus is called
  hushOthersWithResume,

  /// android def. Not certain what it does.
  /// static const transient = 2;

}

/// Class to map the AudioFocus to an int.
class AudioFocusMode {
  /// Must be one of the defined static consts.
  int mode;

  /// Converts an AudioFocus enum to an int
  /// that can be passed down to the platform.
  AudioFocusMode(AudioFocus audioFocus) {
    switch (audioFocus) {
      case AudioFocus.stopOthersNoResume:
        mode = stopOthersNoResume;
        break;
      case AudioFocus.stopOthersWithResume:
        mode = stopOthersWithResume;
        break;
      case AudioFocus.hushOthersWithResume:
        mode = stopOthersWithResume;
        break;
    }
  }

  /// request focus and stop all other audio streams
  /// do not resume stream after abandon focus is called.
  /// static const stopOthers = 1;
  static const stopOthersNoResume = 1;

  /// request focus and stop other audio playing
  /// resume other audio stream abandon focus is called.
  /// static const transientExclusive = 4;
  static const stopOthersWithResume = 4;

  /// request focus and reduce the volume of other players
  /// In the Android world this is know as 'Duck Others'.
  /// Unhush other audio streams when abandon focus is called
  /// static const transientMayDuck = 3;
  static const hushOthersWithResume = 3;

  /// android def. Not certain what it does.
  /// static const transient = 2;

}

/// Helper to to prepare a AudioFocusProxy
class AudioFocusHelper {
  /// Converts an AudioFocus enum to an int
  /// that can be passed down to the platform.
  static AudioFocusProxy generate(AudioFocus audioFocus) {
    var proxy = AudioFocusProxy();

    switch (audioFocus) {
      case AudioFocus.stopOthersNoResume:
        proxy.audioFocusMode = stopOthersNoResume;
        break;
      case AudioFocus.stopOthersWithResume:
        proxy.audioFocusMode = stopOthersWithResume;
        break;
      case AudioFocus.hushOthersWithResume:
        proxy.audioFocusMode = stopOthersWithResume;
        break;
    }
    proxy.stopOthersNoResume = stopOthersNoResume;
    proxy.stopOthersWithResume = stopOthersWithResume;
    proxy.hushOthersWithResume = hushOthersWithResume;

    return proxy;
  }

  /// request focus and stop all other audio streams
  /// do not resume stream after abandon focus is called.
  /// static const stopOthers = 1;
  static const stopOthersNoResume = 1;

  /// request focus and stop other audio playing
  /// resume other audio stream abandon focus is called.
  /// static const transientExclusive = 4;
  static const stopOthersWithResume = 4;

  /// request focus and reduce the volume of other players
  /// In the Android world this is know as 'Duck Others'.
  /// Unhush other audio streams when abandon focus is called
  /// static const transientMayDuck = 3;
  static const hushOthersWithResume = 3;
}
