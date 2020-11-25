import 'dart:ffi';

import 'package:dart_native/dart_native.dart';

///TODO not sure if this works the way i'm expecting
class AVAudioFramePosition extends int64_t {
  AVAudioFramePosition(num raw) : super(raw);

  AVAudioFramePosition.fromPointer(Pointer<Void> p)
      : super(convertFromPointer('int64_t', p) as num) {}
}