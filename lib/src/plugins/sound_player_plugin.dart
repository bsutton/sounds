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

import 'package:sounds_common/sounds_common.dart';

import '../sound_player.dart' as player;

import 'player_base_plugin.dart';

///
// ignore: prefer_mixin
class SoundPlayerPlugin extends PlayerBasePlugin {
  /// Factory
  factory SoundPlayerPlugin() => _self;

  SoundPlayerPlugin._internal() : super('com.bsutton.sounds.sound_player');

  static late final SoundPlayerPlugin _self = SoundPlayerPlugin._internal();

  @override
  Future<void> play(player.SoundPlayer player, Track track) async {
    final args = <String, dynamic>{};
    args['path'] = trackStoragePath(track);
    _setArg(args, 'artist', track.artist);
    _setArg(args, 'title', track.title);
    _setArg(args, 'albumArtUrl', track.albumArtUrl);
    _setArg(args, 'albumArtAsset', track.albumArtAsset);
    _setArg(args, 'albumArtFile', track.albumArtFile);

    Log.d('calling invoke startPlayer');
    return invokeMethod(player, 'startPlayer', args);
  }

  void _setArg(Map<String, dynamic> args, String key, String value) {
    if (value.isNotEmpty) {
      args[key] = value;
    }
  }
}
