import 'package:path/path.dart';

import 'codec.dart';

/// Helper functions for the Codec enum becuase
/// dart's enums are crap.
class CodecHelper {
  /// Provides mappings from common file extensions to
  /// the codec those files use.
  static const extensionToCodecMap = <String, Codec>{
    '.aac': Codec.aacADTS,
    '.opus': Codec.opusOGG,
    '.caf': Codec.cafOpus,
    '.mp3': Codec.mp3,
    '.ogg': Codec.vorbisOGG,
    '.wav': Codec.pcm,
    '.flac': Codec.flac,
  };

  /// Maps codecs to common file extensions.
  static const codecToExtensionMap = <Codec, String>{
    Codec.aacADTS: '.aac',
    Codec.opusOGG: '.opus',
    Codec.cafOpus: '.caf',
    Codec.mp3: '.mp3',
    Codec.vorbisOGG: '.ogg',
    Codec.pcm: '.wav',
    Codec.aacLC: '.aac',
    Codec.aac3GP: '.aac',
    Codec.aacMP4: '.aac',
    Codec.wav: '.wav',
    Codec.flac: '.flac',
  };

  /// Returns the codec for the given [path]
  /// by using the filename's extension.
  /// If the filename's extension doesn't match one of the supported
  /// file extensions listed in [extensionToCodecMap] then
  /// null is returned.
  static Codec determineCodec(String path) {
    var ext = extension(path);

    var codec = extensionToCodecMap[ext];

    return codec;
  }
}
