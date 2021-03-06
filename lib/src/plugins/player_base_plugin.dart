import 'dart:async';
import 'dart:convert' as convert;
import 'dart:io';

import 'package:completer_ex/completer_ex.dart';
import 'package:flutter/services.dart';
import 'package:sounds_common/sounds_common.dart';
import 'package:uuid/uuid.dart';

import '../ios/ios_session_category.dart';
import '../ios/ios_session_mode.dart';
import '../sound_player.dart' as sound_player;
import '../sound_player.dart';
import 'base_plugin.dart';

/// base for all plugins that provide Plaback services.
abstract class PlayerBasePlugin extends BasePlugin {
  /// Pass in the [registeredName] which is the registered
  /// name of the plugin.
  PlayerBasePlugin(String registeredName) : super(registeredName, _slots);

  /// The java ShadePlayer and SoundPlayer share a static
  /// array of slots. As such so must we.
  /// TODO(bsutton): get the java/swift code so that each plugin has its own
  /// slots.
  /// ignore: prefer_final_fields
  static var _slots = <SlotEntry>[];

  /// The callbackMap is used to map callbacks to a completer
  /// created by the originator of the callback.
  /// As we can have overlapping calls against the same entry point
  /// we need to ensure that we map the correct response to the
  /// correct response.
  ///
  /// When making a call to the plugin you should use Uuid() to create
  /// a unique id for each call into the plugin.
  /// When the plugin returns via a callback it should return the uuid
  /// allowing us to 'complete' the [Completer] causing the originator
  /// to complete its future.
  ///
  /// CONSIDER: adding a timeout to the completer so we are guarenteed that
  /// the callbacks complete.
  final _callbackMap = <String, CompleterEx<Duration>>{};

  /// Over load this method to play audio.
  Future<void> play(sound_player.SoundPlayer player, Track track);

  /// Each Player must be initialized and registered.
  Future<void> initializePlayer(SlotEntry player) async {
    await invokeMethod(player, 'initializeMediaPlayer', <String, dynamic>{});
  }

  /// Releases the slot used by the connector.
  /// To use a plugin you start by calling [register]
  /// and finish by calling [release].
  Future<void> releasePlayer(SlotEntry slotEntry) async {
    await invokeMethod(slotEntry, 'releaseMediaPlayer', <String, dynamic>{});
  }

  ///
  Future<void> stop(SlotEntry player) async {
    await invokeMethod(player, 'stopPlayer', <String, dynamic>{});
  }

  ///
  Future<void> pause(SlotEntry player) async {
    await invokeMethod(player, 'pausePlayer', <String, dynamic>{});
  }

  ///
  Future<void> resume(SlotEntry player) async {
    await invokeMethod(player, 'resumePlayer', <String, dynamic>{});
  }

  ///
  Future<void> seekToPlayer(SlotEntry player, Duration position) async {
    await invokeMethod(player, 'seekToPlayer', <String, dynamic>{
      'milli': position.inMilliseconds,
    });
  }

  /// Get the duration of an audio file located at [path].
  Future<Duration> duration(SlotEntry player, String path) async {
    ArgumentError.checkNotNull(player, 'player');
    ArgumentError.checkNotNull(path, 'path');
    final callbackUuid = const Uuid().v4();

    final completer = CompleterEx<Duration>();
    _callbackMap[callbackUuid] = completer;

    /// The results are completed via a callback to [_onDurationResults] or
    /// in the event of an error a call to [onError].
    await invokeMethod(player, 'getDuration',
        <String, dynamic>{'path': path, 'callbackUuid': callbackUuid});

    return completer.future;
  }

  /// callback when the the platform call to 'getDuration' completes.
  void _onDurationResults(MethodCall call) {
    // ignore: avoid_dynamic_calls
    final json = call.arguments['arg'] as Map<dynamic, dynamic>;

    // var json = convert.jsonDecode(arguments) as Map<String, dynamic>;
    final duration = Duration(milliseconds: json['milliseconds'] as int);
    final uuid = json['callbackUuid'] as String;

    // complete the future waiting for this call to return.
    _callbackMap[uuid]!.complete(duration);
  }

  ///
  Future<void> setVolume(SlotEntry player, double volume) async {
    final indexedVolume = Platform.isIOS ? volume * 100 : volume;
    if (volume < 0.0 || volume > 1.0) {
      throw RangeError('Value of volume should be between 0.0 and 1.0.');
    }
    await invokeMethod(player, 'setVolume', <String, dynamic>{
      'volume': indexedVolume,
    });
  }

  ///
  Future<bool> iosSetCategory(SlotEntry player, IOSSessionCategory category,
      IOSSessionMode mode, int options) async {
    if (!Platform.isIOS) {
      return false;
    }
    final r = await invokeMethod(player, 'iosSetCategory', <String, dynamic>{
      'category': iosSessionCategory[category.index],
      'mode': iosSessionMode[mode.index],
      'options': options
    }) as bool;

    return r;
  }

  ///
  Future<bool> androidFocusRequest(SlotEntry player, int focusGain) async {
    if (!Platform.isAndroid) {
      return false;
    }
    return await invokeMethod(player, 'androidAudioFocusRequest',
        <String, dynamic>{'focusGain': focusGain}) as bool;
  }

  /// The caller can manage the audio focus with this function
  /// If [request] is true then we request the focus
  /// If [request] is false then we abandon the focus.
  Future<void> audioFocus(SlotEntry slotEntry, {required bool request}) async {
    await invokeMethod(
        slotEntry, 'setActive', <String, dynamic>{'enabled': request});
  }

  ///
  Future<void> setProgressInterval(SlotEntry player, Duration interval) async {
    await invokeMethod(player, 'setProgressInterval', <String, dynamic>{
      /// we need to use milliseconds as if we use seconds we end
      /// up rounding down to zero.
      'milli': interval.inMilliseconds,
    });
  }

  /// Contrucsts a PlaybackDisposition from a json object.
  /// This is used internally to deserialise data coming
  /// up from the underlying OS.
  static PlaybackDisposition dispositionFromJSON(String serializedJson) {
    final json = convert.jsonDecode(serializedJson) as Map<String, dynamic>;
    var duration = Duration(
        milliseconds: double.parse(json['duration'] as String).toInt());
    var position = Duration(
        milliseconds: double.parse(json['current_position'] as String).toInt());

    /// looks like the android subsystem can generate -ve values
    /// during some transitions so we protect ourselves.
    if (duration.inMilliseconds < 0) {
      duration = Duration.zero;
    }
    if (position.inMilliseconds < 0) {
      position = Duration.zero;
    }

    /// when playing an mp3 I've seen occurances where the position is after
    /// the duration. So I've added this protection.
    if (position > duration) {
      // Log.d('Fixed position > duration,  $position > $duration');
      duration = position;
    }
    return PlaybackDisposition(PlaybackDispositionState.playing,
        progress: 0, position: position, duration: duration);
  }

  /// Handles callbacks from the platform specific plugin
  /// The below methods are shared by all the playback plugins.
  @override
  Future<dynamic> onMethodCallback(
      covariant sound_player.SoundPlayer player, MethodCall call) {
    Log.d('OS callback ${call.method} for slotNo: ${player.slotNo}');
    switch (call.method) {

      ///TODO implement in the OS code for each player.
      case 'onPlayerReady':
        {
          // ignore: avoid_dynamic_calls
          final result = call.arguments['arg'] as bool;
          Log.d('onPlayerReady $result');
          onPlayerReady(player, result: result);
        }
        break;

      case 'updateProgress':
        {
          // ignore: avoid_dynamic_calls
          final arguments = call.arguments['arg'] as String;
          sound_player.updateProgress(
              player, PlayerBasePlugin.dispositionFromJSON(arguments));
        }
        break;

      case 'audioPlayerFinishedPlaying':
        {
          // ignore: avoid_dynamic_calls
          final arguments = call.arguments['arg'] as String;

          sound_player.audioPlayerFinished(
              player, PlayerBasePlugin.dispositionFromJSON(arguments));
        }
        break;

      case 'pause':
        {
          sound_player.onSystemPaused(player);
        }
        break;

      case 'resume':
        {
          sound_player.onSystemResumed(player);
        }
        break;

      /// Callback in response to call to getDuration.
      /// The OS has calculated the duration and we now have the results.
      case 'durationResults':
        _onDurationResults(call);
        break;

      /// the OS media player encounted an error
      case 'onError':
        {
          // ignore: avoid_dynamic_calls
          final json = convert.jsonDecode(call.arguments['arg'] as String)
              as Map<String, dynamic>;

          final description = json['description'] as String;

          final callbackUuid = json['callbackUuid'] as String;
          if (Platform.isAndroid) {
            final androidWhat = json['android_what'] as int;
            final androidExtra = json['android_extra'] as int;
            Log.e('onError: $description android_what $androidWhat '
                'android_extra: $androidExtra');
          } else {
            Log.e('onError: $description');
          }

          /// If there is an outstanding callback then complete it
          /// so the UI doesn't hang.
          _callbackMap[callbackUuid]!.completeError(description);

          sound_player.onSystemError(player, description);
        }
        break;
    }

    throw ArgumentError('Unknown method ${call.method}');
  }

  /// Called when the OS resumes our app.
  /// We need to broadcast this to all player SlotEntries.
  @override
  void onSystemAppResumed() {
    forEachSlot((entry) {
      /// knowledge of the AudioPlayer at this level is a little
      /// ugly but I'm trying to keep the public api that
      /// AudioPlayer exposes clean.
      sound_player.onSystemAppResumed(entry as sound_player.SoundPlayer);
    });
  }

  /// Called when the OS resumes our app.
  /// We need to broadcast this to all player SlotEntries.
  @override
  void onSystemAppPaused() {
    forEachSlot((entry) {
      /// knowledge of the AudioPlayer at this level is a little
      /// ugly but I'm trying to keep the public api that
      /// AudioPlayer exposes clean.
      sound_player.onSystemAppPaused(entry as sound_player.SoundPlayer);
    });
  }
}
