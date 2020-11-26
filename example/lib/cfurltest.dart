import 'package:flutter/material.dart';
import 'package:dart_native/dart_native.dart';
import 'package:sounds/src/ios/frameworks/avfoundation/cfurl.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  String desc = getURL();
  Widget build(context) =>
      Center(child: Text(desc, textDirection: TextDirection.ltr));
}

String getURL() {
  runDartNative();
  CFURL obj = CFURL.fromfromFileSystemPathString('../assets/samples/sample.mp3', CFURLPathStyle(0));
  return obj.toString();
}
