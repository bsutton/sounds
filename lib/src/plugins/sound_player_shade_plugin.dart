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

import 'package:flutter/services.dart';
import 'package:sounds_common/sounds_common.dart';

import '../sound_player.dart';
import 'player_base_plugin.dart';

///
class SoundPlayerShadePlugin extends PlayerBasePlugin {
  static late final SoundPlayerShadePlugin _self =
      SoundPlayerShadePlugin._internal();

  /// Factory
  factory SoundPlayerShadePlugin() {
    return _self;
  }
  SoundPlayerShadePlugin._internal()
      : super('com.bsutton.sounds.sounds_shade_player');

  /// Plays the given [track]. [canSkipForward] and [canSkipBackward] must be
  /// passed to provide information on whether the user can skip to the next
  /// or to the previous song in the lock screen controls.
  ///
  /// This method should only be used if the player has been initialize
  /// with the audio player specific features.
  Future<void> play(SoundPlayer player, Track track) async {
    final trackMap = <String, dynamic>{
      "title": track.title,
      "artist": track.artist,
      "albumArtUrl": track.albumArtUrl,
      "albumArtAsset": track.albumArtAsset,
    };

    /// buffer is only supported on iOS.
    if (track.isBuffer) {
      trackMap["dataBuffer"] = trackBuffer(track);
    } else {
      trackMap["path"] = trackStoragePath(track);
    }

    await invokeMethod(player, 'startShadePlayer', <String, dynamic>{
      'track': trackMap,
      'canPause': player.canPause,
      'canSkipForward': player.canSkipForward,
      'canSkipBackward': player.canSkipBackward,
    });
  }

  ///
  Future<dynamic> onMethodCallback(
      covariant SoundPlayer player, MethodCall call) {
    switch (call.method) {
      case 'pause':
        var b = call.arguments['arg'] as bool;
        if (b) {
          onSystemPaused(player);
        } else {
          onSystemResumed(player);
        }
        //}
        break;

      /// track specific methods
      case 'skipForward':
        onSystemSkipForward(player);
        break;

      case 'skipBackward':
        onSystemSkipBackward(player);
        break;

      /// notifications from the os when the OS Media Player
      /// changes state.
      case 'updatePlaybackState':
        var stateNo = call.arguments['arg'] as int;

        var playbackState = SystemPlaybackState.values[stateNo];

        onSystemUpdatePlaybackState(player, playbackState);
        break;
    }

    return super.onMethodCallback(player, call);
  }
}

/// This enum reflects an enum of the same name
/// in BackgroundAudioServices.java
/// and the two enums MUST be kept in sync.
///
/// The order of these enums is CRITICAL!
enum SystemPlaybackState {
  /// The OS Media Player has started playing
  playing,

  /// The OS Media Player has been paused
  paused,

  /// The OS Media Player has been stopped
  stopped
}
