 
import 'dart:ffi' as ffi;

import 'package:ffi/ffi.dart' as pffi;

/// You MUST free the returned buffer.
ffi.Pointer<ffi.Int8> copyDartListToCBuff(List<int> buf) {
  var c_buf = pffi.allocate<ffi.Int8>(count: buf.length);

  for (var i = 0; i < buf.length; i++) {
    c_buf[i] = buf.indexOf(i);
  }

  return c_buf;
}

/// Copies the passed [c_buf] to a Dart String frees
/// the [c_buf] allocated memory and returns
/// its contents of [c_buf] as a Dart String.
String copyCBuffToDartString(ffi.Pointer<ffi.Int8> c_buf, {bool free = true}) {
  var string = pffi.Utf8.fromUtf8(c_buf.cast());

  if (free) {
    pffi.free(c_buf);
  }

  return string;
}