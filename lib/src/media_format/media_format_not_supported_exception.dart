/// Throw if an unsupported MediaFormat is passed.
/// Different OS's support a different set of codecs.
///
class MediaFormatNotSupportedException implements Exception {
  String message;
  MediaFormatNotSupportedException(this.message);

  @override
  String toString() => message;
}
