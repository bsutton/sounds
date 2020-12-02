import '../track.dart';
import 'media_format.dart';
import 'media_provider.dart';

abstract class MediaConvertor implements MediaProvider {
  /// The MediaFormat that this convertor converts from.
  MediaFormat get from;

  /// The MediaFormat that this convertor converts to.
  MediaFormat get to;

  Track convertTrack(Track from);
}
