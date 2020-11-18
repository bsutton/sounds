import 'package:dart_native/dart_native.dart';

abstract class NSSecureCoding {
  ///Override this to return YES
  bool supportsSecureCoding;

  ///Returns an object initialized from data in a given unarchiver.
  T initWithCoder<T>();

  ///Decodes an object for the key, restricted to the specified class.
  id decodeObjectOfClass(Class aClass, NSString key);
}
