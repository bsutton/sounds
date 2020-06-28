import 'dart:io';
import 'dart:typed_data';

import 'package:intl/intl.dart';
import 'package:sounds/sounds.dart';
import 'package:sounds_common/sounds_common.dart';

import 'demo_media_path.dart';

/// Describes how the media is stored.
enum MediaStorage {
  /// The media is stored in a local file
  file,

  /// The media is stored in a in memory buffer
  buffer,

  /// The media is stored in an asset.
  asset,

  /// The media is being streamed
  stream,

  /// The media is a remote sample file.
  remoteExampleFile,
}

/// get the duration for the media with the given MediaFormat.
Future<Duration> getDuration(MediaFormat mediaFormat) async {
  Future<Duration> duration;
  switch (MediaPath().media) {
    case MediaStorage.file:
    case MediaStorage.buffer:
      duration =
          mediaFormat.getDuration(MediaPath().pathForMediaFormat(mediaFormat));
      break;
    case MediaStorage.asset:
      duration = null;
      break;
    case MediaStorage.remoteExampleFile:
      duration = null;
      break;
    case MediaStorage.stream:
      duration = null;
      break;
  }
  return duration;
}

/// formats a duration for printing.
///  mm:ss
String formatDuration(Duration duration) {
  var date =
      DateTime.fromMillisecondsSinceEpoch(duration.inMilliseconds, isUtc: true);
  return DateFormat('mm:ss', 'en_GB').format(date);
}

/// the set of samples availble as assets.
var assetSample = <String, String>{
  WellKnownMediaFormats.adtsAac.name: 'assets/samples/sample.aac',
  WellKnownMediaFormats.adtsAac.name: 'assets/samples/sample.aac',
  WellKnownMediaFormats.oggOpus.name: 'assets/samples/sample.opus',
  WellKnownMediaFormats.cafOpus.name: 'assets/samples/sample.caf',
  WellKnownMediaFormats.mp3.name: 'assets/samples/sample.mp3',
  WellKnownMediaFormats.oggVorbis.name: 'assets/samples/sample.ogg',
  WellKnownMediaFormats.pcm.name: 'assets/samples/sample.wav',
};

/// Checks if the past file exists
bool fileExists(String path) {
  return File(path).existsSync();
}

/// checks if the given directory exists.
bool directoryExists(String path) {
  return Directory(path).existsSync();
}

/// In this simple example, we just load a file in memory.
/// This is stupid but just for demonstration  of startPlayerFromBuffer()
Future<Uint8List> makeBuffer(String path) async {
  try {
    if (!fileExists(path)) return null;
    var file = File(path);
    file.openRead();
    var contents = await file.readAsBytes();
    Log.d('The file is ${contents.length} bytes long.');
    return contents;
  } on Object catch (e) {
    Log.d(e.toString());
    return null;
  }
}
