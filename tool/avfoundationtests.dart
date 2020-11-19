import 'package:dart_native/dart_native.dart';

void main() {
  NSObject obj = new NSObject(Class('NSObject'));
  print(obj.description);
}
