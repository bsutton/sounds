import 'dart:ffi';
import 'package:ffi/ffi.dart';
import 'package:dart_native/dart_native.dart';
// ignore_for_file: public_member_api_docs

class CFAllocatorRef extends Struct {}

class CFURLRef extends Struct {}

// ignore: avoid_classes_with_only_static_members
class CFURLPathStyle{
  @Uint32()
  final int value;
  CFURLPathStyle(this.value);
  static CFURLPathStyle cfurlposixPathStyle = CFURLPathStyle(0);
  static CFURLPathStyle cfurlWindowsPathStyle = CFURLPathStyle(2);
}

//Possbile this should be extending an NSObject
class CFURL{
  ///Path must always be to a file
  //original signiature

  static CFURL fromfromFileSystemPathString(
      String path, CFURLPathStyle pathStyle) {
    var objCString = Utf8.toUtf8(path).cast();

    var target = alloc(Class('CFURL'));
    var sel = SEL('CFURLCreateWithFileSystemPath');
    var result = msgSend(target, sel,
        args: <dynamic>[target, path, pathStyle, false],
        decodeRetVal: false) as Pointer<Void>;
    var csString = NSObject.fromPointer(result);

    free(objCString);
    return csString as CFURL;
  }
}

//extends struct so that we can get a reference with addressOf
class CFString extends NSObject {
  String value;
  CFString(this.value);
  static CFString fromString(String string) {
    var objCString = Utf8.toUtf8(string).cast();

    var target = alloc(Class('CFString'));
    var sel = SEL('CFStringCreateWithCString');
    var result = msgSend(target, sel,
        args: <dynamic>[nullptr, objCString, CFStringEncoding.UTF8],
        decodeRetVal: false) as Pointer<Void>;
    var csString = NSObject.fromPointer(result);

    free(objCString);
    return csString as CFString;
  }
}

class CFStringEncoding{
  @Uint32()
  final int value;
  CFStringEncoding(this.value);
  static CFStringEncoding UTF8 = CFStringEncoding(134217984);
}
