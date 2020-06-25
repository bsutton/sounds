import 'media_convertor.dart';
import 'media_format.dart';

class MediaConvertors {
  static final _self = MediaConvertors._internal();
  final _convertors = <MediaConvertor>[];

  factory MediaConvertors() {
    return _self;
  }

  MediaConvertors._internal();

  /// throws an exception if the conversion is already registered.
  static void register(MediaConvertor converter) {}

  /// Attempts to find a MediaConvertor that converts [from] to [to].
  MediaConvertor getConverter({MediaFormat from, MediaFormat to}) {
    MediaConvertor result;

    for (var convertor in _convertors) {
      if (convertor.from == from && convertor.to == to) {
        result == convertor;
        break;
      }
    }

    if (result == null) {
      throw MediaConversionNotSupportedException();
    }
    return result;
  }

  List<MediaConvertor> get converters => _convertors;
}

class MediaConversionNotSupportedException implements Exception {
  MediaConversionNotSupportedException();
}
