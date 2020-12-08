import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:sounds/sounds.dart';
import 'package:sounds/src/audio_source.dart';

import '../lib/src/media_format/adts_aac_media_format.dart';


void main() {
  test('Sound Recorder Doco', () {
    var recording = Track.tempFile(WellKnownMediaFormats.adtsAac);
    var track =
        Track.fromFile(recording, mediaFormat: WellKnownMediaFormats.adtsAac);
    var recorder = SoundRecorder();
    recorder.onStopped = ({wasUser}) {
      recorder.release();

      /// recording has finished so play it back to the user.
      QuickPlay.fromTrack(track, onStopped: (() {
        /// delete the temp file now we are done with it.
        File(recording).delete();
      }));
    };
    recorder.record(track);

    recorder.stop();
  });

  test('Sound Recorder permissions example', () {
    var recording = Track.tempFile(WellKnownMediaFormats.adtsAac);
    var track =
        Track.fromFile(recording, mediaFormat: WellKnownMediaFormats.adtsAac);

    var recorder = SoundRecorder();
    // ignore: unnecessary_lambdas
    recorder.onRequestPermissions = (track) => askUserForPermission(track);
    recorder.record(track);
  });

  test('Sound Recorder #Recording Quality', () {
    var recording = Track.tempFile(WellKnownMediaFormats.adtsAac);
    var track = Track.fromFile(recording,
        mediaFormat: AdtsAacMediaFormat(
          sampleRate: 16000,
          numChannels: 1,
          bitRate: 16000,
        ));

    var recorder = SoundRecorder();
    recorder.onStopped = ({wasUser}) {
      recorder.release();
    };

    recorder.record(track, audioSource: AudioSource.mic);
  });

  test('Sound Recorder #AudioSource ', () {
    var recording = Track.tempFile(WellKnownMediaFormats.adtsAac);
    var track =
        Track.fromFile(recording, mediaFormat: WellKnownMediaFormats.adtsAac);

    var recorder = SoundRecorder();
    recorder.record(track, audioSource: AudioSource.mic);
  });

  test('Sound Recorder #Monitoring progress ', () {
    // ignore: omit_local_variable_types
    Stream<RecordingDisposition> stream = SoundRecorder()
        .dispositionStream(interval: Duration(milliseconds: 100));
    stream.listen((disposition) {});
  });

  test('Sound Recorder #Stopping a recording ', () {
    var recorder = SoundRecorder();
    recorder.record(Track.fromFile('path to file',
        mediaFormat: WellKnownMediaFormats.adtsAac));

    recorder.resume();

    /// some widget event
    // ignore: unused_element
    void onTap() {
      recorder.stop();
    }
  });
  test('Sound Recorder #AudioSource ', () {});

  test('Sound Recorder #AudioSource ', () {});
}

Future<bool> askUserForPermission(Track _) async {
  return true;
}
