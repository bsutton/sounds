import 'codec.dart';
import 'codec_manager.dart';
import 'media_container.dart';
import 'media_format_not_supported_exception.dart';

class MediaFormat {
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

  static MediaFormat common =
      MediaFormat.detail(codec: CodecManager().byName('aac'));

  ///
  static Codec determineCodec(String uri) {
    codec = CodecHelper.determineCodec(uri);
    if (codec == null) {
      throw MediaFormatNotSupportedException(
          "The uri's extension does not match any"
          ' of the supported extensions. '
          'You must pass in a codec.');
    }
    return codec;
  }
}
