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



import 'package:dart_numerics/dart_numerics.dart';
import 'package:sounds/src/ios/sounds.dart';
import 'package:sounds/src/platform/sounds_platform_api.dart';

import 'frameworks/avfoundation/avaudiorecorder.dart';
import 'response_extension.dart';


class SoundRecorder implements AVAudioRecorderDelegate {
     Uri audioFileURL;
     AVAudioRecorder audioRecorder;
     
     
     t_SET_CATEGORY_DONE setCategoryDone;
     t_SET_CATEGORY_DONE  setActiveDone;
     


    Duration _recordingProgressInterval = Duration(milliseconds: 100);

  @override
  Response setRecordingProgressInterval(SetRecordingProgressInterval 
    setRecordingProgressInterval) {

     _recordingProgressInterval 
     = Duration(milliseconds: setRecordingProgressInterval.interval);

     return Responses.success();
  }



    void initializeSoundRecorder() {
    }


  @override
  Response releaseRecorder(SoundRecorderProxy recorder) {
  
  }



  @override
  Response startRecording(StartRecording startRecording) {
        //var args = call.arguments as! Dictionary<String, Any>
        var path = startRecording.track.path;
        var sampleRateArgs = startRecording.track.mediaFormat.sampleRate;
        var numChannelsArgs = startRecording.track.mediaFormat.numChannels;
        var iosQuality = startRecording.quality;
        var bitRate = startRecording.track.mediaFormat.bitRate;
        var formatArg = startRecording.track.mediaFormat.name;

        // var sampleRate: Float = 44100

        // var numChannels = 2

      /// TODO: map mediaFormat name to format id.
        var format = formatArg?.intValue ?? 0




        audioFileURL = Uri(fileURLWithPath: path ?? "")

        var audioSettings = [
            AVSampleRateKey : NSNumber(value: sampleRate),
            AVFormatIDKey : NSNumber(value: Int32(format)),
            AVNumberOfChannelsKey : NSNumber(value: Int32(numChannels)),
            AVEncoderAudioQualityKey : NSNumber(value: Int32(iosQuality?.intValue ?? 0))
        ]

        // If bitrate is defined, the use it, otherwise use the OS default
        if (bitRate != null) {
            audioSettings[AVEncoderBitRateKey] = NSNumber(value: Int32(bitRate?.intValue ?? 0))
        }



        // Setup audio session the first time the user starts recording with this SoundRecorder instance.
        if ((setCategoryDone == t_SET_CATEGORY_DONE.not_SET) 
          || (setCategoryDone == t_SET_CATEGORY_DONE.for_PLAYING)) {
            var audioSession = AVAudioSession.sharedInstance();
            try {
                audioSession.setCategory(    t_SET_CATEGORY_DONE.for_RECORDING ,//         .playAndRecord,
                    options: .allowBluetooth);
            } catch {
            }
            setCategoryDone = t_SET_CATEGORY_DONE.for_RECORDING;
            Error error;

            // set volume default to speaker
            var success = false;
            try {
                //preffered method
               // try //audioSession.overrideOutputAudioPort(AVAudioSessionPortOverrideSpeaker)

                // tristans go at compiling.
                _ = audioSession.preferredInput
                 try audioSession.overrideOutputAudioPort(AVAudioSession.PortOverride(rawValue: AVAudioSession.PortOverride.RawValue(kAudioSessionOverrideAudioRoute_Speaker))!);
                success = true;
            } catch {
                print("error doing outputaudioportoverride - \(error.localizedDescription)");
            }
        }


        try {
          
          var audioSettings = audioSettings as String;
            if (audioFileURL != null)  {
                audioRecorder = AVAudioRecorder(
                    url: audioFileURL,
                    settings: audioSettings);
            }
        // ignore: avoid_catches_without_on_clauses
        } catch(e) {
        }

        audioRecorder?.delegate = this;
        audioRecorder?.record();

        audioRecorder?.isMeteringEnabled = true;
        startProgressTimer();

        var filePath = audioFileURL?.path;
        Responses.success();
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
        if (b)
        {
          return Responses.success();
        }
        else
        {
          return Responses.onError(SoundsToPlatformApi.errnoGeneral
              , "Failed to resume recording");
        }
    }

  bool recordingTimerRunning = false;
  void startProgressTimer() {
        stopProgressTimer();
        print("Starting Recording ProgressTimer interval: $_recorderProgressInterval");

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
  @override
  Response setPlaybackProgressInterval(Duration interval) {
    
    _recorderProgressInterval = interval;
  }



    void updateProgress() {
        print("entered updateProgress");

      
         var decibels = getDbLevel();
        var currentTime = audioPlayer?.currentTime! * 1000;
                

        print("""
sending updateProgress: decibels: $decibels, position: $currentTime""");

        // TODO: call dart updateProgress

        if (recordingTimerRunning)
        {
         Future.delayed(_recorderProgressInterval, () {
          

          /// TODO call back to dart
           updateProgress();

        });
        }
    }


    double getDbLevel() {
        // NSNumber *normalizedPeakLevel = [NSNumber numberWithDouble:MIN(pow(10.0, [audioRecorder peakPowerForChannel:0] / 20.0) * 160.0, 160.0)];
        audioRecorder?.updateMeters();
        // silence is -160 max volume is 0 hence +160 as below calc only worksfor +ve no.s
        var maxAmplitude = (audioRecorder?.peakPower(forChannel: 0) ?? 0.0) + 160;

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

}

//---------------------------------------------------------------------------------------------


