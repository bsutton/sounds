import 'media_format.dart';

abstract class MediaProvider {
  /// Returns the list of supported decoders (i.e. we can play the audio)
  /// for the current OS/SDK version
  Future<List<MediaFormat>> get decoders;

  /// Returns the list of supported decoders (i.e. we can record audio in this format)
  /// for the current OS/SDK version
  Future<List<MediaFormat>> get encoders;
}
