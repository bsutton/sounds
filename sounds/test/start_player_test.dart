// import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:sounds/sounds.dart';
// import 'package:flutter_test/flutter_test.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // final log = <MethodCall>[];

  QuickPlay.fromFile('example/asset/samples/sample.acc');
}
