import 'package:flutter/material.dart';

import 'package:dart_native/dart_native.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  String desc = getNSObjDescription();
  Widget build(context) =>
      Center(child: Text(desc, textDirection: TextDirection.ltr));
}

String getNSObjDescription() {
  runDartNative();
  NSObject obj = new NSObject(Class('NSObject'));
  return obj.description;
}
