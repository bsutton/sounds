import 'dart:ffi';

import 'package:dart_native/dart_native.dart';

class NSTimeInterval extends NSObject {
  double value;
  NSTimeInterval(this.value);
  NSTimeInterval.fromPointer(Pointer<Void> p) : super.fromPointer(p) {}
}