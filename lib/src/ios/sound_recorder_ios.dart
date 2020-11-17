//  Converted to Swift 5.2 by Swiftify v5.2.19227 - https://swiftify.com/
//
//  SoundRecorder.swift
//  Pods
//
//  Created by larpoux on 24/03/2020.
//
//
//  SoundRecorder.swift
//  flauto
//
//  Created by larpoux on 24/03/2020.
//

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

// func SoundRecorderReg(_ registrar: (NSObjectProtocol & FlutterPluginRegistrar)?) {
//     SoundRecorderManager.register(with: registrar!)
// }

// var soundRecorderManager: SoundRecorderManager? // Singvaron

import 'package:dart_native/dart_native.dart';
import 'package:dart_native/src/ios/foundation/objc_basic_type.dart';
import 'package:dart_native/src/ios/foundation/nserror.dart';
import 'package:dart_numerics/dart_numerics.dart';
import 'package:sounds/src/ios/frameworks/avfoundation/avaudiosessioncategory.dart';
import 'package:sounds/src/ios/frameworks/avfoundation/avaudiosessiontypes.dart';
import 'package:sounds/src/ios/frameworks/avfoundation/nsurl.dart';
import 'package:sounds/src/ios/sounds.dart';
import 'package:sounds/src/platform/sounds_platform_api.dart';
import 'package:sounds_common/sounds_common.dart';

import 'frameworks/avfoundation/avaudiorecorder.dart';
import 'frameworks/avfoundation/avaudiosession.dart';
import 'frameworks/avfoundation/avaudiosessionportoverride.dart';
import 'frameworks/avfoundation/avkeys.dart';
import 'response_extension.dart';

class SoundRecorderIOS implements AVAudioRecorderDelegate {
  Uri audioFileURL;
  AVAudioRecorder audioRecorder;

  t_SET_CATEGORY_DONE setCategoryDone;
  t_SET_CATEGORY_DONE setActiveDone;

  ///TODO this is unused but might still need to be
  //Duration _recordingProgressInterval = Duration(milliseconds: 100);

  @override
  // ignore_for_file: override_on_non_overriding_member
  Response setRecordingProgressInterval(
      SetRecordingProgressInterval setRecordingProgressInterval) {
    // _recordingProgressInterval =
    //     Duration(milliseconds: setRecordingProgressInterval.interval);

    return Responses.success();
  }

  void initializeSoundRecorder() {}

  @override
  // Originally took SoundRecorderProxy
  ///TODO response needs to be phased out
  Response releaseRecorder(SoundRecorderProxy recorder) {
    return Response();
  }

  ///TODO response needs to be phased out
  @override
  Response startRecording(StartRecording startRecording) {
    //var args = call.arguments as! Dictionary<String, Any>
    var path = startRecording.track.path;

    ///TODO these will definitley need to be used
    // var sampleRateArgs = startRecording.track.mediaFormat.sampleRate;
    // var numChannelsArgs = startRecording.track.mediaFormat.numChannels;
    var iosQuality = startRecording.quality;
    var bitRate = startRecording.track.mediaFormat.bitRate;
    var formatArg = startRecording.track.mediaFormat.name;
    var sampleRate = 44100;
    var numChannels = 2;

    /// TODO: map mediaFormat name to format id.
    var format = formatArg;
    audioFileURL = Uri(path: path);

    var audioSettings = <dynamic, NSNumber>{
      AVKeys.AVSampleRateKey: NSNumber(sampleRate),
      AVKeys.AVFormatIDKey: NSNumber(/*Int32*/ (format)),
      AVKeys.AVNumberOfChannelsKey: NSNumber(numChannels),
      AVKeys.AVEncoderAudioQualityKey: NSNumber(iosQuality ?? 0x40)
    };

    // If bitrate is defined, the use it, otherwise use the OS default
    if (bitRate != null) {
      audioSettings[AVKeys.AVEncoderBitRateKey] = NSNumber(bitRate ?? 0);
    }

    // Setup audio session the first time the user starts recording with this SoundRecorder instance.
    if ((setCategoryDone == t_SET_CATEGORY_DONE.not_SET) ||
        (setCategoryDone == t_SET_CATEGORY_DONE.for_PLAYING)) {
      var audioSession = AVAudioSession.sharedInstance();
      try {
        audioSession.setCategory(
            category: AVAudioSessionCategory.PlayAndRecord,
            options: AVAudioSessionCategoryOptions.AllowBluetooth
                as AVAudioSessionCategoryOptions);
      } on Exception catch (e) {
        Log.d(e.toString());
      }
      setCategoryDone = t_SET_CATEGORY_DONE.for_RECORDING;

      ///May still need to be used
      //Error error;

      // set volume default to speaker
      //var success = false;
      try {
        //preffered method
        // try //audioSession.overrideOutputAudioPort(AVAudioSessionPortOverrideSpeaker)

        audioSession
            .overrideOutputAudioPort(AVAudioSessionPortOverride.Speaker);
        //success = true;
      } on Exception catch (e) {
        Log.d(e.toString());
      }
    }

    try {
      //if let audioFileURL = audioFileURL, let audioSettings =
      //audioSettings as? [String : Any] {
      //      audioRecorder = try AVAudioRecorder(
      //         url: audioFileURL,
      //         settings: audioSettings) I dont even understand
      //It looks like hes just trying to give the current audioRecorder a URL.
      //I dont get why he thought all that was neccesary.
      if (audioFileURL != null) {
        audioRecorder.url = audioFileURL as NSURL;
      }
      // ignore: avoid_catches_without_on_clauses
    } catch (e) {}

    audioRecorder.delegate = this;
    audioRecorder.record();

    audioRecorder.meteringEnabled = true;
    startProgressTimer();

    //var filePath = audioFileURL.path; never used
    return Responses.success();
  }

  @override
  Response stopRecording(SoundRecorderProxy recorder) {
    audioRecorder?.stop();

    stopProgressTimer();

    return Responses.success();
  }

  ///
  Response pauseRecording(SoundRecorderProxy recorder) {
    audioRecorder?.pause();

    stopProgressTimer();
    return Responses.success();
  }

  @override
  Response resumeRecording(SoundRecorderProxy recorder) {
    var b = audioRecorder?.record() ?? false;
    startProgressTimer();
    if (b) {
      return Responses.success();
    } else {
      return Responses.onError(
          SoundsToPlatformApi.errnoGeneral, "Failed to resume recording");
    }
  }

  bool recordingTimerRunning = false;
  void startProgressTimer() {
    stopProgressTimer();
    print(
        "Starting Recording ProgressTimer interval: $_recorderProgressInterval");

    recordingTimerRunning = true;

    Future.delayed(_recorderProgressInterval, () {
      updateProgress();
    });

    print("started ProgressTimer");
  }

  void stopProgressTimer() {
    recordingTimerRunning = true;
    print("stopping RecordingProgressTimer");
  }

  Duration _recorderProgressInterval = Duration(milliseconds: 100);

  ///TODO response needs to be phased out
  @override
  Response setPlaybackProgressInterval(Duration interval) {
    _recorderProgressInterval = interval;
    return Response();
  }

  void updateProgress() {
    print("entered updateProgress");

    var decibels = getDbLevel();
    var currentTime = audioRecorder.currentTime.value * 1000;

    print("""
sending updateProgress: decibels: $decibels, position: $currentTime""");

    // TODO: call dart updateProgress

    if (recordingTimerRunning) {
      Future.delayed(_recorderProgressInterval, () {
        /// TODO call back to dart
        updateProgress();
      });
    }
  }

  double getDbLevel() {
    // NSNumber *normalizedPeakLevel = [NSNumber numberWithDouble:MIN(pow(10.0, [audioRecorder peakPowerForChannel:0] / 20.0) * 160.0, 160.0)];
    audioRecorder?.updateMeters();
    // silence is -160. max volume is 0.
    //therefore, +160 as below to calculate. only worksfor +ve no.s
    var maxAmplitude =
        (audioRecorder.peakPowerForChannel(NSUInteger(0)) ?? 0.0) + 160;

    var db = 0.0;

    if (maxAmplitude != 0) {
      // Calculate db based on the following article.
      // https://stackoverflow.com/questions/10655703/what-does-androids-getmaxamplitude-function-for-the-mediarecorder-actually-gi
      //
      var ref_pressure = 51805.5336;
      var p = maxAmplitude / ref_pressure;
      var p0 = 0.0002;

      db = 20.0 * log10(p / p0);
    }

    return db;
  }

  @override
  void audioRecorderBeginInterruption(AVAudioRecorder recorder) {
    // TODO: implement audioRecorderBeginInterruption
  }

  @override
  void audioRecorderDidFinishRecordingSuccessfully(
      AVAudioRecorder recorder, bool flag) {
    // TODO: implement audioRecorderDidFinishRecordingSuccessfully
  }

  @override
  void audioRecorderEncodeErrorDidOccurError(AVAudioRecorder recorder,
      {NSError error}) {
    // TODO: implement audioRecorderEncodeErrorDidOccurError
  }

  @override
  void audioRecorderEndInterruption(AVAudioRecorder recorder) {
    // TODO: implement audioRecorderEndInterruption
  }

  @override
  void audioRecorderEndInterruptionWithFlags(
      AVAudioRecorder recorder, NSUInteger flags) {
    // TODO: implement audioRecorderEndInterruptionWithFlags
  }

  @override
  void audioRecorderEndInterruptionWithOptions(
      AVAudioRecorder recorder, NSUInteger flags) {
    // TODO: implement audioRecorderEndInterruptionWithOptions
  }

  @override
  void registerAVAudioRecorderDelegate() {
    // TODO: implement registerAVAudioRecorderDelegate
    throw UnimplementedError();
  }
}

//---------------------------------------------------------------------------------------------
