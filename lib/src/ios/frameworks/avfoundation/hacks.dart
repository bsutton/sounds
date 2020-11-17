import 'dart:ffi';

import 'package:sounds/src/ios/shade_player_ios.dart';

import 'avaudiosession.dart';

///Apple has deprecated this class. They suggest "Instead you should register for notifications".
///https://developer.apple.com/documentation/avfoundation/avaudiosessiondelegate?language=objc
class AVAudioPlayerDelegate {
  AVAudioPlayerDelegate.fromPointer(Pointer<Void> result) {}
}

class NSMutableCopying {}

class AudioBufferList {
  AudioBufferList.fromPointer(Object o);
}

class UIApplication {
  static AVAudioSession sharedSession;
}

class AVSampleRateKey {}

class AVFormatIDKey {}

class AVNumberOfChannelsKey {}

class AVEncoderAudioQualityKey {}

class AVEncoderBitRateKey {}

class AVAudioFramePosition {
  AVAudioFramePosition.fromPointer(Pointer<Void> result) {}
}

class AVAudioCommonFormat {
  AVAudioCommonFormat.fromPointer(Pointer<Void> result) {}
}

class AudioChannelLabel {
  AudioChannelLabel.fromPointer(Pointer p);
}

class AudioTimeStamp {
  AudioTimeStamp.fromPointer(Pointer p);
}

class NSLocale {
  NSLocale.fromPointer(Pointer p);
}

class AVMediaCharacteristic {
  AVMediaCharacteristic.fromPointer(Pointer p);
}

class AVMetadataItem {
  AVMetadataItem.fromPointer(Pointer p);
}

class AVMediaType {
  AVMediaType.fromPointer(Pointer p);
}

class AudioChannelLayoutTag {
  AudioChannelLayoutTag.fromPointer(Pointer p);
}

class AudioStreamPacketDescription {
  AudioStreamPacketDescription.fromPointer(Pointer p);
}

class AVAudioMixerNode {
  AVAudioMixerNode.fromPointer(Pointer p);
}

class AudioChannelLayout {
  AudioChannelLayout.fromPointer(Pointer p);
}

class AVAudioOutputNode {
  AVAudioOutputNode.fromPointer(Pointer p);
}

class AVAudioInputNode {
  AVAudioInputNode.fromPointer(Pointer p);
}

class AVAudioConnectionPoint {
  AVAudioConnectionPoint.fromPointer(Pointer p);
}

class AUMIDIOutputEventBlock {}

class MusicSequence {
  MusicSequence.fromPointer(Pointer p);
}

class AVAudioFrameCount {
  AVAudioFrameCount.fromPointer(Pointer p);
}

class AVAudioPacketCount {
  AVAudioPacketCount.fromPointer(Pointer p);
}

class NSSecureCoding {}

class AVAudioChannelCount {
  AVAudioChannelCount.fromPointer(Pointer<Void> result) {}
}

class AudioStreamBasicDescription {
  AudioStreamBasicDescription.fromPointer(Pointer<Void> result) {}
}

class NSData {
  NSData.fromPointer(Pointer<Void> result) {}
  NSData.fromURL(URL result) {}
  void add(Object object) {}
}

class CMAudioFormatDescriptionRef {
  CMAudioFormatDescriptionRef.fromPointer(Pointer<Void> result) {}
}

class AUAudioUnit {
  AUAudioUnit.fromPointer(Pointer<Void> result) {}
}

class NSTimeInterval {
  double value;
  NSTimeInterval(this.value);
  NSTimeInterval.fromPointer(Pointer<Void> result) {}
}

class AVAudioNodeBus {}

class NSCopying {}

class NSCharacterSet {
  NSCharacterSet.fromPointer(Pointer<Void> result) {}
}

class NSCoder {}
