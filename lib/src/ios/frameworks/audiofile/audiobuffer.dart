import 'dart:ffi';

import 'package:dart_native/dart_native.dart';

class AudioBuffer extends NSObject {
  AudioBuffer([Class isa]) : super(isa ?? Class('AudioBufferList'));
  AudioBuffer.fromPointer(Pointer<Void> ptr) : super.fromPointer(ptr);
}
