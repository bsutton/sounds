import 'media_format.dart';
import 'media_format_not_supported_exception.dart';

/// Manages the list of supported MediaFormats.
/// This includes the list of Natively supported MediaFormats
/// as well any registered MediaFormat.
/// Native media formats are only available if the `sounds` package
/// is installed and [NativeMediaFormats.register()] has been called.
class MediaFormatManager {
  static final MediaFormatManager _self = MediaFormatManager._internal();

  // A map of codes with the MediaFormat name as the key.
  final _mediaFormats = <String, MediaFormat>{};

  factory MediaFormatManager() {
    return _self;
  }

  MediaFormatManager._internal();

  void register(MediaFormat mediaFormat) {
    _mediaFormats[mediaFormat.name] = mediaFormat;
  }

  /// Gets a [MediaFormat] using its [name].
  ///
  /// [MediaFormat] names are of the form 'container/codec' all lower case.
  ///
  /// Throws [MediaFormatException] if [name] is not a registered
  /// [MediaFormat].
  MediaFormat byName(String name) {
    var mediaFormat = _mediaFormats[name];

    if (mediaFormat == null) {
      throw MediaFormatException('MediaFormat $name is not registered.');
    }
    return mediaFormat;
  }

  /// Returns the [MediaFormat] for the given file name extension.
  /// The extension should NOT contain a leading '.'.
  ///
  /// Returns null if the extension is not supported by any
  /// registered extension.
  MediaFormat getByExtension(String extension) {
    for (var mediaFormat in _mediaFormats.values) {
      if (extension == mediaFormat.extension) {
        return mediaFormat;
      }
    }
    return null;
  }

  /// returns a list of the native encoders (recording) supported by the current platform.
  ///
  /// Native media formats are only available if the `sounds` package
  /// is installed and [NativeMediaFormats.register()] has been called.
  ///
  /// Throws [MediaFormatException] if no Native Media Formats have been registered.
  Future<List<MediaFormat>> get nativeEncoders async {
    var encoders = <MediaFormat>[];

    for (var mediaFormat in _mediaFormats.values) {
      if (await mediaFormat.isNativeEncoder) {
        encoders.add(mediaFormat);
      }
    }

    if (encoders.isEmpty) {
      throw MediaFormatException(
          'No NativeMediaFormats have been registered. Have you called NativeMediaFormat.register()?');
    }
    return encoders;
  }

  /// returns a list of the native encoders (recording) supported by the current platform.
  ///
  /// Native media formats are only available if the `sounds` package
  /// is installed and [NativeMediaFormats.register()] has been called.
  ///
  /// Throws [MediaFormatException] if no Native Media Formats have been registered.
  Future<List<MediaFormat>> get nativeDecoders async {
    var decoders = <MediaFormat>[];

    for (var decoder in _mediaFormats.values) {
      if (await decoder.isNativeDecoder) {
        decoders.add(decoder);
      }
    }

    if (decoders.isEmpty) {
      throw MediaFormatException(
          'No NativeMediaFormats have been registered. Have you called NativeMediaFormat.register()?');
    }

    return decoders;
  }
}
