# SoundRecorderUI

## Overview

The SoundRecorderUI widget provide a simple UI for recording audio.

Detailed SoundRecorderUI API documentation can be found on [pub.dev](https://pub.dev/documentation/sounds/latest/sounds/sounds-library.html).

The audio is recorded to a [Track](track.md).

### permissions

When recording audio you need access to the devices microphone and possibly its storage.

Sounds does not manage permissions for you. You must ensure that the appropriate permissions are obtained.

The package [permission\_handler](https://pub.dev/packages/permission_handler) provides a convenient set of methods for managing permissions.

When requesting permissions the OS will display a prompt to the user. I generally recommend that you only prompt the user for the required permissions at the point in time that they require them.

To allow you complete control over the timing of the permission request to the user you can provide a call back to the `requestPermission` argument which is called when the user clicks the 'record' button. Recording will not start until the callback completes.

### onStart

The onStart method is called when recording starts.

```dart
Widget build(BuildContext context)
{
    return SoundRecorderUI(track, onStart: () => print('recording started'))
}
```

### onStopped

The onStopped method is called when the recording stops.

```dart
Widget build(BuildContext context)
{
    return SoundRecorderUI(track, onStop: () => print('recording stopped'))
}
```

## Example:

This example is from the example app. It demonstrates how to create a Recorder `SoundRecorderUI` linked to a `SoundPlayerUI`.

The example demonstrates how to build a UI which allows a user to record audio and then immediately play it back.

The example also uses `requestPermissions` to display an explanatory dialog to the user before the OS displays its standard permission dialog.

The [RecorderPlaybackController](recorderplaybackcontroller.md) is responsible for coordinating the recording and playback so that only one can occur at a time.

```dart
import 'dart:async';
import 'dart:core';

import 'package:flutter/material.dart';
import 'package:sounds/sounds.dart';
import 'package:permission_handler/permission_handler.dart';

void main() {
  var recordingPath = Track.tempFile(MediaFormat.aacADTS);
  runApp(SoundExampleApp._internal(recordingPath));
}

class SoundExampleApp extends StatelessWidget {
  final Track _track;

  //
  SoundExampleApp._internal(String recordingPath)
      : _track = Track.fromFile(recordingPath, mediaFormat: MediaFormat.aacAdts);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Welcome to Flutter',
      home: Scaffold(
        appBar: AppBar(
          title: Text('Welcome to Flutter'),
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
      if (Permission.storage.status == PermissionStatus.undetermined) {
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
    Scaffold.of(context).showSnackBar(snackBar);
  }

  ///
  Future<bool> showAlertDialog(BuildContext context, String prompt) {
    // set up the buttons
    Widget cancelButton = FlatButton(
      child: Text("Cancel"),
      onPressed: () => Navigator.of(context).pop(false),
    );
    Widget continueButton = FlatButton(
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
    return showDialog<bool>(
      context: context,
      builder: (context) {
        return alert;
      },
    );
  }
}
```

