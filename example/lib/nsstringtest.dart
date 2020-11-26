import 'package:flutter/material.dart';
import 'package:dart_native/dart_native.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  String desc = getNSString();
  Widget build(context) =>
      Center(child: Text(desc, textDirection: TextDirection.ltr));
}

String getNSString() {
  runDartNative();
  NSString obj = new NSString('This is an NSString');
  return obj.raw;
}
