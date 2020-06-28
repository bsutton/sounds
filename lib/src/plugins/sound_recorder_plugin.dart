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
import 'dart:convert' as convert;
import 'dart:io';
import 'dart:math';

import 'package:flutter/services.dart';

import '../audio_source.dart';
import '../media_format/native_media_format.dart';
import '../quality.dart';
import '../sound_recorder.dart' as sound_recorder;
import 'base_plugin.dart';

/// Provides communications with the platform
/// specific plugin.
class SoundRecorderPlugin extends BasePlugin {
  /// ignore: prefer_final_fields
  static var _slots = <SlotEntry>[];

  static SoundRecorderPlugin _self;

  /// Factory
  factory SoundRecorderPlugin() {
    _self ??= SoundRecorderPlugin._internal();
    return _self;
  }
  SoundRecorderPlugin._internal()
      : super('com.bsutton.sounds.sounds_recorder', _slots);

  ///
  Future<void> initializeRecorder(
      covariant sound_recorder.SoundRecorder recorder) async {
    await invokeMethod(
        recorder, 'initializeSoundRecorder', <String, dynamic>{});
  }

  /// Releases the slot used by the connector.
  /// To use a plugin you start by calling [register]
  /// and finish by calling [release].
  Future<void> releaseRecorder(sound_recorder.SoundRecorder recorder) async {
    await invokeMethod(recorder, 'releaseSoundRecorder', <String, dynamic>{});
  }

  ///
  Future<void> start(
    sound_recorder.SoundRecorder recorder,
    String path,
    NativeMediaFormat mediaFormat,
    AudioSource audioSource,
    Quality iosQuality,
  ) async {
    var param = <String, dynamic>{
      'path': path,
      'sampleRate': mediaFormat.sampleRate,
      'numChannels': mediaFormat.numChannels,
      'bitRate': mediaFormat.bitRate,
      'audioSource': audioSource?.value,
    };

    if (Platform.isAndroid) {
      param['encoder'] = mediaFormat.androidEncoder;
      param['format'] = mediaFormat.androidFormat;
    } else {
      param['format'] = mediaFormat.iosFormat;
      param['iosQuality'] = iosQuality?.value;
    }
    await invokeMethod(recorder, 'startRecorder', param);
  }

  ///
  Future<void> stop(sound_recorder.SoundRecorder recorder) async {
    await invokeMethod(recorder, 'stopRecorder', <String, dynamic>{});
  }

  ///
  Future<void> pause(sound_recorder.SoundRecorder recorder) async {
    await invokeMethod(recorder, 'pauseRecorder', <String, dynamic>{});
  }

  ///
  Future<void> resume(sound_recorder.SoundRecorder recorder) async {
    await invokeMethod(recorder, 'resumeRecorder', <String, dynamic>{});
  }

  ///
  Future<void> setSubscriptionInterval(
      sound_recorder.SoundRecorder recorder, Duration interval) async {
    await invokeMethod(recorder, 'setSubscriptionInterval', <String, dynamic>{
      'milli': interval.inMilliseconds,
    });
  }

  ///
  Future<void> setDbPeakLevelUpdate(
      sound_recorder.SoundRecorder recorder, Duration interval) async {
    await invokeMethod(recorder, 'setDbPeakLevelUpdate', <String, dynamic>{
      'milli': interval.inMilliseconds,
    });
  }

  /// Enables or disables processing the Peak level in db's. Default is disabled
  Future<void> setDbLevelEnabled(sound_recorder.SoundRecorder recorder,
      {bool enabled}) async {
    await invokeMethod(recorder, 'setDbLevelEnabled', <String, dynamic>{
      'enabled': enabled,
    });
  }

  Future<dynamic> onMethodCallback(
      covariant sound_recorder.SoundRecorder recorder, MethodCall call) {
    switch (call.method) {
      case "updateRecorderProgress":
        _updateRecorderProgress(call, recorder);
        break;

      case "updateDbPeakProgress":
        var decibels = call.arguments['arg'] as double;
        // We use max to ensure that we always report a +ve db.
        // We have seen -ve db come up from the OS which is not
        // valid (i.e. silence is 0 db).
        decibels = max(0, decibels);

        /// sanity check. 194 is the theoretical upper limit on undistorted
        ///  sound in air. (above this its a shock wave)
        decibels = min(194, decibels);
        sound_recorder.recorderUpdateDbPeakDispostion(recorder, decibels);
        break;

      default:
        throw ArgumentError('Unknown method ${call.method}');
    }
    return null;
  }

  void _updateRecorderProgress(
      MethodCall call, sound_recorder.SoundRecorder recorder) {
    var result = convert.json.decode(call.arguments['arg'] as String)
        as Map<String, dynamic>;

    var duration = Duration(
        milliseconds:
            double.parse(result['current_position'] as String).toInt());

    sound_recorder.recorderUpdateDuration(recorder, duration);
  }

  /// Called when the OS resumes our app.
  /// We need to broadcast this to all player SlotEntries.
  void onSystemAppResumed() {
    forEachSlot((entry) {
      /// knowledge of the AudioPlayer at this level is a little
      /// ugly but I'm trying to keep the public api that
      /// AudioPlayer exposes clean.
      sound_recorder.onSystemAppResumed(entry as sound_recorder.SoundRecorder);
    });
  }

  /// Called when the OS resumes our app.
  /// We need to broadcast this to all player SlotEntries.
  void onSystemAppPaused() {
    forEachSlot((entry) {
      /// knowledge of the AudioPlayer at this level is a little
      /// ugly but I'm trying to keep the public api that
      /// AudioPlayer exposes clean.
      sound_recorder.onSystemAppPaused(entry as sound_recorder.SoundRecorder);
    });
  }
}
