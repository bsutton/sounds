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

import 'package:dart_native/dart_native.dart';
import 'package:sounds/src/ios/frameworks/avfoundation/avaudiosessioncategory.dart';
import 'package:sounds/src/ios/frameworks/avfoundation/avaudiosessiontypes.dart';
import 'package:sounds/src/ios/frameworks/mpclasses/mpnowplayinginfoproperty.dart';
import 'package:sounds/src/ios/ios_to_platform_api.dart';
import 'package:sounds/src/ios/sound_player_ios.dart';
import 'package:sounds/src/ios/sounds.dart';
import 'package:sounds_common/sounds_common.dart';

import '../../sounds.dart';
import 'frameworks/avfoundation/avaudioplayer.dart';
import 'frameworks/avfoundation/avaudiosession.dart';
import 'frameworks/mpclasses/mediaItemproperty.dart';
import 'frameworks/mpclasses/mpmediaitemartwork.dart';
import 'frameworks/mpclasses/mpremotecommand.dart';
import 'frameworks/mpclasses/mpremotecommandcenter.dart';
import 'frameworks/nsclasses/nsdata.dart';
import 'frameworks/util/uiimage.dart';

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

class URLSessionDataTask {}

class URL {
  String fileURLWithPath;

  URL({String this.fileURLWithPath});

  int get scheme => 0;

  int get host => 0;
}

//TODO fix what this is returning
class NSURLSession {
  URLSessionDataTask dataTask({URL url, Set<dynamic> compvarionHandler}) {
    return URLSessionDataTask();
  }
}

class URLSession {
  //was originally but according to doco i think it should be this
  //https://developer.apple.com/documentation/foundation/nsurlsession/1409000-sharedsession?language=objc
  static NSURLSession sharedSession;
}

///
class ShadePlayerIOS extends SoundPlayerIOS {
  //Hacked props

  //Real props
  URL audioFileURL;
  Track track;
  Function forwardTarget;
  Function backwardTarget;
  Function pauseTarget;
  AVAudioSessionCategory _setActiveDone;
  AVAudioSessionCategory _setCategoryDone;

  // ///
  // void init() {
  //   super.init();
  // }

  // ignore: avoid_positional_boolean_parameters
  void start(
      Track track, bool canPause, bool canSkipForward, bool canSkipBackward) {
    if (track == null) {
      throw (FlutterError(
          code: "UNAVAILABLE",
          message: "The track passed to startPlayer is not valid.",
          details: null));
    }

    // Check whether the audio file is stored as a path to a file or a buffer
    if (track.path != null) {
      audioFileURL = URL(fileURLWithPath: track.path ?? "");

      // Able to play in silent mode
      if (_setCategoryDone == null) {
        try {
          //https://developer.apple.com/documentation/avfoundation/avaudiosessioncategoryoptions/avaudiosessioncategoryoptionduckothers?language=objc
          //AVAudioSessionCategoryOptionDuckOthers = 0x2
          AVAudioSession.sharedInstance().category =
              AVAudioSessionCategoryOptions.DuckOthers
                  as AVAudioSessionCategory;
        } on Exception catch (e) {
          Log.d(e.toString());
        }
        _setCategoryDone = AVAudioSessionCategory.Playback;
        //t_SET_CATEGORY_DONE.for_PLAYING;
      }

      // Able to play in background
      //_setActiveDone set category done is an enum already exposed so im
      //using that one we may need to a create another enum.
      if (_setActiveDone == null) {
        try {
          // originally ._setActive(true) but this prop does not exist
          //on AVAudioSession.
          AVAudioSession.sharedInstance().setActive(active: true);
        } on Exception catch (e) {
          Log.d(e.toString());
        }
        // t_SET_CATEGORY_DONE.for_PLAYING as String
        _setActiveDone = AVAudioSessionCategory.Playback;
        //_setActiveDone = t_SET_CATEGORY_DONE.for_PLAYING;
      }
      //isPaused does not exists so this is a placeholder for now.
      //for_playing is set in every circumstance so wil need to be changed

      // Check whether the file path points to a remote or local file
      if (track.path != null) {
        // Initialize the audio player with the file that the given path points to,
        // and start playing.

        // if (!audioPlayer) { // Fix sound distoring when playing recorded audio again.
        try {
          if (audioFileURL != null) {
            audioPlayer = AVAudioPlayer.init(audioFileURL);
          }
        } on Exception catch (e) {
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
        //var filePath = audioFileURL.fileURLWithPath;
      }
    } else {
      // The audio file is stored as a buffer
      var dataBuffer = track.buffer;
      //var bufferData = dataBuffer.data;
      NSData bufferData;
      for (var d in dataBuffer) {
        bufferData.add(d);
      }
      try {
        if (bufferData != null) {
          audioPlayer = AVAudioPlayer.initWithData(bufferData);
        }
      } on Exception catch (e) {
        Log.d(e.toString());
      }
      audioPlayer.delegate = this;
      //TODO this line allows external devices such as headsets to control
      //playback.
      // UIApplication.sharedSession.beginReceivingRemoteControlEvents();

      audioPlayer.play();
      startProgressTimer();
    }

    // Display the notification with the media controls
    setupRemoteCommandCenter(canPause,
        canSkipForward: canSkipForward, canSkipBackward: canSkipBackward);
    setupNowPlaying();
  }

  bool initializeShadePlayer() {
    _setCategoryDone = null;
    _setActiveDone = null;
    return NSNumber(true) as bool;
  }
  //where release would be called we now just call stop

  ///factory returns a sound player manager.
  IOSToPlatformAPI getPlugin() => IOSToPlatformAPI();

  // Give the system information about what the audio player
  // is currently playing. Takes in the image to display in the
  // notification to control the media playback.
  void setupNowPlaying() {
    // Initialize the MPNowPlayingInfoCenter
    ///After reading this article, https://developer.apple.com/documentation/mediaplayer/mpnowplayinginfocenter/1615899-defaultcenter?language=objc
    ///I believe this is the same as
    var playingInfoCenter = MPNowPlayingInfoCenter.defaultInstance();

    var songInfo = <String>[];
    // The caller specify an asset to be used.
    // Probably good in the future to allow the caller to specify the image itself, and not a resource.
    if ((track.albumArtUrl != null) && (this != null)) {
      // Retrieve the album art for the
      // current track .
      var url = URL(fileURLWithPath: track.albumArtUrl ?? "");

      //UI image might be the same as a flutter image
      //they're both just view components
      UIImage artworkImage = null;
      try {
        var data = NSData.fromURL(url);
        artworkImage = UIImage.imageWithData(data);
      } on Exception catch (e) {
        print("failed to set data");
        Log.d(e.toString());
      }

      if (artworkImage != null) {
        var albumArt = MPMediaItemArtwork(
            boundsSize: (artworkImage.size),
            requestHandler: () {
              artworkImage.size;
            });
        songInfo.add(MPMediaItemProperty.Artwork = albumArt as String);
      }
    } else if ((track.albumArtAsset) != null && (this != null)) {
      var artworkImage = UIImage.imageNamed(track.albumArtAsset ?? "");
      if (artworkImage != null) {
        var albumArt = MPMediaItemArtwork(
            boundsSize: (artworkImage.size),
            requestHandler: () {
              artworkImage.size;
            });

        songInfo.add(MPMediaItemProperty.Artwork = albumArt as String);
      }
    } else if ((track.albumArtFile) != null && (this != null)) {
      var artworkImage =
          UIImage.imageWithContentsOfFile(track.albumArtFile ?? "");
      if (artworkImage != null) {
        var albumArt = MPMediaItemArtwork(
            boundsSize: (artworkImage.size),
            requestHandler: () {
              artworkImage.size;
            });
        songInfo.add(MPMediaItemProperty.Artwork = albumArt as String);
      }
    } else {
      var artworkImage = UIImage.imageNamed("AppIcon");
      if (artworkImage != null) {
        var albumArt = MPMediaItemArtwork(
            boundsSize: (artworkImage.size),
            requestHandler: () {
              artworkImage.size;
            });
        songInfo.add(MPMediaItemProperty.Artwork = albumArt as String);
      }
    }

    var progress = NSNumber(audioPlayer.currentTime ?? 0.0);
    var duration = NSNumber(audioPlayer.duration ?? 0.0);

    //pretty certain MPMediaItem is an enum.
    songInfo.add(MPMediaItemProperty.Title = track.title);
    songInfo.add(MPMediaItemProperty.Artist = track.artist);
    songInfo.add(MPNowPlayingInfoCenter
        .MPNowPlayingInfoPropertyElapsedPlaybackTime = progress.toString());
    songInfo.add(MPMediaItemProperty.PlaybackDuration = duration.toString());
    bool b = (audioPlayer.playing ?? false);
    songInfo.add(MPNowPlayingInfoCenter.MPNowPlayingInfoPropertyPlaybackRate =
        NSNumber(b ? 1.0 : 0.0).toString());

    //TODO convert this to Map<Value, Type> manually
    playingInfoCenter.nowPlayingInfo = songInfo as Map<String, dynamic>;
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
    var commandCenter = MPRemoteCommandCenter.sharedCommandCenter();
    if (pauseTarget != null) {
      //Changed as remove target does not exist.
      //Thought this achieved the same goal
      //commandCenter.togglePlayPauseCommand.removeTarget(pauseTarget, action: null);
      commandCenter.togglePlayPauseCommand.enabled = false;
      pauseTarget = null;
    }
    if (forwardTarget != null) {
      //commandCenter.nextTrackCommand.removeTarget(forwardTarget, action: null);
      commandCenter.nextTrackCommand.enabled = false;
      forwardTarget = null;
    }

    if (backwardTarget != null) {
      //commandCenter.previousTrackCommand.removeTarget(backwardTarget, action: null)
      commandCenter.previousTrackCommand.enabled = false;
      backwardTarget = null;
    }

    commandCenter.togglePlayPauseCommand.enabled =
        true; // If the caller does not want to control pause button, we will use our default action
    commandCenter.nextTrackCommand.enabled = canSkipForward;
    commandCenter.previousTrackCommand.enabled = canSkipBackward;

    void pauseCommand() {
      var b = audioPlayer.playing ?? false;
      // If the caller wants to control the pause button, just call him
      if (b) {
        if (canPause) {
          //invokeCallback("pause", boolArg: true);
        } else {
          audioPlayer.pause();
        }
      } else {
        if (canPause) {
          //invokeCallback("resume", boolArg: true);
        } else {
          audioPlayer.resume();
        }
      }
    }

    ;

    try {
      //dont think these casts are valid but its a hack for now
      commandCenter.pauseCommand = pauseCommand as MPRemoteCommand;
      pauseTarget = commandCenter.pauseCommand as Function;
    } on Exception catch (e) {
      Log.d(e.toString());
    }

    if (canSkipForward) {
      commandCenter.nextTrackCommand =
          audioPlayer.skipBackward as MPRemoteCommand;
      forwardTarget = commandCenter.nextTrackCommand as Function;
      //(handler: { event in
      //  invokeCallback("skipForward", stringArg: "")
      // [[MediaController sharedInstance] fastForward];    // forward to next track.
      //});
    }

    if (canSkipBackward) {
      commandCenter.nextTrackCommand =
          audioPlayer.skipBackward as MPRemoteCommand;
      backwardTarget = commandCenter.nextTrackCommand as Function;
      //backwardTarget = commandCenter.previousTrackCommand.addTarget(handler: { event in
      //  invokeCallback("skipBackward", stringArg: "")
      // [[MediaController sharedInstance] rewind];    // back to previous track.
      // });
    }
  }

  void stop() {
    stopProgressTimer();
    isPaused = false;
    if (audioPlayer != null) {
      audioPlayer?.stop();
      //audioPlayer = null;
    }
    // ????  [self cleanTarget:false canSkipForward:false canSkipBackward:false];
    /* The caller did it himself : Sounds must not change that) */
    if ((_setActiveDone != t_SET_CATEGORY_DONE.by_USER) &&
        (setActiveDone != null)) {
      cleanTarget(false, canSkipForward: false, canSkipBackward: false); // ???
      try {
        AVAudioSession.sharedInstance().setActive(active: false);
      } on Exception catch (e) {
        Log.d(e.toString());
      }
      setActiveDone = null;
    }
    ;
  }

  // Give the system information about what to do when the notification
  // control buttons are pressed.
  void setupRemoteCommandCenter(bool canPause,
      {bool canSkipForward, bool canSkipBackward}) {
    cleanTarget(canPause,
        canSkipForward: canSkipForward, canSkipBackward: canSkipBackward);
  }
}

//---------------------------------------------------------------------------------------------

//---------------------------------------------------------------------------------------------
