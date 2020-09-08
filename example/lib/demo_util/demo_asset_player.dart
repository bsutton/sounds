import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:sounds/sounds.dart';

import 'demo_active_codec.dart';
import 'demo_common.dart';
import 'demo_player_state.dart';

///
class AssetPlayer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SoundPlayerUI.fromLoader(
      (_) => createAssetTrack(),
      showTitle: true,
    );
  }

  ///
  Future<Track> createAssetTrack() async {
    Track track;
    track = Track.fromAsset(
      assetSample[ActiveMediaFormat().mediaFormat.name],
      mediaFormat: ActiveMediaFormat().mediaFormat,
    );

    track.title = "Asset playback.";
    track.artist = "By sounds";

    if (Platform.isIOS) {
      track.albumArtAsset = 'AppIcon';
    } else if (Platform.isAndroid) {
      track.albumArtAsset = 'AppIcon.png';
    }
    return track;
  }
}
