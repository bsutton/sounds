import 'package:sounds_common/sounds_common.dart';
import 'package:sounds_platform_interface/sounds_platform_interface.dart';

import '../sound_player.dart';
import '../sound_player.dart' as p;
import '../sound_recorder.dart';
import '../sound_recorder.dart' as r;

/// Handles calls coming up from the platform and dispatching them.abstract

class PlatformDispatcher implements SoundsFromPlatformApi {
  static PlatformDispatcher _self = PlatformDispatcher._internal();

  /// Factory ctor.
  factory PlatformDispatcher() => _self;

  PlatformDispatcher._internal() {
    SoundsFromPlatformApi.setup(this);
  }

  final _players = <String, SoundPlayer>{};

  /// Each time a [SoundPlayer] is created it MUST register
  /// so we can dispatch callbacks from the platform.
  void registerPlayer(SoundPlayerProxy _proxy, SoundPlayer soundPlayer) {
    _players[_proxy.uuid] = soundPlayer;
  }

  /// When a [SoundPlayer] is released from the platform
  /// you MUST also release the recorder here so
  /// we don't leak old recorders.
  void releasePlayer(SoundPlayerProxy _proxy) {
    _players[_proxy.uuid] = null;
  }

  final _recorders = <String, SoundRecorder>{};

  /// Each time a [SoundRecorder] is created it MUST register
  /// so we can dispatch callbacks from the platform.
  void registerRecorder(
      SoundRecorderProxy _proxy, SoundRecorder soundRecorder) {
    _recorders[_proxy.uuid] = soundRecorder;
  }

  /// When a [SoundRecorder] is released from the platform
  /// you MUST also release the recorder here so
  /// we don't leak old recorders.
  void releaseRecoder(SoundRecorderProxy _proxy) {
    _recorders[_proxy.uuid] = null;
  }

  SoundPlayer _getPlayer(SoundPlayerProxy proxy) {
    return _players[proxy.uuid];
  }

  SoundRecorder _getRecorder(SoundRecorderProxy proxy) {
    return _recorders[proxy.uuid];
  }

  @override
  void onError(OnError arg) {
    // TODO: implement onError
  }

  @override
  void onPlaybackProgress(OnPlaybackProgress arg) {
    var playerProxy = arg.player;
    var duration = Duration(milliseconds: arg.duration);
    var position = Duration(milliseconds: arg.position);

    p.onPlaybackProgress(
        _getPlayer(playerProxy),
        PlaybackDisposition(
          PlaybackDispositionState.playing,
          duration: duration,
          position: position,
        ));
  }

  @override
  void onPlaybackFinished(OnPlaybackFinished arg) {
    var playerProxy = arg.player;
    // var trackProxy = arg.track;
    var disposition = PlaybackDisposition(
      PlaybackDispositionState.finished,
    );

    p.onPlaybackFinished(_getPlayer(playerProxy), disposition);
  }

  @override
  void onShadePaused(OnShadePaused arg) {
    var playerProxy = arg.player;
    // var trackProxy = arg.track;

    p.onShadePaused(_getPlayer(playerProxy));
  }

  @override
  void onShadeResumed(OnShadeResumed arg) {
    var playerProxy = arg.player;
    // var trackProxy = arg.track;

    p.onShadeResumed(_getPlayer(playerProxy));
  }

  @override
  void onShadeSkipBackward(OnShadeSkipBackward arg) {
    var playerProxy = arg.player;
    // var trackProxy = arg.track;

    p.onShadeSkipBackward(_getPlayer(playerProxy));
  }

  @override
  void onShadeSkipForward(OnShadeSkipForward arg) {
    var playerProxy = arg.player;
    //var trackProxy = arg.track;

    p.onShadeSkipForward(_getPlayer(playerProxy));
  }

  @override
  void onRecordingProgress(OnRecordingProgress arg) {
    var recorderProxy = arg.recorder;
    //var trackProxy = arg.track;
    var duration = Duration(milliseconds: arg.duration);
    var decibels = arg.decibels;

    r.onRecordingProgress(_getRecorder(recorderProxy), duration, decibels);
  }
}
