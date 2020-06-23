/// Throw if an unsupported codec is passed.
/// Different OS's support a different set of codecs.
///
class MediaFormatNotSupportedException implements Exception {
  String message;
  MediaFormatNotSupportedException(this.message);

  @override
  String toString() => message;
}
