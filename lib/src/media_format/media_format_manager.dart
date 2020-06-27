import 'package:sounds_common/src/media_format/native_media_formats.dart';

import 'media_format.dart';
import 'media_format_not_supported_exception.dart';

/// Manages the list of supported MediaFormats.
/// This includes the list of Natively supported MediaFormats
/// as well any registered MediaFormat.
class MediaFormatManager {
  static final MediaFormatManager _self = MediaFormatManager._internal();

  // A map of codes with the MediaFormat name as the key.
  final _mediaFormats = <String, MediaFormat>{};

  factory MediaFormatManager() {
    return _self;
  }

  MediaFormatManager._internal() {
    /// add the set of native codecs.
    for (var mediaFormat in NativeMediaFormats().mediaFormats) {
      _mediaFormats[mediaFormat.name] = mediaFormat;
    }
  }

  /// Gets a [MediaFormat] using its [name].
  MediaFormat byName(String name) {
    var mediaFormat = _mediaFormats[name];

    if (mediaFormat == null) {
      throw MediaFormatNotSupportedException(
          'MediaFormat $name not supported.');
    }
    return mediaFormat;
  }

  MediaFormat getByExtension(String extension) {
    for (var mediaFormat in _mediaFormats.values) {
      if (extension == mediaFormat.extension) {
        return mediaFormat;
      }
    }
    return null;
  }

  /// returns a list of the native encoders (recording) supported by the current platform.
  Future<List<MediaFormat>> get nativeEncoders async {
    var encoders = <MediaFormat>[];

    for (var mediaFormat in _mediaFormats.values) {
      if (await mediaFormat.isNativeEncoder) {
        encoders.add(mediaFormat);
      }
    }
    return encoders;
  }

  /// returns a list of the native encoders (recording) supported by the current platform.
  Future<List<MediaFormat>> get nativeDecoders async {
    var encoders = <MediaFormat>[];

    for (var encoder in _mediaFormats.values) {
      if (await encoder.isNativeDecoder) {
        encoders.add(encoder);
      }
    }
    return encoders;
  }

  var nativeMediaFormats = <MediaFormat>[];
}
