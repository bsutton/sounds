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

import 'package:sounds_platform_interface/sounds_platform_interface.dart';

///
/// Determines the source that should be recorded.
/// Currently these are only supported by android.
///
/// For iOS we always record from the microphone.
class AudioSource {
  final int _source;
  const AudioSource._internal(this._source);
  String toString() => 'AudioSource.$_source';

  ///
  int get source => _source;

  /// The const defined here are intended to be platform agnostic
  /// however the exactly match the Android definitions which
  /// the android platform depends on. If you change
  /// these you MUST update the android platform code.
  static const defaultSource = AudioSource._internal(0);

  ///
  static const mic = AudioSource._internal(1);

  ///
  static const voiceUplink = AudioSource._internal(2);

  ///
  static const voiceDownlink = AudioSource._internal(3);

  ///
  static const camcorder = AudioSource._internal(4);

  ///
  static const voiceRecognition = AudioSource._internal(5);

  ///
  static const voiceCommunication = AudioSource._internal(6);

  ///
  static const remoteSubmix = AudioSource._internal(7);

  ///
  static const unprocessed = AudioSource._internal(8);

  ///
  static const radioTuner = AudioSource._internal(9);

  ///
  static const hotword = AudioSource._internal(10);
}

/// Generates an AudioSourceProxy from an audioSource so
/// we can pass it down to the host platform.
class AudioSourceHelper {
  /// Generates an AudioSourceProxy from an audioSource so
  /// we can pass it down to the host platform.
  static AudioSourceProxy generate(AudioSource audioSource) {
    var proxy = AudioSourceProxy();

    proxy.audioSource = audioSource.source;
    proxy.defaultSource = AudioSource.defaultSource.source;
    proxy.mic = AudioSource.mic.source;
    proxy.voiceUplink = AudioSource.voiceUplink.source;
    proxy.voiceDownlink = AudioSource.voiceDownlink.source;
    proxy.camcorder = AudioSource.camcorder.source;
    proxy.voiceRecognition = AudioSource.voiceRecognition.source;
    proxy.voiceCommunication = AudioSource.voiceCommunication.source;
    proxy.remoteSubmix = AudioSource.remoteSubmix.source;
    proxy.unprocessed = AudioSource.unprocessed.source;
    proxy.radioTuner = AudioSource.radioTuner.source;
    proxy.hotword = AudioSource.hotword.source;

    return proxy;
  }
}
