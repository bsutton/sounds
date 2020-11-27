import 'dart:ffi';
import 'package:sounds/src/ios/frameworks/avfoundation/cfurl.dart';

/// C function `CFURLCreateWithFileSystemPath`.
Pointer CFURLCreateWithFileSystemPath(
  Pointer<CFAllocatorRef> arg0,
  Pointer<Void> arg1,
  CFURLPathStyle arg2,
  int arg3,
) {
  return _CFURLCreateWithFileSystemPath(arg0, arg1, arg2.value, arg3);
}
//This throws an error because CFURLRef cannot be instantiated
final _CFURLCreateWithFileSystemPath_Dart _CFURLCreateWithFileSystemPath =
    DynamicLibrary.open('dart_native/dart_native.dart').lookupFunction<_CFURLCreateWithFileSystemPath_C,
        _CFURLCreateWithFileSystemPath_Dart>(
  'CFURLCreateWithFileSystemPath'
);
typedef _CFURLCreateWithFileSystemPath_C = 
//Pointer<CFURLRef> 

Pointer Function(
//  Pointer<CFAllocatorRef> arg0,
 // Pointer<CFStringRef> arg1,
  //CFURLPathStyle arg2,
  //Int8 arg3,
  Pointer arg0,
  Pointer arg1,
  Int8 arg2,
  Int8 arg3,

);
typedef _CFURLCreateWithFileSystemPath_Dart = 

//Pointer<CFURLRef> 
Pointer

Function(
  //Pointer<CFAllocatorRef> arg0,
  //Pointer<CFStringRef> arg1,
  //CFURLPathStyle arg2,
  //int arg3,
  Pointer arg0,
  Pointer arg1,
  int arg2,
  int arg3,
);
