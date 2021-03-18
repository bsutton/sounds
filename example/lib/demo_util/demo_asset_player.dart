import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:sounds/sounds.dart';
import 'package:sounds_example/demo_util/demo_media_path.dart';

import 'demo_active_codec.dart';
import 'demo_common.dart';

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

    if (!assetSample.containsKey(ActiveMediaFormat().mediaFormat.name)) {
      throw UnknownMediaFormat(ActiveMediaFormat().mediaFormat);
    }
    track = Track.fromAsset(
      assetSample[ActiveMediaFormat().mediaFormat.name]!,
      mediaFormat: ActiveMediaFormat().mediaFormat,
    );

    track.title = 'Asset playback.';
    track.artist = 'By sounds';

    if (Platform.isIOS) {
      track.albumArtAsset = 'AppIcon';
    } else if (Platform.isAndroid) {
      track.albumArtAsset = 'AppIcon.png';
    }
    return track;
  }
}
