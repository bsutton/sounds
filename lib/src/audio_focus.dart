/// Used by [AudioPlayer.audioFocus]
/// to control the focus mode.
enum AudioFocus {
//NOTE auto focus calls hushOthersWithResume and automatically abandons focus

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

  /// relinquish the audio focus.
  abandonFocus,
}
