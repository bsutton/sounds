// Provides additional functionality required when recording
import 'dart:io';

import 'package:path/path.dart';
import 'package:sounds_common/sounds_common.dart';

import '../sound_recorder.dart';

/// a track.
class RecordingTrack {
  ///
  Track track;

  /// The codec that we will use when asking the OS to
  /// record.
  /// The OS doesn't support all codec so we sometimes have
  /// to record in some native codec and then remux the
  /// recording to the codec required by the Track.
  Codec nativeCodec;

  /// The path we will be recording to.
  /// This is often the same as [track.file] unless
  /// we need to record to a different codec and then remux
  /// the file after recording finishes.
  String recordingPath;

  /// Create a [RecordingTrack] fro a [Track].
  ///
  /// The recording track causes recording to use a native codec
  /// if the requested codec is not supported.
  ///
  /// When [recode] is called the recording is transcoded to the
  /// originally requested codec. If the requested codec was
  /// supported by the OS then remix just returns.
  ///
  RecordingTrack(this.track) {
    ArgumentError.checkNotNull(track, 'track');

    if (!track.isFile) {
      ArgumentError("Only Tracks created via [Track.fromFile] are supported");
    }

    if (!this.track.mediaFormat.isNative) {
      ArgumentError('You can only record to a Track which use a natively '
          'supported Codec and Container');
    }

    nativeCodec = track.codec;
    recordingPath = track.path;

    if (FileUtil().exists(recordingPath)) {
      FileUtil().truncate(recordingPath);
    }
  }

  /// Used by the [SoundRecorder] to update the [Track]'s duration
  /// as the track is recorded into.
  //ignore: avoid_setters_without_getters
  set duration(Duration duration) {
    setTrackDuration(track, duration);
  }

  /// Check that the target recording path is valid
  void validatePath() {
    /// the directory where we are recording to MUST exist.
    if (!FileUtil().directoryExists(dirname(track.path))) {
      throw DirectoryNotFoundException(
          'The directory ${dirname(track.path)} must exists');
    }
  }

  /// Release all system resources for the track.
  void release() {
    if (track != null) {
      trackRelease(track);
    }
  }
}
