/// Throw if an unsupported MediaFormat is passed.
/// Different OS's support a different set of codecs.
///
class MediaFormatException implements Exception {
  String message;
  MediaFormatException(this.message);

  @override
  String toString() => message;
}
