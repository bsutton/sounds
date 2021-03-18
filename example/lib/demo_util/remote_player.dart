import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:sounds/sounds.dart';
import 'package:sounds_common/sounds_common.dart';

import 'demo_active_codec.dart';
import 'demo_player_state.dart';

/// path to remote auido file.
const String exampleAudioFilePath =
    "https://file-examples.com/wp-content/uploads/2017/11/file_example_MP3_700KB.mp3";

/// path to remote auido file artwork.
final String albumArtPath =
    "https://file-examples.com/wp-content/uploads/2017/10/file_example_PNG_500kB.png";

///
class RemotePlayer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var track = _createRemoteTrack(context);

    if (track != null) {
      return SoundPlayerUI.fromTrack(track,
          showTitle: true, autoFocus: PlayerState().hushOthers);
    } else
      return Text('No valid track selected');
  }

  Track? _createRemoteTrack(BuildContext context) {
    Track? track;
    // validate MediaFormat for example file
    if (ActiveMediaFormat().mediaFormat != WellKnownMediaFormats.mp3) {
      var error = SnackBar(
          backgroundColor: Colors.red,
          content: Text('You must set the MediaFormat to MP3 to '
              'play the "Remote Example File"'));
      Future.delayed(Duration.zero,
          () => ScaffoldMessenger.of(context).showSnackBar(error));
    } else {
      // We have to play an example audio file loaded via a URL
      track = Track.fromURL(exampleAudioFilePath,
          mediaFormat: ActiveMediaFormat().mediaFormat);

      track.title = "Remote mpeg playback.";
      track.artist = "By sounds";
      track.albumArtUrl = albumArtPath;

      if (Platform.isIOS) {
        track.albumArtAsset = 'AppIcon';
      } else if (Platform.isAndroid) {
        track.albumArtAsset = 'AppIcon.png';
      }
    }

    return track;
  }
}
