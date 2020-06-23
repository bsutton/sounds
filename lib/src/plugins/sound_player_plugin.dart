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
  static SoundPlayerPlugin _self;

  /// Factory
  factory SoundPlayerPlugin() {
    _self ??= SoundPlayerPlugin._internal();
    return _self;
  }
  SoundPlayerPlugin._internal() : super('com.bsutton.sounds.sounds_player');

  Future<void> play(player.SoundPlayer player, Track track) async {
    var args = <String, dynamic>{};
    args['path'] = trackStoragePath(track);
    // Flutter cannot transfer an enum to a native plugin.
    // We use an integer instead
    args['codec'] = track.codec.name;
    Log.d('calling invoke startPlayer');
    return invokeMethod(player, 'startPlayer', args);
  }
}
