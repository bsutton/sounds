import 'dart:ffi';

import 'package:dart_native/dart_native.dart';

class AVAudioCommonFormat extends NSObject {
  int value;
  AVAudioCommonFormat.fromPointer(Pointer<Void> ptr) : super.fromPointer(ptr);
  AVAudioCommonFormat(this.value);
  static AVAudioCommonFormat AVAudioOtherFormat = AVAudioCommonFormat(0);
  AVAudioCommonFormat AVAudioPCMFormatFloat32 = AVAudioCommonFormat(1);
  AVAudioCommonFormat AVAudioPCMFormatFloat64 = AVAudioCommonFormat(2);
  AVAudioCommonFormat AVAudioPCMFormatInt16 = AVAudioCommonFormat(3);
  AVAudioCommonFormat AVAudioPCMFormatInt32 = AVAudioCommonFormat(4);
}
