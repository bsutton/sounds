import 'package:dart_native/dart_native.dart';

main() => runApp(MyApp());

class MyApp extends StatelessWidget{
  @override
  runDartNative();
  NSObject obj = new NSObject(Class('NSObject'));
  Widget build(context) => Center(
    child: Text(obj.description, textDirection: TextDirection.ltr)
  );
}