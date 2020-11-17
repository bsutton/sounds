import 'dart:ffi';

import 'package:dart_native/dart_native.dart';

import 'audiobuffer.dart';

class AudioBufferList extends NSObject {
  ///TODO need to figure out how these are set.
  List<AudioBuffer> mBuffers;
  int mNumberBuffer;
  AudioBufferList([Class isa]) : super(isa ?? Class('AudioBufferList'));
  AudioBufferList.fromPointer(Pointer<Void> ptr) : super.fromPointer(ptr);
}
