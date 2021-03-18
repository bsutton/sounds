import 'package:sounds_common/sounds_common.dart';

/// [RecordedAudio] is used to track the audio media
/// created during a recording session via the SoundRecorderUI.
///
class RecordedAudio {
  /// Creates a [RecordedAudio] that will store
  /// the recording to the given track.
  RecordedAudio.recordTo(this.track);

  /// The length of the recording (so far)
  Duration duration = Duration.zero;

  /// The track we are recording audio intto.
  Track track;
}
