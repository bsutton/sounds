import '../track.dart';
import 'media_format.dart';

abstract class MediaConvertor {
  /// The MediaFormat that this convertor converts from.
  MediaFormat get from;

  /// The MediaFormat that this convertor converts to.
  MediaFormat get to;

  Track convertTrack(Track from);
}
