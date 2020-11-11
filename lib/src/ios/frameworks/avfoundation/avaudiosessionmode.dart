import 'dart:ffi';

import 'package:dart_native/dart_native.dart';

//ignore_for_file: public_member_api_docs
//ignore_for_file: non_constant_identifier_names
class AVAudioSessionMode extends NSString {
  AVAudioSessionMode(String value) : super(value);

  AVAudioSessionMode.fromPointer(Pointer<Void> ptr) : super.fromPointer(ptr);

  static var AVAudioSessionModeDefault =
      AVAudioSessionMode('AVAudioSessionModeDefault');
  static var AVAudioSessionModeMoviePlayback =
      AVAudioSessionMode('AVAudioSessionModeMoviePlayback');
  static var AVAudioSessionModeVideoRecording =
      AVAudioSessionMode('AVAudioSessionModeVideoRecording');
  static var AVAudioSessionModeVoiceChat =
      AVAudioSessionMode('AVAudioSessionModeVoiceChat');
  static var AVAudioSessionModeGameChat =
      AVAudioSessionMode('AVAudioSessionModeGameChat');
  static var AVAudioSessionModeVideoChat =
      AVAudioSessionMode('AVAudioSessionModeVideoChat');
  static var AVAudioSessionModeSpokenAudio =
      AVAudioSessionMode('AVAudioSessionModeSpokenAudio');
  static var AVAudioSessionModeMeasurement =
      AVAudioSessionMode('AVAudioSessionModeMeasurement');
}
