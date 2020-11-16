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

// ignore_for_file: implementation_imports
import 'package:dart_native/src/ios/foundation/nserror.dart';
import 'package:dart_native/src/ios/foundation/objc_basic_type.dart';

import '../../sounds.dart';
import '../platform/sounds_platform_api.dart';
import '../sound_player.dart';
import 'frameworks/avfoundation/avaudioplayer.dart';
import 'frameworks/avfoundation/avaudiosession.dart';
import 'frameworks/avfoundation/avaudiosessioncategory.dart';
import 'frameworks/avfoundation/avaudiosessionmode.dart';
import 'frameworks/avfoundation/avaudiosessiontypes.dart';
import 'frameworks/avfoundation/hacks.dart';
import 'shade_player_ios.dart';
import 'sounds.dart';

class SoundPlayerIOS implements AVAudioPlayerDelegate {
  SoundPlayer _player;
  AVAudioPlayer audioPlayer;
  var isPaused = false;
  t_SET_CATEGORY_DONE setCategoryDone;
  t_SET_CATEGORY_DONE setActiveDone;

  Uri _audioFileURL;

  @override
  MediaFormatResponse getNativeDecoderFormats(MediaFormat mediaFormat) {
    // TODO: implement getNativeDecoderFormats
    throw UnimplementedError();
  }

  @override
  MediaFormatResponse getNativeEncoderFormats(MediaFormat proxy) {
    // TODO: implement getNativeEncoderFormats
    throw UnimplementedError();
  }

  @override
  Response initializePlayer(InitializePlayer initializePlayer) {
    isPaused = false;
  }

  @override
  Response initializePlayerWithShade(
      InitializePlayerWithShade initializePlayerWithShade) {
    // TODO: implement initializePlayerWithShade
    throw UnimplementedError();
  }

  @override
  Response initializeRecorder(SoundRecorder recorder) {
    // TODO: implement initializeRecorder
    throw UnimplementedError();
  }

  @override
  BoolResponse isBackgroundPlaybackSupported() {
    // TODO: implement isBackgroundPlaybackSupported
    throw UnimplementedError();
  }

  @override
  BoolResponse isShadePauseSupported() {
    // TODO: implement isShadePauseSupported
    throw UnimplementedError();
  }

  @override
  BoolResponse isShadeSkipBackwardsSupported() {
    // TODO: implement isShadeSkipBackwardsSupported
    throw UnimplementedError();
  }

  @override
  BoolResponse isShadeSkipForwardSupported() {
    // TODO: implement isShadeSkipForwardSupported
    throw UnimplementedError();
  }

  @override
  BoolResponse isShadeSupported() {
    // TODO: implement isShadeSupported
    throw UnimplementedError();
  }

  ///
  Response pausePlayer() {
    var response = Response();

    if (audioPlayer != null) {
      if (!(audioPlayer?.playing ?? false)) {
        isPaused = false;

        print("audioPlayer is not playing!\n");
        response.success = false;
        response.error = "audioPlayer is not playing";
        response.errorCode = SoundsToPlatformApi.errnoNotPlaying;
      } else {
        _pause();
        response.success = true;
      }
    } else {
      print("resumePlayer : player is not set\n");
      response.success = false;
      response.error = "audioPlayer is unknown";
      response.errorCode = SoundsToPlatformApi.errnoUnknownPlayer;
    }

    return response;
  }

  void _pause() {
    audioPlayer.pause();
    isPaused = true;
    stopProgressTimer();
    if (setActiveDone != t_SET_CATEGORY_DONE.by_USER &&
        (setActiveDone != t_SET_CATEGORY_DONE.not_SET)) {
      try {
        AVAudioSession.sharedInstance().setActive(active: false);
      } catch (_) {}
      setActiveDone = t_SET_CATEGORY_DONE.not_SET;
    }
  }

  @override
  Response releaseAudioFocus() {
    // TODO: implement releaseAudioFocus
    throw UnimplementedError();
  }

  ///
  Response releasePlayer() {}

  @override
  Response requestAudioFocus(AudioFocusProxy requestAudioFocus) {
    // TODO: implement requestAudioFocus
    throw UnimplementedError();
  }

  @override
  Response resumePlayer() {
    var response = Response();
    isPaused = false;

    if (audioPlayer == null) {
      print("resumePlayer : player is not set\n");

      response.success = false;
      response.error = "audioPlayer is unknown";
      response.errorCode = SoundsToPlatformApi.errnoUnknownPlayer;

      return response;
    }
    if ((audioPlayer?.playing ?? false) == true) {
      print("audioPlayer is already playing!\n");

      response.success = false;
      response.error = "audioPlayer is already playing";
      response.errorCode = SoundsToPlatformApi.errnoAlreadyPlaying;
    } else {
      try {
        AVAudioSession.sharedInstance().setActive(active: true);
      } catch (_) {}
      var b = resume();
      if (b) {
        var filePath = _audioFileURL.toFilePath();
        response.success = true;
      } else {
        response.success = false;
        response.error = "AudioPlayer resumed failed";
        response.errorCode = SoundsToPlatformApi.errnoGeneral;
      }
    }

    return response;
  }

  bool resume() {
    isPaused = true;

    var b = false;

    b = audioPlayer?.play() ?? false;
    if (b) {
      startProgressTimer();
      if (setActiveDone == t_SET_CATEGORY_DONE.not_SET) {
        try {
          AVAudioSession.sharedInstance().setActive(active: true);
          // ignore: avoid_catches_without_on_clauses
        } catch (_) {}
        setActiveDone = t_SET_CATEGORY_DONE.for_PLAYING;
      }
    } else {
      print("resume : resume failed!\n");
    }

    return b;
  }

  @override
  Response seekToPlayer(Duration offset) {
    var response = Response();
    if (audioPlayer != null) {
      audioPlayer.currentTime = offset;
      updateProgress();
      response.success = true;
    } else {
      response.success = false;
      response.error = 'AudioPlayer is not set';
      response.errorCode = SoundsToPlatformApi.errnoUnknownPlayer;
    }
  }

  Duration _playbackProgressInterval = Duration(milliseconds: 100);
  @override
  Response setPlaybackProgressInterval(Duration interval) {
    _playbackProgressInterval = interval;
  }

  @override
  Response setVolume(int volume) {
    var response = Response();

    if (audioPlayer != null) {
      audioPlayer.volume = volume / 1000.0;
      response.success = true;
    } else {
      response.success = false;
      response.error = 'AudioPlayer is not set';
      response.errorCode = SoundsToPlatformApi.errnoUnknownPlayer;
    }
  }

  @override
  Response startPlayer(TrackProxy track, Duration duration,
      {Duration startAt,
      bool canPause,
      bool canSkipForward,
      bool canSkipBackwards}) {
    var response = Response();

    var audioFileURL = URL(fileURLWithPath: track.path ?? "");
    // Able to play in silent mode

    if (setCategoryDone == t_SET_CATEGORY_DONE.not_SET) {
      try {
        AVAudioSession.sharedInstance().setCategory(
            category: AVAudioSessionCategory.Playback); // was forPlaying
        // ignore: avoid_catches_without_on_clauses
      } catch (_) {}
      setCategoryDone = t_SET_CATEGORY_DONE.for_PLAYING;
    }
    // Able to play in background
    if (setActiveDone == t_SET_CATEGORY_DONE.not_SET) {
      try {
        AVAudioSession.sharedInstance().setActive(active: true);
        // ignore: avoid_catches_without_on_clauses
      } catch (_) {}
      setActiveDone = t_SET_CATEGORY_DONE.for_PLAYING;
    }

    isPaused = false;

    // if (!audioPlayer) { // Fix sound distoring when playing recorded audio again.
    try {
      audioPlayer = AVAudioPlayer.init(audioFileURL);

      seekToPlayer(startAt);

      // ignore: avoid_catches_without_on_clauses
    } catch (_) {}
    audioPlayer.delegate = this;
    // }
    var b = audioPlayer?.play() ?? false;
    if (!b) {
      //originally stop() I think thiis is the same as "This" is the audioPlayer
      //delegate and audioPlayer is the only  AVAudioPlayer in the class
      audioPlayer.stop();
      response.success = false;
      response.error = "AudioPlayer Play failure";
      response.errorCode = SoundsToPlatformApi.errnoGeneral;
    } else {
      startProgressTimer();
      response.success = true;
    }

    return response;
  }
/*
  /// not currently supported.
  Response start(Uint8List fromBuffer) {
    //  : FlutterStandardTypedData?, result: FlutterResult) {
    var response = Response();
    try {
      var data = fromBuffer?.buffer;
      if (data != null) {
        audioPlayer = AVAudioPlayer(data: data);
      }
      // ignore: avoid_catches_without_on_clauses
    } catch (_) {}
    audioPlayer?.delegate = this;
    // Able to play in silent mode
    if (_setCategoryDone == t_SET_CATEGORY_DONE.not_SET) {
      try {
        AVAudioSession.sharedInstance()
            .setCategory(t_SET_CATEGORY_DONE.for_PLAYING);
        // ignore: avoid_catches_without_on_clauses
      } catch (_) {}
      _setCategoryDone = t_SET_CATEGORY_DONE.for_PLAYING;
    }
    // Able to play in background
    if (_setActiveDone == t_SET_CATEGORY_DONE.not_SET) {
      try {
        AVAudioSession.sharedInstance().setActive(active: true);
        // ignore: avoid_catches_without_on_clauses
      } catch (_) {}
      _setActiveDone = t_SET_CATEGORY_DONE.for_PLAYING;
    }
    isPaused = false;
    var b = audioPlayer?.play() ?? false;
    if (!b) {
      stop();

      response.success = false;
      response.error = "AudioPlayer Play failure";
      response.errorCode = SoundsToPlatformApi.errnoGeneral;
    } else {
      startProgressTimer();
      response.success = true;
    }
  }
  */

  bool playbackTimerRunning = false;
  void startProgressTimer() {
    stopProgressTimer();
    print("Starting ProgressTimer interval: $_playbackProgressInterval");

    playbackTimerRunning = true;

    Future.delayed(_playbackProgressInterval, () {
      updateProgress();
    });

    print("started ProgressTimer");
  }

  void stopProgressTimer() {
    playbackTimerRunning = true;
    print("stopping ProgressTimer");
  }

  ///
  Response stopPlayer() {
    stopProgressTimer();
    isPaused = false;
    if (audioPlayer != null) {
      audioPlayer?.stop();
      audioPlayer = null;
    }
    /* The caller did it himself : Sounds must not change that) */
    if ((setActiveDone != t_SET_CATEGORY_DONE.by_USER) &&
        (setActiveDone != t_SET_CATEGORY_DONE.not_SET)) {
      try {
        AVAudioSession.sharedInstance().setActive(active: false);
        // ignore: avoid_catches_without_on_clauses
      } catch (_) {}
      setActiveDone = t_SET_CATEGORY_DONE.not_SET;
    }
  }

  void updateProgress() {
    print("entered updateProgress");
    var duration = audioPlayer.duration * 1000;
    var currentTime = audioPlayer.currentTime * 1000;

    print("""
sending updateProgress: duration: $duration, position: $currentTime""");

    // TODO: call dart updateProgress

    if (playbackTimerRunning) {
      Future.delayed(_playbackProgressInterval, () {
        /// TODO call back to dart
        updateProgress();
      });
    }
  }

  ///
  void audioPlayerDidFinishPlaying(AVAudioPlayer _player, bool successfully) {
    print("audioPlayerDidFinishPlaying");
    /* The caller did it himself : Sounds must not change that) */
    if ((setActiveDone != t_SET_CATEGORY_DONE.by_USER) &&
        (setActiveDone != t_SET_CATEGORY_DONE.not_SET)) {
      try {
        AVAudioSession.sharedInstance().setActive(active: false);
        // ignore: avoid_catches_without_on_clauses
      } catch (_) {}
      setActiveDone = t_SET_CATEGORY_DONE.not_SET;
    }
    if (audioPlayer != null) {
      var duration = audioPlayer.duration * 1000;
      var currentTime = audioPlayer.currentTime * 1000;

      print(
          "sending updateProgress: duration: $duration, position: $currentTime");

      /// TODO call dart onStopped and may need to send final progress update.
      isPaused = false;
    }
    stopProgressTimer();
  }

  void _setCategory(AVAudioSessionCategory category, AVAudioSessionMode mode,
      AVAudioSessionCategoryOptions options) {
    // Able to play in silent mode
    var b = false;

    try {
      AVAudioSession.sharedInstance()
          .setCategory(category: category, mode: mode, options: options);
      b = true;
      // ignore: avoid_catches_without_on_clauses
    } catch (_) {}
    // The caller did it himself : Sounds must not change that)
    setCategoryDone = t_SET_CATEGORY_DONE.by_USER;
    setActiveDone = t_SET_CATEGORY_DONE.not_SET;
    // var r = NSNumber(value: b);
    // result(r)
  }

  void _setActive(bool enabled) {
    if (enabled) {
      if (setActiveDone != t_SET_CATEGORY_DONE.not_SET) {
        // Already activated. Nothing todo;
        // The caller did it himself : Sounds must not change that)
        setActiveDone = t_SET_CATEGORY_DONE.by_USER;
        return;
      }

      setActiveDone = t_SET_CATEGORY_DONE.by_USER;
    } else {
      if (setActiveDone == t_SET_CATEGORY_DONE.not_SET) {
        // Already desactivated
        return;
      }
      setActiveDone = t_SET_CATEGORY_DONE.not_SET;
    }
    var b = false;
    try {
      AVAudioSession.sharedInstance().setActive(active: enabled);
      b = true;
      // ignore: avoid_catches_without_on_clauses
    } catch (_) {}
    // var r = NSNumber(value: b)
    // result(r)
  }

  @override
  void audioPlayerBeginInterruption(AVAudioPlayer player) {
    // TODO: implement audioPlayerBeginInterruption
  }

  @override
  void audioPlayerDecodeErrorDidOccurError(AVAudioPlayer player,
      {NSError error}) {
    // TODO: implement audioPlayerDecodeErrorDidOccurError
  }

  @override
  void audioPlayerDidFinishPlayingSuccessfully(
      AVAudioPlayer player, bool flag) {
    // TODO: implement audioPlayerDidFinishPlayingSuccessfully
  }

  @override
  void audioPlayerEndInterruption(AVAudioPlayer player) {
    // TODO: implement audioPlayerEndInterruption
  }

  @override
  void audioPlayerEndInterruptionWithFlags(
      AVAudioPlayer player, NSUInteger flags) {
    // TODO: implement audioPlayerEndInterruptionWithFlags
  }

  @override
  void audioPlayerEndInterruptionWithOptions(
      AVAudioPlayer player, NSUInteger flags) {
    // TODO: implement audioPlayerEndInterruptionWithOptions
  }

  // @override
  // registerAVAudioPlayerDelegate() {
  //   // TODO: implement registerAVAudioPlayerDelegate
  //   throw UnimplementedError();
  // }
}
