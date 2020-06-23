import 'codec.dart';
import 'media_format_not_supported_exception.dart';

class MediaFormatManager {

  static final MediaFormatManager _self= MediaFormatManager._internal();
  factory MediaFormatManager()
  {
    return _self;
  }

  MediaFormatManager._internal();

  // A map of codes with the codec name as the key.
  final _codecs = <String, Codec>{};

/// method to use a codec
  Codec byName(String name)
  {
    var codec = _codecs[name];

    if (codec == null)
    {
      throw  MediaFormatNotSupportedException('Codec not supported.');
    }
    return codec;
  }
 static Codec getByExtension(String extension){
   
 }

 /// returns a list of the native codecs supported by the current platform.
  static List<Codec> get nativeCodecs;

}
