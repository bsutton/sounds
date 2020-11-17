import 'dart:ffi';

import 'package:dart_native/dart_native.dart';

import 'avaudioplayer.dart';

class AVAudioPlayerDelegate extends NSObject {
  AVAudioPlayerDelegate.fromPointer(Pointer<Void> pointer)
      : super.fromPointer(pointer);

  void audioPlayerDidFinishPlaying(
      AVAudioPlayer player, bool successfullyflag) {}

  void audioPlayerDecodeErrorDidOccur(AVAudioPlayer player, Error error) {}
}
