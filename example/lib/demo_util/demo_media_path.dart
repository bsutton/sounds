import 'package:sounds/sounds.dart';
import 'package:sounds_common/sounds_common.dart';

import 'demo_common.dart';

/// Paths for example media files.
class MediaPath {
  static final MediaPath _self = MediaPath._internal();

  final _path = <MediaFormat, String>{};

  /// The media we are storing
  MediaStorage media = MediaStorage.file;

  /// ctor
  factory MediaPath() {
    return _self;
  }
  MediaPath._internal();

  /// true if the media is an asset
  bool get isAsset => media == MediaStorage.asset;

  /// true if the media is an file
  bool get isFile => media == MediaStorage.file;

  /// true if the media is an buffer
  bool get isBuffer => media == MediaStorage.buffer;

  /// true if the media is the example file.
  bool get isExampleFile => media == MediaStorage.remoteExampleFile;

  /// Sets the location of the file for the given MediaFormat.
  void setMediaFormatPath(MediaFormat mediaFormat, String path) {
    _path[mediaFormat] = path;
  }

  /// returns the path to the file for the given MediaFormat.
  String pathForMediaFormat(MediaFormat mediaFormat) {
    return _path[mediaFormat];
  }

  /// [true] if a path for the give MediaFormat exists.
  bool exists(MediaFormat mediaFormat) {
    return _path[mediaFormat] != null;
  }
}
