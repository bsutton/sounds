import 'dart:async';
import 'dart:core';

import 'package:flutter/material.dart';
import 'package:sounds/sounds.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:sounds_common/sounds_common.dart';

void main() {
  var recordingPath = Track.tempFile(AdtsAacMediaFormat());
  runApp(SoundExampleApp._internal(recordingPath));
}

class SoundExampleApp extends StatelessWidget {
  final Track _track;

  //
  SoundExampleApp._internal(String recordingPath)
      : _track =
            Track.fromFile(recordingPath, mediaFormat: AdtsAacMediaFormat());

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Sounds',
      home: Scaffold(
        appBar: AppBar(
          title: Text('Welcome to Sounds'),
        ),
        body: buildBody(),
      ),
    );
  }

  Widget buildBody() {
    // link the recorder and player so you can record
    // and then playback the message.
    // Note: the recorder and player MUST share the same track.
    return RecorderPlaybackController(
        child: Column(
      children: [
        /// Add the recorder
        SoundRecorderUI(
          /// the track to record into.
          _track,

          /// callback for when recording needs permissions
          requestPermissions: requestPermissions,
        ),
        Padding(
          padding: const EdgeInsets.all(10),
          // add the player
          child: SoundPlayerUI.fromTrack(_track),
        )
      ],
    ));
  }

  /// Callback for when the recorder needs permissions to record
  /// to the [track].
  Future<bool> requestPermissions(BuildContext context, Track track) async {
    var granted = false;

    /// change this to true if the track doesn't use
    /// external storage on android.
    var usingExternalStorage = false;

    // Request Microphone permission if needed
    print('storage: ${await Permission.microphone.status}');
    var microphoneRequired = !await Permission.microphone.isGranted;

    var storageRequired = false;

    if (usingExternalStorage) {
      /// only required if track is on external storage
      if (await Permission.storage.status == PermissionStatus.denied) {
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

      var reason = 'To record a message we need permission ';

      if (microphoneRequired) {
        reason += 'to access your microphone';
      }

      if (both) {
        reason += ' and ';
      }

      if (storageRequired) {
        reason += 'to store a file on your phone';
      }

      reason += '.';

      if (both) {
        reason += " \n\nWhen prompted click the 'Allow' button on "
            'each of the following prompts.';
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

  ///
  Future<bool> showAlertDialog(BuildContext context, String prompt) async {
    // set up the buttons
    Widget cancelButton = TextButton(
      onPressed: () => Navigator.of(context).pop(false),
      child: Text('Cancel'),
    );
    Widget continueButton = TextButton(
      onPressed: () => Navigator.of(context).pop(true),
      child: Text('Continue'),
    );

    // set up the AlertDialog
    var alert = AlertDialog(
      title: Text('Recording Permissions'),
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
}
