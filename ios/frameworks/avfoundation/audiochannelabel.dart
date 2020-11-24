import 'dart:ffi';

import 'package:dart_native/dart_native.dart';

class AudioChannelLabel extends NSInteger {
  AudioChannelLabel(num raw) : super(raw);
  AudioChannelLabel.fromPointer(Pointer<Void> p) : super(convertFromPointer('UInt32',p) as num) {}
}
