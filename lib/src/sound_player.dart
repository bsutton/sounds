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

import 'package:meta/meta.dart';
import 'package:sounds_common/sounds_common.dart';
import 'package:sounds_platform_interface/sounds_platform_interface.dart';
import 'package:uuid/uuid.dart';

import '../sounds.dart';
import 'audio_focus.dart';
import 'media_format/native_media_formats.dart';
import 'plugins/app_life_cycle_observer.dart';

/// A [SoundPlayer] establishes an audio session and allows
/// you to play multiple audio files within the session.
///
/// [SoundPlayer] can either be used headless ([SoundPlayer.noUI] or
/// use the OSs' built in Media Player (shade) [SoundPlayer.withIU].
///
/// You can use the headless mode to build you own UI for playing sound
/// or use Soundss own [SoundPlayerUI] widget.
///
/// Once you have finished using a [SoundPlayer] you MUST call
/// [SoundPlayer.release] to free up any resources.
///
class SoundPlayer {
  final String _uuid = Uuid().v4();

  SoundPlayerProxy __proxy;

  final AppLifeCycleObserver _lifeCycleObserver = AppLifeCycleObserver();

  SoundPlayerProxy get _proxy {
    if (__proxy == null) {
      __proxy = SoundPlayerProxy();
      __proxy.uuid = _uuid;
    }
    return __proxy;
  }

  final _plugin = SoundsToPlatformApi();

  PlayerEvent _onSkipForward;
  PlayerEvent _onSkipBackward;

  PlayerEventWithCause _onPaused;
  PlayerEventWithCause _onResumed;
  PlayerEventWithCause _onStarted;
  PlayerEventWithCause _onStopped;
  final bool _autoFocus;

  /// When the [withShadeUI] ctor is called this field
  /// controls whether the OSs' UI displays the pause button.
  /// If you change this value it won't take affect until the
  /// next call to [play].
  bool canPause;

  /// When the [withShadeUI] ctor is called this field
  /// controls whether the OSs' UI displays the skip Forward button.
  /// If you change this value it won't take affect until the
  /// next call to [play].
  bool canSkipForward;

  /// When the [withShadeUI] ctor is called this field
  /// controls whether the OSs' UI displays the skip back button.
  /// If you change this value it won't take affect until the
  /// next call to [play].
  bool canSkipBackward;

  /// If true then the media is being played in the background
  /// and will continue playing even if our app is paused.
  /// If false the audio will automatically be paused if
  /// the audio is placed into the back ground and resumed
  /// when your app becomes the foreground app.
  final bool _playInBackground;

  /// If the user calls seekTo before starting the track
  /// we cache the value until we start the player and
  /// then we apply the seek offset.
  Duration _seekTo;

  /// The track that we are currently playing.
  Track _track;

  var _internalPlayerState = _InternalPlayerState.preInitialised;

  ///
  /// Disposition stream components
  ///

  /// The stream source
  var _playerController = StreamController<PlaybackDisposition>.broadcast();

  /// The current playback position as last sent on the stream.
  Duration _currentPosition = Duration.zero;

  /// Used to track when we have been paused when the app is paused.
  /// We should only resume playing if we wer playing when paused.
  bool _inSystemPause = false;

  final bool _showShade;

  /// Create a [SoundPlayer] that displays the OS' audio UI (often
  /// referred to as a shade).
  ///
  /// if [canPause] is true than the user will be able to pause the track
  /// via the OSs' UI. Defaults to true.
  ///
  /// If [canSkipBackward] is true then the user will be able to click the skip
  /// back button on the OSs' UI. Given the [SoundPlayer] only deals with a
  /// single track at
  /// a time you will need to implement [onSkipBackward] for this action to
  /// have any affect. The [Album] class has the ability to manage mulitple
  /// tracks.
  ///
  /// If [canSkipForward] is true then the user will be able to click the skip
  /// forward button on the OSs' UI. Given the [SoundPlayer] only deals with a
  /// single track at a time you will need to implement [onSkipForward] for
  /// this action to have any affect. The [Album] class has the ability to
  /// manage mulitple tracks.
  ///
  /// If [playInBackground] is true then the audio will play in the background
  /// which means that it will keep playing even if the app is sent to the
  /// background.
  ///
  /// {@tool sample}
  /// Once you have finished with the [SoundPlayer] you MUST
  /// call [SoundPlayer.release].
  ///
  /// ```dart
  /// var player = SoundPlayer.noUI();
  /// player.onStopped = ({wasUser}) => player.release();
  /// player.play(track);
  /// ```
  /// The above example guarentees that the player will be released.
  /// {@end-tool}
  SoundPlayer.withShadeUI(
      {this.canPause = true,
      this.canSkipBackward = false,
      this.canSkipForward = false,
      bool playInBackground = false,
      bool autoFocus = true})
      : _playInBackground = playInBackground,
        _showShade = true,
        _autoFocus = autoFocus {
    _commonInit();
  }

  /// Create a [SoundPlayer] that does not have a UI.
  ///
  /// You can use this version to simply playback audio without
  /// a UI or to build your own UI as [Playbar] does.
  ///
  /// If [playInBackground] is true then the audio will play in the background
  /// which means that it will keep playing even if the app is sent to the
  /// background.
  ///
  /// {@tool sample}
  /// Once you have finished with the [SoundPlayer] you MUST
  /// call [SoundPlayer.release].
  /// ```dart
  /// var player = SoundPlayer.noUI();
  /// player.onStopped = ({wasUser}) => player.release();
  /// player.play(track);
  /// ```
  /// The above example guarentees that the player will be released.
  /// {@end-tool}
  SoundPlayer.noUI({bool playInBackground = false, bool autoFocus = true})
      : _playInBackground = playInBackground,
        _showShade = false,
        _autoFocus = autoFocus {
    canPause = false;
    canSkipBackward = false;
    canSkipForward = false;
    _commonInit();
  }

  /// once off initialisation used by all ctors.
  void _commonInit() {
    _lifeCycleObserver.onSystemAppPaused = _onSystemAppPaused;
    _lifeCycleObserver.onSystemAppResumed = _onSystemAppResumed;

    /// set up a listener to track the current position
    _playerController.stream.listen((playbackDisposition) {
      _currentPosition = playbackDisposition.position;
    });
  }

  Future<void> _initialize() async {
    if (_internalPlayerState == _InternalPlayerState.preInitialised) {
      if (_showShade) {
        var args = InitializePlayerWithShade();
        args.player = _proxy;
        args.playInBackground = _playInBackground;
        args.canPause = canPause;
        args.canSkipBackward = canSkipBackward;
        args.canSkipForward = canSkipForward;
        await _plugin.initializePlayerWithShade(args);
      } else {
        var args = InitializePlayer();
        args.player = _proxy;
        args.playInBackground = _playInBackground;

        await _plugin.initializePlayer(args);
        _internalPlayerState = _InternalPlayerState.initialised;
      }
    }
  }

  /// Call this method once you are done with the player
  /// so that it can release all of the attached resources.
  /// await the [release] to ensure that all resources are released before
  /// you take future action.
  Future<void> release() async {
    if (_internalPlayerState == _InternalPlayerState.preInitialised) {
      throw PlayerInvalidStateException(
          "The player is not initialised. Did you call release() twice?");
    }

    _lifeCycleObserver.dispose();
    await _closeDispositionStream();
    await _softRelease();
    await _plugin.releasePlayer(_proxy);
  }

  /// If the player is pushed into the
  /// background we want to release the plugin and
  /// any other temporary resources.
  /// The exception is if we are configured to continue
  /// playing in the backgroud in which case
  /// this method won't be called.
  Future<void> _softRelease() async {
    // Stop the player playback before releasing

    if (isPlaying) {
      await _plugin.stopPlayer(_proxy);
    }

    // release the android/ios resources but
    // leave the slot intact so we can resume.
    if (_internalPlayerState != _InternalPlayerState.preInitialised) {
      /// the plugin is in an initialized state
      /// so we need to release it.
      await _plugin.releasePlayer(_proxy);

      /// looks like this method is re-entrant when app is pausing
      /// so we need to protect ourselves from being called twice.
      _internalPlayerState = _InternalPlayerState.preInitialised;
    }

    if (_track != null) {
      trackRelease(_track);
    }
  }

  /// Starts playback.
  /// The [track] to play.
  /// To start playback from an position other than the start of
  /// the [track] pass a non-zero value to [startAt] which indicates
  /// the start position, in milliseconds, from the start of the
  /// track.
  Future<void> play(Track track, {int startAt = 0}) async {
    assert(track != null);
    await _initialize();

    if (_autoFocus) {
      requestAudioFocus(AudioFocus.hushOthersWithResume);
    }

    if (!isStopped) {
      throw PlayerInvalidStateException("The player must not be running.");
    }

    _currentPosition = Duration.zero;
    _track = track;

    // Check the current MediaFormat is supported on this platform
    // if we were supplied the format.
    if (track.mediaFormat != null &&
        !await NativeMediaFormats().isNativeDecoder(track.mediaFormat)) {
      var exception = PlayerInvalidStateException(
          'The selected MediaFormat ${track.mediaFormat.name} is not '
          'supported on this platform.');
      throw exception;
    }

    Log.d('calling prepare stream');
    await prepareStream(
        track, (disposition) => _playerController.add(disposition));

    // Not awaiting this may cause issues if someone immediately tries
    // to stop.
    // I think we need a completer to control transitions.
    Log.d('calling _plugin.play');

    var args = StartPlayer();
    args.player = _proxy;
    args.startAt = startAt;
    args.track = trackProxy(track);
    await _plugin.startPlayer(args);

    /// If the user called seekTo before starting the player
    /// we immediate do a seek.
    /// TODO: does this cause any audio glitch (i.e starts playing)
    /// and then seeks.
    /// If so we may need to modify the plugin so we pass in a seekTo
    /// argument.
    Log.d('calling seek');
    if (_seekTo != null) {
      await seekTo(_seekTo);
      _seekTo = null;
    }

    // TODO: we should wait for the os to notify us that the start
    // has happened.
    _internalPlayerState = _InternalPlayerState.playing;

    if (_onStarted != null) _onStarted(wasUser: false);
  }

  /// Stops playback.
  /// Use the [wasUser] to indicate if the stop was a caused by a user action
  /// or the application called stop.
  Future<void> stop({@required bool wasUser}) async {
    if (isStopped) {
      throw PlayerInvalidStateException('Player is not playing.');
    }

    await _initialize;

    try {
      _internalPlayerState = _InternalPlayerState.stopped;
      await _plugin.stopPlayer(_proxy);

      // when we get the real system onSystemStopped being
      // called via the plugin then we can delete this line.
      _onSystemStopped();
    } on Object catch (e) {
      Log.d(e.toString());
      rethrow;
    }
  }

  void _onSystemStopped() {
    if (_autoFocus) {
      releaseAudioFocus();
    }
  }

  /// Pauses playback.
  /// If you call this and the audio is not playing
  /// a [PlayerInvalidStateException] will be thrown.
  Future<void> pause() async {
    await _initialize();
    if (_internalPlayerState != _InternalPlayerState.playing) {
      throw PlayerInvalidStateException('Player is not playing.');
    }

    _internalPlayerState = _InternalPlayerState.paused;
    await _plugin.pausePlayer(_proxy);
    if (_onPaused != null) _onPaused(wasUser: false);
  }

  /// Resumes playback.
  /// If you call this when audio is not paused
  /// then a [PlayerInvalidStateException] will be thrown.
  Future<void> resume() async {
    await _initialize();
    if (_internalPlayerState != _InternalPlayerState.paused) {
      throw PlayerInvalidStateException('Player is not paused.');
    }

    _internalPlayerState = _InternalPlayerState.playing;
    await _plugin.resumePlayer(_proxy);
    if (_onResumed != null) _onResumed(wasUser: false);
  }

  /// Moves the current playback position to the given offset in the
  /// recording.
  /// [position] is the position in the recording to set the playback
  /// location from.
  /// You may call this before [play] or whilst the audio is playing.
  /// If you call [seekTo] before calling [play] then when you call
  /// [play] we will start playing the recording from the [position]
  /// passed to [seekTo].
  Future<void> seekTo(Duration position) async {
    await _initialize();
    if (!isPlaying) {
      _seekTo = position;
    } else {
      var args = SeekToPlayer();
      await _plugin.seekToPlayer(args);
    }
  }

  /// Rewinds the current track by the given interval
  Future<void> rewind(Duration interval) async {
    await _initialize();

    _currentPosition -= interval;

    /// There may be a chance of a race condition if the underlying
    /// os code is in the middle of sending us a position update.
    return seekTo(_currentPosition);
  }

  /// Sets the playback volume
  /// The [volume] must be in the range 0.0 to 1.0.
  Future<void> setVolume(double volume) async {
    await _initialize();

    var args = SetVolume();
    args.player = _proxy;
    args.volume = volume;
    await _plugin.setVolume(args);
  }

  /// [true] if the player is currently playing audio
  bool get isPlaying => _internalPlayerState == _InternalPlayerState.playing;

  /// [true] if the player is playing but the audio is paused
  bool get isPaused => _internalPlayerState == _InternalPlayerState.paused;

  /// [true] if the player is stopped.
  bool get isStopped => _internalPlayerState == _InternalPlayerState.stopped;

  /// Provides a stream of dispositions which
  /// provide updated position and duration
  /// as the audio is played.
  /// The duration may start out as zero until the
  /// media becomes available.
  /// Keep in mind disposition stream is a type of broadcast stream
  /// meaning duration and position will only be available as they fire.
  ///
  /// Use [setProgressInterval] to control the frequency
  /// of events. The default is 100ms.
  ///
  /// If you pause the audio then no updates will be sent to the
  /// stream.
  Stream<PlaybackDisposition> dispositionStream() {
    return _playerController.stream;
  }

  /// TODO does this need to be exposed?
  /// The simple action of stopping the playback may be sufficient
  /// Given the user has to call stop
  Future<void> _closeDispositionStream() async {
    if (_playerController != null) {
      _playerController.close();
      _playerController = null;
    }
  }

  /// Stream updates to users of [dispositionStream]
  void _updateProgress(PlaybackDisposition disposition) {
    // we only send dispositions whilst playing.
    if (isPlaying) {
      _playerController?.add(disposition);
    }
  }

  /// Sets the time between callbacks from the platform specific code
  /// used to notify us of playback progress.
  Future<void> setProgressInterval(Duration interval) async {
    await _initialize();
    assert(interval.inMilliseconds > 0);

    var args = SetPlaybackProgressInterval();
    args.player = _proxy;
    args.interval = interval.inMilliseconds;

    await _plugin.setPlaybackProgressInterval(args);
  }

  /// internal method.
  /// Called by the Platform plugin to notify us that
  /// audio has finished playing to the end.
  void _audioPlayerFinished(PlaybackDisposition status) {
    // if we have finished then position should be at the end.
    var finalPosition = PlaybackDisposition(PlaybackDispositionState.stopped,
        position: status.duration, duration: status.duration);

    _playerController?.add(finalPosition);
    if (_autoFocus) {
      releaseAudioFocus();
    }
    _internalPlayerState = _InternalPlayerState.stopped;
    if (_onStopped != null) _onStopped(wasUser: false);
  }

  /// handles a pause coming up from the player
  void _onSystemPaused() {
    if (!isPaused) {
      pause();
    }
  }

  /// handles a resume coming up from the player
  void _onSystemResumed() {
    if (isPaused) {
      resume();
    }
  }

  /// System event telling us that the app has been paused.
  /// Unless we are playing in the background then
  /// we need to stop playback and release resources.
  void _onSystemAppPaused() {
    Log.d(red('onSystemAppPaused _playInBackground=$_playInBackground'));
    if (!_playInBackground) {
      if (isPlaying) {
        /// we are only in a system pause if we were playing
        /// when the app was paused.
        _inSystemPause = true;
        stop(wasUser: false);
      }
      _softRelease();
    }
  }

  /// System event telling us that our app has been resumed.
  /// If we had previously stopped then we resuming playing
  /// from the last position - 1 second.
  Future<void> _onSystemAppResumed() async {
    Log.d(red('onSystemAppResumed _playInBackground=$_playInBackground '
        'track=$_track'));

    if (_inSystemPause && !_playInBackground && _track != null) {
      _inSystemPause = false;
      await seekTo(_currentPosition);
      await play(_track);
    }
  }

  /// handles a skip forward coming up from the player
  void _onSystemSkipForward() {
    if (_onSkipForward != null) _onSkipForward();
  }

  /// handles a skip forward coming up from the player
  void _onSystemSkipBackward() {
    if (_onSkipBackward != null) _onSkipBackward();
  }

  /// Pass a callback if you want to be notified
  /// when the user attempts to skip forward to the
  /// next track.
  /// This is only meaningful if you have used
  /// [SoundPlayer..withShadeUI] which has a 'skip' button.
  ///
  /// It is up to you to create a new SoundPlayer with the
  /// next track and start it playing.
  ///
  // ignore: avoid_setters_without_getters
  set onSkipForward(PlayerEvent onSkipForward) {
    _onSkipForward = onSkipForward;
  }

  /// Pass a callback if you want to be notified
  /// when the user attempts to skip backward to the
  /// prior track.
  /// This is only meaningful if you have set
  /// [showOSUI] which has a 'skip' button.
  /// The SoundPlayer essentially ignores this event
  /// as the SoundPlayer has no concept of an Album.
  ///
  ///
  // ignore: avoid_setters_without_getters
  set onSkipBackward(PlayerEvent onSkipBackward) {
    _onSkipBackward = onSkipBackward;
  }

  ///
  /// Pass a callback if you want to be notified when
  /// playback is paused.
  /// The [wasUser] argument in the callback will
  /// be true if the user clicked the pause button
  /// on the OS UI.  To show the OS UI you must have called
  /// [SoundPlayer..withShadeUI].
  ///
  /// [wasUser] will be false if you paused the audio
  /// via a call to [pause].
  // ignore: avoid_setters_without_getters
  set onPaused(PlayerEventWithCause onPaused) {
    _onPaused = onPaused;
  }

  ///
  /// Pass a callback if you want to be notified when
  /// playback is resumed.
  /// The [wasUser] argument in the callback will
  /// be true if the user clicked the resume button
  /// on the OS UI.  To show the OS UI you must have called
  /// [SoundPlayer..withShadeUI].
  ///
  /// [wasUser] will be false if you resumed the audio
  /// via a call to [resume].
  // ignore: avoid_setters_without_getters
  set onResumed(PlayerEventWithCause onResumed) {
    _onResumed = onResumed;
  }

  /// Pass a callback if you want to be notified
  /// that audio has started playing.
  ///
  /// If the player has to download or transcribe
  /// the audio then this method won't return
  /// util the audio actually starts to play.
  ///
  /// This can occur if you called [play]
  /// or the user click the start button on the
  /// OS UI. To show the OS UI you must have called
  /// [SoundPlayer..withShadeUI].
  // ignore: avoid_setters_without_getters
  set onStarted(PlayerEventWithCause onStarted) {
    _onStarted = onStarted;
  }

  /// Pass a callback if you want to be notified
  /// that audio has stopped playing.
  /// This can happen as the result of a user
  /// action (clicking the stop button) an api
  /// call [stop] or the audio naturally completes.
  ///
  /// [onStoppped]  can occur if you called [stop]
  /// or the user click the stop button (widget or OS)
  /// or the audio naturally completes.
  ///
  /// [SoundPlayer..withShadeUI].
  // ignore: avoid_setters_without_getters
  set onStopped(PlayerEventWithCause onStopped) {
    _onStopped = onStopped;
  }

  /// The caller can manage the audio focus with this function.
  /// Depending on your configuration this will either make
  /// this player the loudest stream or it will silence all other stream.
  Future<void> requestAudioFocus(AudioFocus audioFocus) async {
    await _initialize();

    var args = RequestAudioFocus();

    args.player = _proxy;
    args.audioFocus = AudioFocusHelper.generate(audioFocus);
    await _plugin.requestAudioFocus(args);
  }

  /// The caller can manage the audio focus with this function.
  /// Depending on your configuration this will either make
  /// this player the loudest stream or it will silence all other stream.
  Future<void> releaseAudioFocus() async {
    await _initialize();

    await _plugin.releaseAudioFocus(_proxy);
  }

  /// Gets the duration of the passed [path].
  /// The [path] MUST be stored on the local file system
  /// otherwise an [ArgumentError] will be thrown.
  /// An Asset is not considered to be on the local file system.
  Future<Duration> duration(String path) async {
    var args = GetDuration();
    args.player = _proxy;
    args.track = TrackProxy();
    args.track.uuid = Track.fromFile(path).uuid;

    var response = await _plugin.getDuration(args);
    return Duration(milliseconds: response.duration);
  }
}

/// Forwarders so we can hide methods from the public api.

void updateProgress(SoundPlayer player, PlaybackDisposition disposition) =>
    player._updateProgress(disposition);

/// Called if the audio has reached the end of the audio source
/// or if we or the os stopped the playback prematurely.
void audioPlayerFinished(SoundPlayer player, PlaybackDisposition status) =>
    player._audioPlayerFinished(status);

/// handles an audio pause coming up from the player
void onSystemPaused(SoundPlayer player) => player._onSystemPaused();

/// handles an audio resume coming up from the player
void onSystemResumed(SoundPlayer player) => player._onSystemResumed();

/// handles a skip forward coming up from the player
void onSystemSkipForward(SoundPlayer player) => player._onSystemSkipForward();

/// handles a skip forward coming up from the player
void onSystemSkipBackward(SoundPlayer player) => player._onSystemSkipBackward();

/// Get the unique id for this sound player.
String soundPlayerUuid(SoundPlayer player) => player._uuid;

enum _InternalPlayerState {
  preInitialised,

  initialised,

  stopped,

  playing,

  paused
}

typedef PlayerEvent = void Function();

/// TODO should we be passing an object that contains
/// information such as the position in the track when
/// it was paused?
typedef PlayerEventWithCause = void Function({@required bool wasUser});
typedef UpdatePlayerProgress = void Function(int current, int max);

/// The player was in an unexpected state when you tried
/// to change it state.
/// e.g. you tried to pause when the player was stopped.
class PlayerInvalidStateException implements Exception {
  final String _message;

  ///
  PlayerInvalidStateException(this._message);

  String toString() => _message;
}

/// Thrown if the user tries to call an api method which
/// is currently not implemented.
class NotImplementedException implements Exception {
  final String _message;

  ///
  NotImplementedException(this._message);

  String toString() => _message;
}
