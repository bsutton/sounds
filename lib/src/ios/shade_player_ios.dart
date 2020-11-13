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




import 'dart:io';

import 'package:dart_native/dart_native.dart';
import 'package:sounds/src/ios/frameworks/avfoundation/avaudiosessioncategory.dart';
import 'package:sounds/src/ios/frameworks/avfoundation/avaudiosessiontypes.dart';
import 'package:sounds/src/ios/sound_player_ios.dart';
import 'package:sounds/src/ios/sounds.dart';
import 'package:sounds_common/sounds_common.dart';

import '../../sounds.dart';
import 'frameworks/avfoundation/avaudioplayer.dart';
import 'frameworks/avfoundation/avaudiosession.dart';
import 'frameworks/avfoundation/hacks.dart';

/// Plays an audio track using the OSs on UI (sometimes referred to as a Shade) media
/// player.
/// Allows playback control even when the phone is locked.

/// post fix with _Sound to avoid conflicts with common libs including path_provider
// String GetDirectoryOfType_Sounds(FileManager.SearchPathDirectory dir)  {
//     var paths = FileManager.default.urls(for: dir, in: .userDomainMask).map(\.path)
//     return (paths.first ?? "") + "/"
// }

class FlutterError {
  String code;
  String message;
  String details;
  ///
  FlutterError({this.code, this.message, this.details});
}
class URLSessionDataTask {
}
class URL
{
  String fileURLWithPath;

  URL(String s, {String this.fileURLWithPath});

  int get scheme => 0;

  int get host => 0;
}

class NSURLSession{
  URLSessionDataTask dataTask({URL url, Set<dynamic> compvarionHandler}){

  }
}

class URLSession{
  //was originally but according to doco i think it should be this
  //https://developer.apple.com/documentation/foundation/nsurlsession/1409000-sharedsession?language=objc
  static NSURLSession sharedSession;
}

/// 
class ShadePlayerIOS extends SoundPlayerIOS
 {
   //Hacked props

    //Real props
    URL audioFileURL;
    Track track;
    Function forwardTarget;
    Function backwardTarget;
    Function pauseTarget;
    AVAudioSessionCategory _setActiveDone;
    AVAudioSessionCategory _setCategoryDone;
    ///
      void init() {
       /// super.init();
      }
    
    // ignore: avoid_positional_boolean_parameters
    void start(Track track, bool canPause, bool canSkipForward ,bool canSkipBackward) {
        if (track == null) {
          throw( 
            FlutterError(
              code: "UNAVAILABLE",
              message: "The track passed to startPlayer is not valid.",
              details: null));
        }


        // Check whether the audio file is stored as a path to a file or a buffer
        if (track.path != null) {
            audioFileURL = URL(track.path ?? "");
               
            // Able to play in silent mode
            if (_setCategoryDone == null) {
                
                    try{
                      //https://developer.apple.com/documentation/avfoundation/avaudiosessioncategoryoptions/avaudiosessioncategoryoptionduckothers?language=objc
                      //AVAudioSessionCategoryOptionDuckOthers = 0x2
                       AVAudioSession.sharedInstance().category = 
                       AVAudioSessionCategoryOptions.DuckOthers 
                       as AVAudioSessionCategory;
                    } on Exception catch (e){
                  Log.d(e.toString());
                }
                _setCategoryDone = AVAudioSessionCategory.Playback;
                //t_SET_CATEGORY_DONE.for_PLAYING;
            }

            // Able to play in background
            //_setActiveDone set category done is an enum already exposed so im
            //using that one we may need to a create another enum.
            if (_setActiveDone == null) {
            
                    try{
                      // originally ._setActive(true) but this prop does not exist
                      //on AVAudioSession.
                       AVAudioSession.sharedInstance().setActive(active: true);
                }on Exception catch(e){
                  Log.d(e.toString());
                }
               // t_SET_CATEGORY_DONE.for_PLAYING as String
                _setActiveDone = AVAudioSessionCategory.Playback;
                //_setActiveDone = t_SET_CATEGORY_DONE.for_PLAYING;
            }
            //isPaused does not exists so this is a placeholder for now.
            //for_playing is set in every circumstance so wil need to be changed



            // Check whether the file path points to a remote or local file
            if (track.path != null){
                // Initialize the audio player with the file that the given path points to,
                // and start playing.

                // if (!audioPlayer) { // Fix sound distoring when playing recorded audio again.
                try {
                    if (audioFileURL != null) {
                        audioPlayer = AVAudioPlayer.init(audioFileURL);
                    }
                } on Exception catch(e) 
                {
                  Log.d(e.toString());
                }
                audioPlayer.delegate = this;
                // }

                // Able to play in silent mode
                //I would argue we should never be able play when 
                //a phone is set to silent mode. I don't know of any
                //apps which breach that contract.
                // DispatchQueue.main.async(
                //     execute: {
                //         UIApplication.sharedSession.beginReceivingRemoteControlEvents()
                //     });

                audioPlayer?.play();
                startProgressTimer();
                //orginally audioFileURL?.absoluteString but I beleive this
                //achieves the same thing.
                var filePath = audioFileURL.fileURLWithPath;
            }
        } else {
            // The audio file is stored as a buffer
            var dataBuffer = track.buffer;
            //var bufferData = dataBuffer.data;
            NSData bufferData;
            for(var d in dataBuffer){
              bufferData.add(d);
            }
            try {
                if(bufferData != null) {
                    audioPlayer = AVAudioPlayer.initWithData(bufferData);
                }
            }
            on Exception catch(e){
                Log.d(e.toString());
            }
            audioPlayer.delegate = this;
            //TODO this line allows external devices such as headsets to control
            //playback.
           // UIApplication.sharedSession.beginReceivingRemoteControlEvents();
             
            audioPlayer.play();
            startProgressTimer();
        }
        //[ self invokeCallback:@"updatePlaybackState" arguments:playingState];
                    isPaused = false;

        // Display the notification with the media controls
        setupRemoteCommandCenter(canPause, canSkipForward: canSkipForward, canSkipBackward: canSkipBackward);
        setupNowPlaying();

    }

    void initializeShadePlayer(call: FlutterMethodCall, result: FlutterResult) {
        _setCategoryDone = .not_SET
        _setActiveDone = .not_SET
        result(NSNumber(value: true))
    }

    override func release(_ call: FlutterMethodCall?, result: FlutterResult) {
        // The code used to release all the media player resources is the same of the one needed
        // to stop the media playback. Then, use that one.
        // [self stopRecorder:result];
        stop();
        var commandCenter = MPRemoteCommandCenter.sharedSession();
        if (pauseTarget != null) {
                commandCenter.togglePlayPauseCommand.removeTarget(pauseTarget, action: null);
            pauseTarget = null;
        }
        if forwardTarget != null {
            if var forwardTarget = forwardTarget {
                commandCenter.nextTrackCommand.removeTarget(forwardTarget, action: null)
            }
            forwardTarget = null
        }

        if backwardTarget != null {
            if var backwardTarget = backwardTarget {
                commandCenter.previousTrackCommand.removeTarget(backwardTarget, action: null)
            }
            backwardTarget = null
        }

        getPlugin()?.freeSlot(slotNo: slotNo)
        result("The player has been successfully released")

    }

    override func getPlugin() -> SoundPlayerManager? {
        return shadePlayerManager
    }

    override func invokeCallback(_ methodName: String?, stringArg: String?) {
        var dic = [
            "slotNo": NSNumber(value: Int32(slotNo)),
            "arg": stringArg ?? ""
            ] as [String : Any]
        getPlugin()?.invokeCallback(methodName, arguments: dic)
    }

    func invokeCallback(_ methodName: String?, boolArg: Bool) {
        var dic = [
            "slotNo": NSNumber(value: Int32(slotNo)),
            "arg": NSNumber(value: boolArg)
        ]
        getPlugin()?.invokeCallback(methodName, arguments: dic)
    }

    // Give the system information about what the audio player
    // is currently playing. Takes in the image to display in the
    // notification to control the media playback.
    func setupNowPlaying() {
        // Initialize the MPNowPlayingInfoCenter

        var playingInfoCenter = MPNowPlayingInfoCenter.default()
        var songInfo: [AnyHashable : Any] = [:]
        // The caller specify an asset to be used.
        // Probably good in the future to allow the caller to specify the image itself, and not a resource.
        if (track?.albumArtUrl != null) && (NSString.self != NSNull.self) {
            // Retrieve the album art for the
            // current track .
            var url = URL(string: track?.albumArtUrl ?? "")
            var artworkImage: UIImage? = null
            do{
                var data = try Data(contentsOf: url!)
                artworkImage = UIImage(data: data)
            }
            catch{
                print("failed to set data")
                
            }
            
            
            if artworkImage != null {
                var albumArt = MPMediaItemArtwork(
                    boundsSize: artworkImage?.size ?? CGSize.zero,
                    requestHandler: { size in
                        return artworkImage!
                    })

                songInfo[MPMediaItemPropertyArtwork] = albumArt
            }
        } else if (track?.albumArtAsset) != null && (NSString.self != NSNull.self) {
            var artworkImage = UIImage(named: track?.albumArtAsset ?? "")
            if artworkImage != null {
                var albumArt = MPMediaItemArtwork(
                    boundsSize: artworkImage?.size ?? CGSize.zero,
                    requestHandler: { size in
                        return artworkImage!
                    })

                songInfo[MPMediaItemPropertyArtwork] = albumArt
            }
        } else if (track?.albumArtFile) != null && (NSString.self != NSNull.self) {
            var artworkImage = UIImage(contentsOfFile: track?.albumArtFile ?? "")
            if artworkImage != null {
                var albumArt = MPMediaItemArtwork(
                    boundsSize: artworkImage?.size ?? CGSize.zero,
                    requestHandler: { size in
                        return artworkImage!
                    })
                songInfo[MPMediaItemPropertyArtwork] = albumArt
            }
        } else {
            var artworkImage = UIImage(named: "AppIcon")
            if artworkImage != null {
                var albumArt = MPMediaItemArtwork(
                    boundsSize: artworkImage?.size ?? CGSize.zero,
                    requestHandler: { size in
                        return artworkImage!
                    })
                songInfo[MPMediaItemPropertyArtwork] = albumArt
            }
        }

        var progress = NSNumber(value: audioPlayer?.currentTime ?? 0.0)
        var duration = NSNumber(value: audioPlayer?.duration ?? 0.0)

        songInfo[MPMediaItemPropertyTitle] = track?.title
        songInfo[MPMediaItemPropertyArtist] = track?.artist
        songInfo[MPNowPlayingInfoPropertyElapsedPlaybackTime] = progress
        songInfo[MPMediaItemPropertyPlaybackDuration] = duration
        var b = audioPlayer?.isPlaying ?? false
        songInfo[MPNowPlayingInfoPropertyPlaybackRate] = NSNumber(value: b ? 1.0 : 0.0)

        playingInfoCenter.nowPlayingInfo = songInfo as? [String : Any]
    }

    void cleanTarget(bool canPause, {bool canSkipForward, bool canSkipBackward}) {
        // [commandCenter.playCommand setEnabled:YES];
        // [commandCenter.pauseCommand setEnabled:YES];
        //   [commandCenter.playCommand addTargetWithHandler: ^MPRemoteCommandHandlerStatus(MPRemoteCommandEvent * _Nonnull event) {
        //       // [[MediaController sharedInstance] playOrPauseMusic];    // Begin playing the current track.
        //       [self resumePlayer:result];
        //       return MPRemoteCommandHandlerStatusSuccess;
        //   }];
        //
        //   [commandCenter.pauseCommand addTargetWithHandler: ^MPRemoteCommandHandlerStatus(MPRemoteCommandEvent * _Nonnull event) {
        //       // [[MediaController sharedInstance] playOrPauseMusic];    // Begin playing the current track.
        //       [self pausePlayer:result];
        //       return MPRemoteCommandHandlerStatusSuccess;
        //   }];
        var commandCenter = MPRemoteCommandCenter.sharedSession()

        if pauseTarget != null {
            if var pauseTarget = pauseTarget {
                commandCenter.togglePlayPauseCommand.removeTarget(pauseTarget, action: null)
            }
            pauseTarget = null
        }
        if forwardTarget != null {
            if var forwardTarget = forwardTarget {
                commandCenter.nextTrackCommand.removeTarget(forwardTarget, action: null)
            }
            forwardTarget = null
        }

        if backwardTarget != null {
            if var backwardTarget = backwardTarget {
                commandCenter.previousTrackCommand.removeTarget(backwardTarget, action: null)
            }
            backwardTarget = null
        }
        commandCenter.togglePlayPauseCommand.isEnabled = true // If the caller does not want to control pause button, we will use our default action
        commandCenter.nextTrackCommand.isEnabled = canSkipForward
        commandCenter.previousTrackCommand.isEnabled = canSkipBackward

        do {
            pauseTarget = commandCenter.togglePlayPauseCommand.addTarget(handler: { event in

                var b = self.audioPlayer?.isPlaying ?? false
                // If the caller wants to control the pause button, just call him
                if b{
                    if canPause {
                        self.invokeCallback("pause", boolArg: true)
                    } else {
                        self.pause()
                    }
                } else {
                    if canPause {
                        self.invokeCallback("resume", boolArg: true)
                    } else {
                        self.resume()
                    }
                }
                return .success
            })
        }

        if canSkipForward {
            forwardTarget = commandCenter.nextTrackCommand.addTarget(handler: { event in
                self.invokeCallback("skipForward", stringArg: "")
                // [[MediaController sharedInstance] fastForward];    // forward to next track.
                return .success
            })
        }

        if canSkipBackward {
            backwardTarget = commandCenter.previousTrackCommand.addTarget(handler: { event in
                self.invokeCallback("skipBackward", stringArg: "")
                // [[MediaController sharedInstance] rewind];    // back to previous track.
                return .success
            })
        }
    }

    override func stop() {
        stopProgressTimer()
        isPaused = false
        if audioPlayer != null {
            audioPlayer?.stop()
            //audioPlayer = null;
        }
        // ????  [self cleanTarget:false canSkipForward:false canSkipBackward:false];
        if (_setActiveDone != .by_USER /* The caller did it himself : Sounds must not change that) */) && (setActiveDone != .not_SET) {
            cleanTarget(false, canSkipForward: false, canSkipBackward: false) // ???
            do {
                try AVAudioSession.sharedInstance()._setActive(false)
            } catch {
            }
            setActiveDone = .not_SET
        }
    }

    // Give the system information about what to do when the notification
    // control buttons are pressed.
    void setupRemoteCommandCenter(bool canPause, {bool canSkipForward, bool canSkipBackward}) {
        cleanTarget(canPause, canSkipForward: canSkipForward, canSkipBackward: canSkipBackward);
    }
}


//---------------------------------------------------------------------------------------------

//---------------------------------------------------------------------------------------------
