import 'dart:ffi';

import 'package:dart_native/dart_native.dart';

///TODO this needs to be set up
class NSCharacterSet extends NSObject {
  NSCharacterSet.fromPointer(Pointer<Void> result) : super.fromPointer(result);
}
