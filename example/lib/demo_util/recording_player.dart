import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:sounds/sounds.dart';
import 'package:sounds_common/sounds_common.dart';

import 'demo_active_codec.dart';
import 'demo_common.dart';
import 'demo_media_path.dart';

///
class RecordingPlayer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SoundPlayerUI.fromLoader(
      createTrack,
      showTitle: true,
    );
  }

  ///
  Future<Track> createTrack(BuildContext context) async {
    Track track;

    String title;
    try {
      if (_recordingExist(context)) {
        /// build player from file
        if (MediaPath().isFile) {
          // Do we want to play from buffer or from file ?
          track = await _createPathTrack();
          title = 'Recording from file playback';
        }

        /// build player from buffer.
        else if (MediaPath().isBuffer) {
          // Do we want to play from buffer or from file ?
          track = await _createBufferTrack();
          title = 'Recording from buffer playback';
        }

        if (track != null) {
          track.title = title;
          track.artist = "By sounds";

          if (Platform.isIOS) {
            track.albumArtAsset = 'AppIcon';
          } else if (Platform.isAndroid) {
            track.albumArtAsset = 'AppIcon.png';
          }
        }
      } else {
        var error = SnackBar(
            backgroundColor: Colors.red,
            content: Text('You must make a recording first with the '
                'selected MediaFormat first.'));
        Scaffold.of(context).showSnackBar(error);
      }
    } on Object catch (err) {
      Log.d('error: $err');
      rethrow;
    }

    return track;
  }

  Future<Track> _createBufferTrack() async {
    Track track;
    // Do we want to play from buffer or from file ?
    if (fileExists(
        MediaPath().pathForMediaFormat(ActiveMediaFormat().mediaFormat))) {
      var dataBuffer = await makeBuffer(
          MediaPath().pathForMediaFormat(ActiveMediaFormat().mediaFormat));
      if (dataBuffer == null) {
        throw Exception('Unable to create the buffer');
      }
      track = Track.fromBuffer(dataBuffer,
          mediaFormat: ActiveMediaFormat().mediaFormat);
    }
    return track;
  }

  Future<Track> _createPathTrack() async {
    Track track;
    var audioFilePath =
        MediaPath().pathForMediaFormat(ActiveMediaFormat().mediaFormat);
    track = Track.fromFile(audioFilePath,
        mediaFormat: ActiveMediaFormat().mediaFormat);
    return track;
  }

  bool _recordingExist(BuildContext context) {
    // Do we want to play from buffer or from file ?
    var path = MediaPath().pathForMediaFormat(ActiveMediaFormat().mediaFormat);
    return (path != null && fileExists(path));
  }
}
