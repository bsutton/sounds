import 'package:flutter/material.dart';
import 'package:sounds/sounds.dart';

import '../util/grayed_out.dart';
import 'demo_audio_state.dart';
import 'demo_common.dart';

import 'demo_media_path.dart';
import 'recorder_state.dart';

/// UI for the Recorder example controls
class RecorderControls extends StatefulWidget {
  /// ctor
  const RecorderControls({
    Key? key,
  }) : super(key: key);

  @override
  _RecorderControlsState createState() => _RecorderControlsState();
}

class _RecorderControlsState extends State<RecorderControls> {
  bool paused = false;

  /// detect hot reloads and stop the recorder
  @override
  void reassemble() {
    super.reassemble();
    RecorderState().stopRecorder();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          buildDurationText(),
          buildDBIndicator(),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              buildStartStopButton(),
              buildRecorderPauseButton(),
            ],
          ),
        ]);
  }

  Widget buildDBIndicator() {
    return RecorderState().isRecording
        ? StreamBuilder<RecordingDisposition>(
            stream: RecorderState()
                .dispositionStream(interval: Duration(milliseconds: 50)),
            initialData: RecordingDisposition.zero(),
            builder: (context, snapshot) {
              var dbLevel = 1.0;
              if (snapshot.hasData) {
                var recordingDisposition = snapshot.data!;
                dbLevel = recordingDisposition.decibels;
              }

              return LinearProgressIndicator(
                  value: 100.0 / 160.0 * dbLevel / 100,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.green),
                  backgroundColor: Colors.red);
            })
        : Container();
  }

  Widget buildDurationText() {
    return StreamBuilder<RecordingDisposition>(
        stream: RecorderState()
            .dispositionStream(interval: Duration(milliseconds: 50)),
        initialData: RecordingDisposition.zero(),
        builder: (context, snapshot) {
          var txt = '';
          if (snapshot.hasData) {
            RecordingDisposition disposition;
            disposition = snapshot.data!;
            txt = formatDuration(disposition.duration);
          }

          return Container(
            margin: EdgeInsets.only(top: 12.0, bottom: 16.0),
            child: Text(
              txt,
              style: TextStyle(
                fontSize: 35.0,
                color: Colors.black,
              ),
            ),
          );
        });
  }

  Container buildStartStopButton() {
    return Container(
      width: 56.0,
      height: 50.0,
      child: ClipOval(
          child: GrayedOut(
        grayedOut: !canRecord(),
        child: TextButton(
          onPressed: () => startStopRecorder(context),
          style: TextButton.styleFrom(padding: EdgeInsets.all(8.0)),
          child: Image(
            image: recorderAssetImage(),
          ),
        ),
      )),
    );
  }

  Container buildRecorderPauseButton() {
    return Container(
      width: 56.0,
      height: 50.0,
      child: ClipOval(
        child: GrayedOut(
            grayedOut: !isRecording(),
            child: TextButton(
              style: TextButton.styleFrom(padding: EdgeInsets.all(8.0)
                  // disabledColor: Colors.white,
                  ),
              onPressed: pauseResumeRecorder,
              child: Image(
                width: 36.0,
                height: 36.0,
                image: AssetImage(paused
                    ? 'res/icons/ic_play.png'
                    : 'res/icons/ic_pause.png'),
              ),
            )),
      ),
    );
  }

  bool isRecording() {
    return audioState == AudioState.isRecording || isPaused();
  }

  bool isPaused() {
    return audioState == AudioState.isRecordingPaused;
  }

  bool canRecord() {
    if (audioState != AudioState.isRecording &&
        audioState != AudioState.isRecordingPaused &&
        audioState != AudioState.isStopped) {
      return false;
    }
    return true;
  }

  bool checkPreconditions() {
    var passed = true;
    if (MediaPath().isAsset ||
        // MediaPath().isBuffer ||
        MediaPath().isExampleFile) {
      var error = SnackBar(
          backgroundColor: Colors.red,
          content:
              Text('You must select a Media type of File or Buffer to record'));
      ScaffoldMessenger.of(context).showSnackBar(error);
      passed = false;
    }
    // Disable the button if the selected MediaFormat is not supported
    // Removed this test as felt it was better to display an error
    // when the user attempts to record so they know why they can't record.
    // if (!ActiveCodec().encoderSupported) return false;

    return passed;
  }

  void startStopRecorder(BuildContext context) async {
    paused = false;
    try {
      if (RecorderState().isRecording || RecorderState().isPaused) {
        await RecorderState().stopRecorder();
      } else {
        if (checkPreconditions()) {
          await RecorderState().startRecorder(context);
        }
      }
    } finally {
      setState(() {});
    }
  }

  AssetImage recorderAssetImage() {
    if (!canRecord()) return AssetImage('res/icons/ic_mic_disabled.png');
    return (RecorderState().isRecording || RecorderState().isPaused)
        ? AssetImage('res/icons/ic_stop.png')
        : AssetImage('res/icons/ic_mic.png');
  }

  AudioState get audioState {
    if (RecorderState().isPaused) {
      return AudioState.isRecordingPaused;
    }
    if (RecorderState().isRecording) return AudioState.isRecording;

    return AudioState.isStopped;
  }

  void pauseResumeRecorder() async {
    paused = !paused;
    await RecorderState().pauseResumeRecorder();

    setState(() {});
  }
}
