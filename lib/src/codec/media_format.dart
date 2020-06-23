import 'codec.dart';
import 'media_format_manager.dart';
import 'media_container.dart';
import 'media_format_not_supported_exception.dart';

abstract class MediaFormat {
  Codec codec;
  MediaContainer container;
  int sampleRate;
  int numChannels;
  int bitRate;

  MediaFormat.detail({
    this.codec,
    this.sampleRate = 16000,
    this.numChannels = 1,
    this.bitRate = 16000,
  });

  /// Returns the duration of the audio file at the given [path].
  /// The audio file at the given path MUST be the of the same
  /// [MediaFormat] otherwise the result is undefined.
  Future<Duration> getDuration(String path);

  /// Only codecs natively supported by the current platform should return
  /// true.
  bool get isNative;
}
