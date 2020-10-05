/*
 * This file is part of Sounds .
 *
 *   Sounds  is free software: you can redistribute it and/or modify
 *   it under the terms of the Lesser GNU General Public License
 *   version 3 (LGPL3) as published by the Free Software Foundation.
 *
 *   Sounds  is distributed in the hope that it will be useful,
 *   but WITHOUT ANY WARRANTY; without even the implied warranty of
 *   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *   GNU General Public License for more details.
 *
 *   You should have received a copy of the Lesser GNU General Public License
 *   along with Sounds .  If not, see <https://www.gnu.org/licenses/>.
 */

import 'dart:async';
import 'dart:core';

import 'package:sounds_common/sounds_common.dart';
import 'package:sounds_platform_interface/sounds_platform_interface.dart';
import 'package:uuid/uuid.dart';

import '../sounds.dart';
import 'audio_source.dart';

import 'media_format/native_media_format.dart';
import 'media_format/native_media_formats.dart';
import 'plugins/app_life_cycle_observer.dart';
import 'quality.dart';
import 'recording_disposition.dart';
import 'util/recording_disposition_manager.dart';
import 'util/recording_track.dart';

/// The [requestPermissions] callback allows you to provide an
/// UI informing the user that we are about to ask for a permission.
///
typedef RequestPermission = Future<bool> Function(Track track);

typedef RecorderEventWithCause = void Function({bool wasUser});

enum _InternalRecorderState {
  preinitialisation,
  initialised,
  recording,
  stopped,
  paused
}

/// Provide an API for recording audio.
class SoundRecorder {
  final String _uuid = Uuid().v4();
  final _plugin = SoundsToPlatformApi();

  SoundRecorderProxy _proxy;

  final AppLifeCycleObserver _lifeCycleObserver = AppLifeCycleObserver();

  RecorderEventWithCause _onPaused;
  RecorderEventWithCause _onResumed;
  RecorderEventWithCause _onStarted;
  RecorderEventWithCause _onStopped;

  RecordingDispositionManager _dispositionManager;

  /// [SoundRecorder] calls the [onRequestPermissions] callback
  /// to give you a chance to grant the necessary permissions.
  ///
  /// The [onRequestPermissions] method is called just before recording
  /// starts (just after you call [record]).
  ///
  /// You may also want to pop a dialog
  /// explaining to the user why the permissions are being requested.
  ///
  /// If the required permissions are not in place then the recording will fail
  /// and an exception will be thrown.
  ///
  /// Return true if the app has the permissions and you want recording to
  /// continue.
  ///
  /// Return [false] if the app does not have the desired permissions.
  /// The recording will not be started if you return false and no
  /// error/exception will be returned from the [record] call.
  ///
  /// At a minimum SoundRecorder requires access to the microphone
  /// and possibly external storage if the recording is to be placed
  /// on external storage.
  RequestPermission onRequestPermissions;

  /// track the total time we hav been paused during
  /// the current recording player.
  var _timePaused = Duration(seconds: 0);

  /// If we have paused during the current recording player this
  /// will be the time
  /// the most recent pause commenced.
  DateTime _pauseStarted;

  /// The track we are recording to.
  RecordingTrack _recordingTrack;

  /// If true then the recorder will continue to record
  /// even if the app is pushed to the background.
  ///
  /// If false the recording will stop if the app is pushed
  /// to the background.
  /// Unlike the [SoundPlayer] the [SoundRecorder] will NOT
  /// resume recording when the app is resumed.
  final bool _playInBackground;

  _InternalRecorderState _internalRecorderState =
      _InternalRecorderState.preinitialisation;

  /// Create a [SoundRecorder] to record audio.
  ///

  SoundRecorder({bool playInBackground = false})
      : _playInBackground = playInBackground {
    _proxy = SoundRecorderProxy();
    _proxy.uuid = _uuid;

    _lifeCycleObserver.onSystemAppPaused = _onSystemAppPaused;
    _lifeCycleObserver.onSystemAppResumed = _onSystemAppResumed;
    _dispositionManager = RecordingDispositionManager(this);
  }

  Future<void> _initialize() async {
    if (_internalRecorderState == _InternalRecorderState.preinitialisation) {
      await _plugin.initializeRecorder(_proxy);
      _internalRecorderState = _InternalRecorderState.initialised;
    }
  }

  /// Call this method when you have finished with the recorder
  /// and want to release any resources the recorder has attached.
  Future<void> release() async {
    if (_internalRecorderState == _InternalRecorderState.preinitialisation) {
      throw RecorderInvalidStateException(
          'The recorder is no longer registered. '
          'Did you call release() twice?');
    }
    _dispositionManager.release();

    if (isRecording) {
      await stop();
    }
    _recordingTrack?.release();
    await _plugin.releaseRecorder(_proxy);
  }

  /// Future indicating if initialisation has completed.
  bool get isInitialized =>
      _internalRecorderState != _InternalRecorderState.preinitialisation;

  /// Starts the recorder recording to the
  /// passed in [Track].
  ///
  /// At this point the track MUST have been created via
  /// the [Track.fromFile] constructor.
  ///
  /// You must have permission to write to the path
  /// indicated by the Track and permissions to
  /// access the microphone.
  ///
  /// see: [onRequestPermissions] to get a callback
  /// as the recording is about to start.
  ///
  /// Support of recording to a databuffer is planned for a later
  /// release.
  ///
  /// The [track]s file will be truncated and over-written.
  ///
  ///```dart
  /// var track = Track.fromFile('fred.mpeg');
  ///
  /// var recorder = SoundRecorder();
  /// recorder.onStopped = ({wasUser}) {
  ///   recorder.release();
  ///   // playback the recording we just made.
  ///   QuickPlay.fromTrack(track);
  /// });
  /// recorder.record(track);
  /// ```
  /// The [audioSource] is currently only supported on android.
  /// For iOS the source is always the microphone.
  /// The [quality] is currently only supported on iOS.
  ///
  /// Throws [MediaFormatException] if you pass in a [Track]
  /// that doesn't have a [NativeMediaFormat].
  Future<void> record(
    Track track, {
    AudioSource audioSource = AudioSource.mic,
    Quality quality = Quality.low,
  }) async {
    if (track.mediaFormat == null) {
      throw MediaFormatException("The [Track] must have a [NativeMediaFormat] "
          "specified for it's [mediaFormat]");
    }

    if (!(track.mediaFormat is NativeMediaFormat)) {
      throw MediaFormatException(
          'Only [NativeMediaFormat]s can be used when recording');
    }

    /// We must not already be recording.
    if (isRecording) {
      throw RecorderInvalidStateException('Recorder is already recording.');
    }

    if (!track.isFile) {
      throw RecorderException(
          "Only file based tracks are supported. Used Track.fromFile().");
    }

    await _initialize();

    _recordingTrack =
        RecordingTrack(track, track.mediaFormat as NativeMediaFormat);

    /// Throws an exception if the path isn't valid.
    _recordingTrack.validatePath();

    /// the MediaFormat must be supported.
    if (!await NativeMediaFormats()
        .isNativeEncoder(_recordingTrack.track.mediaFormat)) {
      throw MediaFormatException('MediaFormat not supported.');
    }

    // we assume that we have all necessary permissions
    var hasPermissions = true;

    if (onRequestPermissions != null) {
      hasPermissions = await onRequestPermissions(track);
    }

    if (hasPermissions) {
      _timePaused = Duration(seconds: 0);

      var args = StartRecording();
      args.recorder = _proxy;

      /// should we be passing down the recording track?
      args.track = trackProxy(track);
      args.audioSource = AudioSourceHelper.generate(audioSource);
      args.quality = QualityHelper.generate(quality);

      await _plugin.startRecording(args);
      _internalRecorderState = _InternalRecorderState.recording;

      if (_onStarted != null) _onStarted(wasUser: true);
    } else {
      Log.d('Call to SoundRecorder.record() failed as '
          'onRequestPermissions() returned false');
    }
  }

  /// returns true if we are recording.
  bool get isRecording =>
      _internalRecorderState == _InternalRecorderState.recording;

  /// returns true if the record is stopped.
  bool get isStopped => !isRecording;

  /// returns true if the recorder is paused.
  bool get isPaused => _internalRecorderState == _InternalRecorderState.paused;

  /// Returns a stream of [RecordingDisposition] which
  /// provides live updates as the recording proceeds.
  /// The [RecordingDisposition] items contain the duration
  /// and decibel level of the recording at the point in
  /// time that it is sent.
  /// Set the [interval] to control the time between each
  /// event. [interval] defaults to 10ms.
  Stream<RecordingDisposition> dispositionStream(
      {Duration interval = const Duration(milliseconds: 10)}) {
    return _dispositionManager.stream(interval: interval);
  }

  /// Stops the current recording.
  /// An exception is thrown if the recording can't be stopped.
  ///
  /// [stopRecording] is also responsible for recode'ing the recording
  /// for some codecs which aren't natively support. Dependindig on the
  /// size of the file this could take a few moments to a few minutes.
  Future<void> stop() async {
    if (isStopped) {
      throw RecorderNotRunningException(
          "You cannot stop recording when the recorder is not running.");
    }

    await _plugin.stopRecording(_proxy);

    _internalRecorderState = _InternalRecorderState.stopped;

    /// send final db so any listening UI is reset.
    _dispositionManager.updateDisposition(_dispositionManager.lastDuration, 0);

    if (_onStopped != null) _onStopped(wasUser: true);
  }

  /// Pause recording.
  /// The recording must be recording when this method is called
  /// otherwise an [RecorderNotRunningException]
  Future<void> pause() async {
    if (!isRecording) {
      throw RecorderNotRunningException(
          "You cannot pause recording when the recorder is not running.");
    }

    await _plugin.pauseRecording(_proxy);
    _pauseStarted = DateTime.now();
    _internalRecorderState = _InternalRecorderState.paused;
    if (_onPaused != null) _onPaused(wasUser: true);
  }

  /// Resume recording.
  /// The recording must be paused when this method is called
  /// otherwise a [RecorderNotPausedException] will be thrown.
  Future<void> resume() async {
    if (!isPaused) {
      throw RecorderNotPausedException(
          "You cannot resume recording when the recorder is not paused.");
    }

    _timePaused += (DateTime.now().difference(_pauseStarted));

    try {
      await _plugin.resumeRecording(_proxy);
    } on Object catch (e) {
      Log.d("Exception throw trying to resume the recorder $e");
      await stop();
      rethrow;
    }
    _internalRecorderState = _InternalRecorderState.recording;
    if (_onResumed != null) _onResumed(wasUser: true);
  }

  /// Sets the frequency at which duration updates are sent to
  /// duration listeners.
  /// The default is every 10 milliseconds.
  Future<void> _setProgressInterval(Duration interval) async {
    await _initialize();
    var args = SetRecordingProgressInterval();
    args.recorder = _proxy;
    args.interval = interval.inMilliseconds;
    await _plugin.setRecordingProgressInterval(args);
  }

  /// Returns the duration of the recording
  Duration get duration => _dispositionManager.lastDuration;

  /// Call by the plugin to notify us that the duration of the recording
  /// has changed.
  /// The plugin ignores pauses so it just gives us the time
  /// elapsed since the recording first started.
  ///
  /// We subtract the time we have spent paused to get the actual
  /// duration of the recording.
  ///
  void _updateProgress(Duration elapsedDuration, double decibels) {
    var duration = elapsedDuration - _timePaused;
    // Log.d('update duration called: $elapsedDuration');
    _dispositionManager.updateDisposition(duration, decibels);
    _recordingTrack.duration = duration;
  }

  ///
  /// Pass a callback if you want to be notified when
  /// recorder is paused.
  /// The [wasUser] is currently always true.
  // ignore: avoid_setters_without_getters
  set onPaused(RecorderEventWithCause onPaused) {
    _onPaused = onPaused;
  }

  ///
  /// Pass a callback if you want to be notified when
  /// recording is resumed.
  /// The [wasUser] is currently always true.
  // ignore: avoid_setters_without_getters
  set onResumed(RecorderEventWithCause onResumed) {
    _onResumed = onResumed;
  }

  /// Pass a callback if you want to be notified
  /// that recording has started.
  /// The [wasUser] is currently always true.
  ///
  // ignore: avoid_setters_without_getters
  set onStarted(RecorderEventWithCause onStarted) {
    _onStarted = onStarted;
  }

  /// Pass a callback if you want to be notified
  /// that recording has stopped.
  /// The [wasUser] is currently always true.
  // ignore: avoid_setters_without_getters
  set onStopped(RecorderEventWithCause onStopped) {
    _onStopped = onStopped;
  }

  /// System event telling us that the app has been paused.
  /// If we are recording we simply stop the recording.
  /// This could be a problem with some apps if they want to
  /// record in the background.
  Future<void> _onSystemAppPaused() async {
    Log.d(red('onSystemAppPaused  track=${_recordingTrack?.track}'));
    if (isRecording && !_playInBackground) {
      /// CONSIDER: this could be expensive as we do a [recode]
      /// when we stop. We might need to look at doing a lazy
      /// call to [recode].
      await stop();
    }
    await release();
  }

  /// System event telling us that our app has been resumed.
  /// We take no action when resuming. This is a place holder
  /// in case we change our mind.
  Future<void> _onSystemAppResumed() async {
    Log.d(red('onSystemAppResumed track=${_recordingTrack?.track}'));
  }
}

/// INTERNAL APIS
/// functions to assist with hiding the internal api.
///

///
/// Duration monitoring
///

/// Sets the frequency at which duration updates are sent to
/// duration listeners.
void recorderSetProgressInterval(SoundRecorder recorder, Duration interval) =>
    recorder._setProgressInterval(interval);

///
void recorderUpdateProgress(
        SoundRecorder recorder, Duration duration, double decibels) =>
    recorder._updateProgress(duration, decibels);

/// App pause/resume events.
///
///

/// System event notification that the app has paused
void onSystemAppPaused(SoundRecorder recorder) => recorder._onSystemAppPaused();

/// System event notification that the app has resumed
void onSystemAppResumed(SoundRecorder recorder) =>
    recorder._onSystemAppResumed();

/// Get the unique id for this sound player.
String soundRecoderUuid(SoundRecorder recorder) => recorder._uuid;

///
/// Execeptions
///

/// Base class for all exeception throw via
/// the recorder.
class RecorderException implements Exception {
  final String _message;

  ///
  RecorderException(this._message);

  String toString() => _message;
}

/// Thrown if you attempt an operation that requires the recorder
/// to be in a particular state and its not.
class RecorderInvalidStateException extends RecorderException {
  ///
  RecorderInvalidStateException(String message) : super(message);
}

/// Thrown when you attempt to make a recording and don't have
/// OS permissions to record.
class RecordingPermissionException extends RecorderException {
  ///
  RecordingPermissionException(String message) : super(message);
}

/// Thrown if the directory that you want to record into
/// doesn't exists.
class DirectoryNotFoundException extends RecorderException {
  ///
  DirectoryNotFoundException(String message) : super(message);
}

/// Thrown if you attempt an operation that requires the recorder
/// to be running (recording) and it is not currently recording.
class RecorderNotRunningException extends RecorderException {
  ///
  RecorderNotRunningException(String message) : super(message);
}

/// Throw if you attempt to resume recording but the
/// record is not currently paused.
class RecorderNotPausedException extends RecorderException {
  ///
  RecorderNotPausedException(String message) : super(message);
}
