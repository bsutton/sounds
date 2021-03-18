import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:sounds/sounds.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:sounds_common/sounds_common.dart';

import 'demo_active_codec.dart';
import 'demo_asset_player.dart';
import 'demo_drop_downs.dart';
import 'demo_player_state.dart';
import 'recorder_state.dart';
import 'remote_player.dart';

///
class MainBody extends StatefulWidget {
  ///
  const MainBody({
    Key? key,
  }) : super(key: key);

  @override
  _MainBodyState createState() => _MainBodyState();
}

class _MainBodyState extends State<MainBody> {
  bool initialized = false;

  late final String recordingFile;
  late Track track;

  @override
  void initState() {
    super.initState();
    recordingFile = Track.tempFile(WellKnownMediaFormats.adtsAac);

    track = Track.fromFile(recordingFile,
        mediaFormat: WellKnownMediaFormats.adtsAac);
    track.artist = 'Brett';
  }

  Future<bool> init() async {
    if (!initialized) {
      await initializeDateFormatting();
      RecorderState().init();
      ActiveMediaFormat().recorderModule = RecorderState().recorderModule;
      await ActiveMediaFormat()
          .setMediaFormat(mediaFormat: WellKnownMediaFormats.adtsAac);

      initialized = true;
    }
    return initialized;
  }

  void dispose() {
    File(recordingFile).delete();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        initialData: false,
        future: init(),
        builder: (context, snapshot) {
          if (snapshot.data == false) {
            return Container(
              width: 0,
              height: 0,
              color: Colors.white,
            );
          } else {
            final dropdowns =
                Dropdowns(onMediaFormatChanged: (mediaFormat) async {
              await ActiveMediaFormat()
                  .setMediaFormat(mediaFormat: mediaFormat);

              /// If we have changed MediaFormat the recording is no longer valid.
              FileUtil().truncate(recordingFile);
              track = Track.fromFile(recordingFile, mediaFormat: mediaFormat);

              /// we need the SoundRecorderUI to rebuild so it gets
              /// the track with the changed MediaFormat.
              setState(() {});
            });

            return ListView(
              children: <Widget>[
                _buildRecorder(track),
                dropdowns,
                buildPlayBars(),
                buildHushOthers(),
              ],
            );
          }
        });
  }

  Widget buildPlayBars() {
    return Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Left("Asset Playback"),
            AssetPlayer(),
            Left("Remote Track Playback"),
            RemotePlayer(),
            Left("Shade Playback"),
            buildShadePlayer(),
            Left("Test Playback"),
            buildRemoteShadeButton(context),
          ],
        ));
  }

  Widget _buildRecorder(Track track) {
    return Padding(
        padding: const EdgeInsets.all(8.0),
        child: RecorderPlaybackController(
            child: Column(
          children: [
            SoundRecorderUI(
              track,
              requestPermissions: requestPermissions,
            ),
            Left("Recording Playback"),
            SoundPlayerUI.fromTrack(track,
                showTitle: true, autoFocus: PlayerState().hushOthers),
          ],
        )));
  }

  Widget buildHushOthers() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.only(right: 4.0),
            child: Text('Hush Others:'),
          ),
          Switch(
            value: PlayerState().hushOthers,
            onChanged: (hushOthers) =>
                hushOthersSwitchChanged(hushOthers: hushOthers),
          ),
        ],
      ),
    );
  }

  void hushOthersSwitchChanged({required bool hushOthers}) {
    setState(() {
      PlayerState().setHush(hushOthers: hushOthers);
    });
  }

  /// Callback for when the recorder needs permissions to record
  /// to the [track].
  Future<bool> requestPermissions(BuildContext context, Track track) async {
    var granted = false;

    /// change this to true if the track uses
    /// external storage on android.
    var usingExternalStorage = false;

    // Request Microphone permission if needed
    print('storage: ${await Permission.microphone.status}');
    var microphoneRequired = !await Permission.microphone.isGranted;

    var storageRequired = false;

    if (usingExternalStorage) {
      /// only required if track is on external storage
      if (Permission.storage.status == PermissionStatus.denied) {
        print('You are probably missing the storage permission '
            'in your manifest.');
      }

      storageRequired =
          usingExternalStorage && !await Permission.storage.isGranted;
    }

    /// build the 'reason' why and what we are asking permissions for.
    if (microphoneRequired || storageRequired) {
      var both = false;

      if (microphoneRequired && storageRequired) {
        both = true;
      }

      var reason = "To record a message we need permission ";

      if (microphoneRequired) {
        reason += "to access your microphone";
      }

      if (both) {
        reason += " and ";
      }

      if (storageRequired) {
        reason += "to store a file on your phone";
      }

      reason += ".";

      if (both) {
        reason += " \n\nWhen prompted click the 'Allow' button on "
            "each of the following prompts.";
      } else {
        reason += " \n\nWhen prompted click the 'Allow' button.";
      }

      /// tell the user we are about to ask for permissions.
      if (await showAlertDialog(context, reason)) {
        var permissions = <Permission>[];
        if (microphoneRequired) permissions.add(Permission.microphone);
        if (storageRequired) permissions.add(Permission.storage);

        /// ask for the permissions.
        await permissions.request();

        /// check the user gave us the permissions.
        granted = await Permission.microphone.isGranted &&
            await Permission.storage.isGranted;
        if (!granted) grantFailed(context);
      } else {
        granted = false;
        grantFailed(context);
      }
    } else {
      granted = true;
    }

    // we already have the required permissions.
    return granted;
  }

  /// Display a snackbar saying that we can't record due to lack of permissions.
  void grantFailed(BuildContext context) {
    var snackBar = SnackBar(
        content: Text('Recording cannot start as you did not allow '
            'the required permissions'));

    // Find the Scaffold in the widget tree and use it to show a SnackBar.
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  ///s
  Future<bool> showAlertDialog(BuildContext context, String prompt) async {
    // set up the buttons
    Widget cancelButton = TextButton(
      child: Text("Cancel"),
      onPressed: () => Navigator.of(context).pop(false),
    );
    Widget continueButton = TextButton(
      child: Text("Continue"),
      onPressed: () => Navigator.of(context).pop(true),
    );

    // set up the AlertDialog
    var alert = AlertDialog(
      title: Text("Recording Permissions"),
      content: Text(prompt),
      actions: [
        cancelButton,
        continueButton,
      ],
    );

    // show the dialog
    var result = await showDialog<bool>(
      context: context,
      builder: (context) {
        return alert;
      },
    );
    return result!;
  }

  Widget buildShadePlayer() {
    return ElevatedButton(
      child: Text('Play Asset via Shade'),
      onPressed: () {
        var player = SoundPlayer.withShadeUI(autoFocus: false);
        player.onStopped = ({required wasUser}) async {
          await player.audioFocus(AudioFocus.abandonFocus);
          await player.release();
        };
        if (PlayerState().hushOthers) {
          player.audioFocus(AudioFocus.hushOthersWithResume);
        } else {
          player.audioFocus(AudioFocus.stopOthersWithResume);
        }
        player.play(createAssetTrack());
        ScaffoldMessenger.of(context).showSnackBar(new SnackBar(
            content: new Text("Playing via the OS's Media Player.")));
      },
    );
  }
}

Track createAssetTrack() {
  Track track;
  track = Track.fromAsset('assets/samples/sample.aac',
      mediaFormat: WellKnownMediaFormats.adtsAac);

  track.title = "Asset playback.";
  track.artist = "By sounds";

  if (Platform.isIOS) {
    track.albumArtAsset = 'AppIcon';
  } else if (Platform.isAndroid) {
    track.albumArtAsset = 'AppIcon.png';
  }
  return track;
}

///
class Left extends StatelessWidget {
  ///
  final String label;

  ///
  Left(this.label);
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Padding(
      padding: const EdgeInsets.only(top: 16.0, bottom: 4, left: 8),
      child: Container(
          alignment: Alignment.centerLeft,
          child: Text(label, style: TextStyle(fontWeight: FontWeight.bold))),
    );
  }
}

Widget buildRemoteShadeButton(BuildContext context) {
  return ElevatedButton(
    child: Text('Play Remote URL via Shade'),
    onPressed: () {
      playRemoteURL();
      ScaffoldMessenger.of(context).showSnackBar(
          new SnackBar(content: new Text("Playing test OS's Media Player.")));
    },
  );
}

/// test remote url on shade.
void playRemoteURL() async {
  SoundPlayer soundPlayer =
      SoundPlayer.withShadeUI(canSkipBackward: false, playInBackground: true);
  soundPlayer.onStopped = ({required wasUser}) => soundPlayer.release();

  Track track = Track.fromURL(
      'https://file-examples-com.github.io/uploads/2017/11/file_example_MP3_2MG.mp3');
  await soundPlayer.play(track);
}
