import 'dart:ffi';

import 'package:dart_native/dart_native.dart';

///Apple has deprecated this class. They suggest "Instead you should register for notifications".
///https://developer.apple.com/documentation/avfoundation/avaudiosessiondelegate?language=objc
class AVAudioPlayerDelegate {
  static AVAudioPlayerDelegate fromPointer(Pointer<Void> result) {}
}


class UIApplication {}

class AVSampleRateKey {}

class AVFormatIDKey {}

class AVNumberOfChannelsKey {}

class AVEncoderAudioQualityKey {}

class AVEncoderBitRateKey {}

class AVAudioFramePosition {
  static AVAudioFramePosition fromPointer(Pointer<Void> result) {}
}

class AVAudioCommonFormat {
  static AVAudioCommonFormat fromPointer(Pointer<Void> result) {}
}

class AVAudioFrameCount {}

class NSSecureCoding {}

class AVAudioChannelCount {
  static AVAudioChannelCount fromPointer(Pointer<Void> result) {}
}

class AudioStreamBasicDescription {
  static AudioStreamBasicDescription fromPointer(Pointer<Void> result) {}
}

class NSData {
  static NSData fromPointer(Pointer<Void> result) {}
}

class CMAudioFormatDescriptionRef {
  static CMAudioFormatDescriptionRef fromPointer(Pointer<Void> result) {}
}

class AUAudioUnit {
  static AUAudioUnit fromPointer(Pointer<Void> result) {}
}

class NSTimeInterval {
  double value;
  NSTimeInterval(this.value);
  static NSTimeInterval fromPointer(Pointer<Void> result) {}
}

class AVAudioNodeBus {}

class NSCopying {}

class NSCharacterSet {
  static NSCharacterSet fromPointer(Pointer<Void> result) {}
}

class NSCoder {}
