//  Converted to Swift 5.2 by Swiftify v5.2.19227 - https://swiftify.com/
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


import 'dart:typed_data';

import 'package:sounds/src/ios/sounds.dart';
import 'package:sounds/src/platform/sounds_platform_api.dart';
// import 'package:sounds_platform_interface/sounds_platform_interface.dart';

import '../platform/sounds_platform_api.dart';
import 'frameworks/avfoundation/avaudioplayer.dart';
import 'frameworks/avfoundation/avaudiosession.dart';
import 'frameworks/avfoundation/avfoundation.dart';




class SoundPlayer implements  AVAudioPlayerDelegate {

    SoundPlayerProxy _playerProxy;
    AVAudioPlayer audioPlayer;
    var _isPaused = false;
    t_SET_CATEGORY_DONE _setCategoryDone;
    t_SET_CATEGORY_DONE _setActiveDone;

     Uri _audioFileURL;
     
   

      @override
  MediaFormatResponse getNativeDecoderFormats(MediaFormatProxy proxy) {
    // TODO: implement getNativeDecoderFormats
    throw UnimplementedError();
  }

  @override
  MediaFormatResponse getNativeEncoderFormats(MediaFormatProxy proxy) {
    // TODO: implement getNativeEncoderFormats
    throw UnimplementedError();
  }






  @override
  Response initializePlayer(InitializePlayer initializePlayer) {
     _isPaused = false;
        
        
  }

  @override
  Response initializePlayerWithShade(InitializePlayerWithShade initializePlayerWithShade) {
    // TODO: implement initializePlayerWithShade
    throw UnimplementedError();
  }

  @override
  Response initializeRecorder(SoundRecorderProxy recorder) {
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
                _isPaused = false;

                print("audioPlayer is not playing!\n");
                response.success = false;
                response.error = "audioPlayer is not playing";
                response.errorCode = SoundsToPlatformApi.errnoNotPlaying;
            } else {
                _pause();
                response.success = true;
            }
        } else {
            print("resumePlayer : player is not set\n")
              response.success = false;
                response.error = "audioPlayer is unknown";
                response.errorCode = SoundsToPlatformApi.errnoUnknownPlayer;
        }

        return response;
    }
  


    void _pause() {
        audioPlayer?.pause();
        _isPaused = true;
        stopProgressTimer();
        if (_setActiveDone != t_SET_CATEGORY_DONE.by_USER /* The caller did it himself : Sounds must not change that) */
           && (_setActiveDone != t_SET_CATEGORY_DONE.not_SET)) {
            try {
                 AVAudioSession.sharedInstance().setActive(false);
            } catch(_) {
            }
            _setActiveDone = t_SET_CATEGORY_DONE.not_SET;
        }
    }



  @override
  Response releaseAudioFocus() {
    // TODO: implement releaseAudioFocus
    throw UnimplementedError();
  }

  /// 
  Response releasePlayer() {
        
  }

  @override
  Response requestAudioFocus(AudioFocusProxy requestAudioFocus) {
    // TODO: implement requestAudioFocus
    throw UnimplementedError();
  }

  @override
  Response resumePlayer() {
   var response = Response();
        _isPaused = false;

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
                 AVAudioSession.sharedInstance().setActive(true);
            } catch(_) {
            }
            var b = resume();
            if (b) {
                var filePath = _audioFileURL?.absoluteString;
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
        _isPaused = true;

        var b = false;
       
            b = audioPlayer?.play() ?? false;
            if (b) {
                startProgressTimer();
                if (_setActiveDone == t_SET_CATEGORY_DONE.not_SET) {
                    try {
                        AVAudioSession.sharedInstance().setActive(true);
                    // ignore: avoid_catches_without_on_clauses
                    } catch(_) {
                    }
                    _setActiveDone = t_SET_CATEGORY_DONE.for_PLAYING;
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
            audioPlayer?.currentTime = TimeInterval(offset.inMilliseconds / 1000);
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
            audioPlayer?.volume = volume / 1000.0;
            response.success = true;
        } else {
          response.success = false;
          response.error = 'AudioPlayer is not set';
          response.errorCode = SoundsToPlatformApi.errnoUnknownPlayer;

        }
    }
  @override
  Response startPlayer(TrackProxy trackProxy, Duration startAt) {
    var response = Response();


     var audioFileURL = URL(string: trackProxy.path ?? "");
        // Able to play in silent mode

        if (_setCategoryDone == t_SET_CATEGORY_DONE.not_SET) {
            
                try
                { 
                  AVAudioSession.sharedInstance().setCategory(t_SET_CATEGORY_DONE.for_PLAYING);
            // ignore: avoid_catches_without_on_clauses
            } catch(_) {
            }
            _setCategoryDone = t_SET_CATEGORY_DONE.for_PLAYING;
        }
        // Able to play in background
        if (_setActiveDone == t_SET_CATEGORY_DONE.not_SET) {
            
                try { 
                  AVAudioSession.sharedInstance().setActive(true);
            // ignore: avoid_catches_without_on_clauses
            } catch(_) {
            }
            _setActiveDone = t_SET_CATEGORY_DONE.for_PLAYING;
        }

        _isPaused = false;

       
            // if (!audioPlayer) { // Fix sound distoring when playing recorded audio again.
            try{
                
              audioPlayer = AVAudioPlayer(contentsOf: audioFileURL);

              seekToPlayer(startAt);
                
            // ignore: avoid_catches_without_on_clauses
            } catch(_) {
            }
            audioPlayer?.delegate = this;
            // }
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

            return response;
        
    }



  /// not currently supported.
    Response start(Uint8List  fromBuffer) {//  : FlutterStandardTypedData?, result: FlutterResult) {
        var response = Response();
        try {
            var data = fromBuffer?.buffer;
            if (data != null) {
                audioPlayer =  AVAudioPlayer(data: data);
            }
        // ignore: avoid_catches_without_on_clauses
        } catch(_) {
        }
        audioPlayer?.delegate = this;
        // Able to play in silent mode
        if (_setCategoryDone == t_SET_CATEGORY_DONE.not_SET) {
            try {
                AVAudioSession.sharedInstance().setCategory(
                    t_SET_CATEGORY_DONE.for_PLAYING);
            // ignore: avoid_catches_without_on_clauses
            } catch(_) {
            }
            _setCategoryDone = t_SET_CATEGORY_DONE.for_PLAYING;
        }
        // Able to play in background
        if (_setActiveDone == t_SET_CATEGORY_DONE.not_SET) {
            try {
                 AVAudioSession.sharedInstance().setActive(true);
            // ignore: avoid_catches_without_on_clauses
            } catch(_) {
            }
            _setActiveDone = t_SET_CATEGORY_DONE.for_PLAYING;
        }
        _isPaused = false;
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
        _isPaused = false;
        if (audioPlayer != null) {
            audioPlayer?.stop();
            audioPlayer = null;
        }
         /* The caller did it himself : Sounds must not change that) */ 
        if ((_setActiveDone != t_SET_CATEGORY_DONE.by_USER)
        && (_setActiveDone != t_SET_CATEGORY_DONE.not_SET)) {
           
                try{
                   AVAudioSession.sharedInstance().setActive(false);
            // ignore: avoid_catches_without_on_clauses
            } catch(_) {
            }
            _setActiveDone = t_SET_CATEGORY_DONE.not_SET;
        }
    }


    void updateProgress() {
        print("entered updateProgress");
        var duration = audioPlayer!.duration * 1000;
        var currentTime = audioPlayer?.currentTime! * 1000;

        print("""
sending updateProgress: duration: $duration, position: $currentTime""");

        // TODO: call dart updateProgress

        if (playbackTimerRunning)
        {
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
        if ((_setActiveDone != t_SET_CATEGORY_DONE.by_USER 
        ) && (_setActiveDone != t_SET_CATEGORY_DONE.not_SET)) {
            try {
                AVAudioSession.sharedInstance().setActive(false);
            // ignore: avoid_catches_without_on_clauses
            } catch(_) {
            }
            _setActiveDone = t_SET_CATEGORY_DONE.not_SET;
        }
        if (audioPlayer!=null) {
        var duration = audioPlayer.duration * 1000;
        var currentTime = audioPlayer.currentTime * 1000;
        

         print("sending updateProgress: duration: $duration, position: $currentTime");

        /// TODO call dart onStopped and may need to send final progress update.
        _isPaused = false;
        }
        stopProgressTimer();
    }



    void _setCategory(String categ, String mode, int options) {
        // Able to play in silent mode
        var b = false;
        
            try{ 
              AVAudioSession.sharedInstance().setCategory(
                AVAudioSession.Category(rawValue: categ!/* AVAudioSessionCategoryPlayback */),
                        mode: AVAudioSession.Mode(rawValue: mode),
                        options: AVAudioSession.CategoryOptions(rawValue: UInt(options)));
            b = true;
        // ignore: avoid_catches_without_on_clauses
        } catch(_) {
        }
        // The caller did it himself : Sounds must not change that)
        _setCategoryDone = t_SET_CATEGORY_DONE.by_USER; 
        _setActiveDone = t_SET_CATEGORY_DONE.not_SET;
        // var r = NSNumber(value: b);
        // result(r)
    }

    void _setActive(bool enabled) {
        if (enabled) {
            if (_setActiveDone != t_SET_CATEGORY_DONE.not_SET) {
                // Already activated. Nothing todo;
                // The caller did it himself : Sounds must not change that)
                _setActiveDone = t_SET_CATEGORY_DONE.by_USER; 
                return;
            }
            
            _setActiveDone = t_SET_CATEGORY_DONE.by_USER ;
        } else {
            if (_setActiveDone == t_SET_CATEGORY_DONE.not_SET) {
                // Already desactivated
                return;
            }
            _setActiveDone = t_SET_CATEGORY_DONE.not_SET;
        }
        var b = false;
        try{ AVAudioSession.sharedInstance().setActive(enabled);
            b = true;
        // ignore: avoid_catches_without_on_clauses
        } catch(_) {
        }
        // var r = NSNumber(value: b)
        // result(r)
    }

}
