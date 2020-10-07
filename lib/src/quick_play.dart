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
import 'dart:typed_data' show Uint8List;

import 'package:flutter/foundation.dart';
import 'package:sounds_common/sounds_common.dart';

import 'audio_focus.dart';
import 'sound_player.dart';

/// Provides the ability to playback a single
/// audio file from a variety of sources.
///  - Track
///  - File
///  - Buffer
///  - Assets
///  - URL.
///
/// The audio file plays to completion and then
/// resources are automatically cleanedup.
/// You have no control over the audio once it starts playing.
///
/// This is intended for playing short audio files.
///
/// ```dart
/// QuickPlay.fromFile('path to file);
///
/// QuickPlay.fromTrack(track, volume: 1.0, withShadeUI: true);

class QuickPlay {
  SoundPlayer _player;
  Track _track;
  PlayerEvent _onStopped;

  /// Creates a QuickPlay from a Track and immediately plays it.
  /// By default no UI is displayed.
  /// If you pass [withShadeUI]=true then the OSs' media player is displayed
  /// but all of the UI controls are disabled.
  /// You can control the playback [volume]. The valid range is 0.0 to 1.0
  /// and the default is 0.5.
  ///
  /// Pass a callback to [onStopped] if you want to be notified
  /// that audio has stopped playing.
  QuickPlay.fromTrack(this._track, {int volume, bool withShadeUI = false, PlayerEvent onStopped})
      : _onStopped = onStopped {
    QuickPlay._internal(volume, withShadeUI);
  }

  QuickPlay._internal(int volume, bool withShadeUI) {
    if (withShadeUI) {
      _player = SoundPlayer.withShadeUI(canPause: false, canSkipBackward: false, canSkipForward: false);
    } else {
      _player = SoundPlayer.noUI();
    }

    volume ??= 50;

    _play(volume);
  }

  /// Plays audio from a local file path such as an asset.
  ///
  /// The [path] of the file to play.
  ///
  /// An [TrackFileMustExistException] exception will be thrown
  /// if the file doesn't exist.
  ///
  /// If the file contains a unknown MediaFormat then
  /// [QuickPlay] will throw an [MediaFormatException].
  ///
  /// By default no UI is displayed.
  ///
  /// If you pass [withShadeUI]=true then the OSs' media player is displayed
  /// but all of the UI controls are disabled.
  ///
  /// The [volume] must be in the range 0 to 100. Defaults to 50
  ///
  /// Pass a callback to [onStopped] if you want to be notified
  /// that audio has stopped playing.
  QuickPlay.fromFile(String path, {int volume, bool withShadeUI = false, PlayerEvent onStopped})
      : _onStopped = onStopped {
    _track = Track.fromFile(path);
    QuickPlay._internal(volume, withShadeUI);
  }

  /// Allows you to play an audio file stored at a givenURL.
  ///  Both HTTP and HTTPS are supported.
  /// The [url] of the file to download and playback
  ///
  /// [QuickPlay] will throw an [MediaFormatException] if the
  /// passed files MediaFormat is not supported.
  ///
  /// By default no UI is displayed.
  ///
  /// If you pass [withShadeUI]=true then the OSs' media player is displayed
  /// but all of the UI controls are disabled.
  ///
  /// The [volume] must be in the range 0 to 100 Defaults to 50
  ///
  /// Pass a callback to [onStopped] if you want to be notified
  /// that audio has stopped playing.
  QuickPlay.fromURL(String url, {int volume, bool withShadeUI = false, PlayerEvent onStopped})
      : _onStopped = onStopped {
    _track = Track.fromURL(url);
    QuickPlay._internal(volume, withShadeUI);
  }

  /// Create a audio play from an in memory buffer.
  /// The [dataBuffer] contains the media to be played.
  ///
  /// [QuickPlay] will throw an [MediaFormatException] if the
  /// passed audio's MediaFormat is not supported.
  ///
  /// By default no UI is displayed.
  /// If you pass [withShadeUI]=true then the OSs' media player is displayed
  /// but all of the UI controls are disabled.
  /// The [volume] must be in the range 1 to 100. Defaults to 50
  ///
  /// Pass a callback to [onStopped] if you want to be notified
  /// that audio has stopped playing.
  QuickPlay.fromBuffer(Uint8List dataBuffer,
      {int volume, @required MediaFormat mediaFormat, bool withShadeUI = false, PlayerEvent onStopped})
      : _onStopped = onStopped {
    _track = Track.fromBuffer(dataBuffer, mediaFormat: mediaFormat);
    QuickPlay._internal(volume, withShadeUI);
  }

  /// Starts playback.

  Future<void> _play(int volume) async {
    await _player.setVolume(volume);
    await _player.requestAudioFocus(AudioFocus.hushOthersWithResume);
    _player.onStopped = ({wasUser}) {
      _player.release();
      if (_onStopped != null) _onStopped();
    };
    return _player.play(_track);
  }
}
