import 'dart:ffi';

import 'package:dart_native/dart_native.dart';
import 'package:sounds/src/ios/shade_player_ios.dart';

class NSData extends NSObject {
  NSData(Class isa) : super(isa);
  NSData.fromPointer(Pointer<Void> result) : super.fromPointer(result);
  String datapath;
  NSData.fromURL(URL result) {
    datapath = result.fileURLWithPath;
  }
  void add(Object object) {}
}