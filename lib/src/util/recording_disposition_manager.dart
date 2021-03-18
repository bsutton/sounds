/*
 * This file is part of Sounds.
 *
 *   Sounds is free software: you can redistribute it and/or modify
 *   it under the terms of the Lesser GNU General Public License
 *   version 3 (LGPL3) as published by the Free Software Foundation.
 *
 *   Sounds is distributed in the hope that it will be useful,
 *   but WITHOUT ANY WARRANTY; without even the implied warranty of
 *   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *   GNU General Public License for more details.
 *
 *   You should have received a copy of the Lesser GNU General Public License
 *   along with Sounds.  If not, see <https://www.gnu.org/licenses/>.
 */

import 'dart:async';

import '../recording_disposition.dart';
import '../sound_recorder.dart';

/// An internal class which manages the RecordingDisposition stream.
/// Its main job is turn plugin updates into a stream.
class RecordingDispositionManager {
  /// ctor
  RecordingDispositionManager(this._recorder);

  final SoundRecorder _recorder;
  bool _streamCreated = false;
  late final StreamController<RecordingDisposition> _dispositionController;

  /// The duration between updates to the stream.
  /// Defaults to [10ms].
  Duration interval = const Duration(milliseconds: 10);

  /// We cache the last duration (length of recording) we have seen as
  /// its needed during wrap up.
  Duration lastDuration = Duration.zero;

  /// Returns a stream of RecordingDispositions
  /// The stream is a broadcast stream and can be called
  /// multiple times however the [interval] is shared between
  /// all stream.
  /// The [interval] sets the time between stream updates.
  /// This is the minimum [interval] and updates may be less
  /// frequent.
  /// Updates will stop if the recorder is paused.
  Stream<RecordingDisposition> stream({required Duration interval}) {
    var subscriptionRequired = false;
    if (!_streamCreated) {
      _dispositionController = StreamController.broadcast();
      _streamCreated = true;
      subscriptionRequired = true;
    }

    /// If the interval has changed then we need to re-subscribe.
    if (this.interval != interval) {
      subscriptionRequired = true;
    }
    this.interval = interval;

    // interval has changed or this is the first time througn
    if (subscriptionRequired) {
      recorderSetProgressInterval(_recorder, interval);
    }
    return _dispositionController.stream;
  }

  /// Sends a disposition if the [interval] has elapsed since
  /// we last sent the data.
  void updateDisposition(Duration duration, double decibels) {
    lastDuration = duration;
    assert(_streamCreated, 'The stream has not been created');
    _dispositionController.add(RecordingDisposition(duration, decibels));
  }

  /// Call this method once you have finished with the recording
  /// api so we can release any attached resources.
  void release() {
    _dispositionController
        // TODO signal that the stream is closed?
        // ..add(null) // We keep that strange line for backward compatibility
        .close();
  }
}
