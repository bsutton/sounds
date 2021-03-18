import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:sounds/sounds.dart';

void main() {
  test('Sound Recorder Doco', () {
    final recording = Track.tempFile(WellKnownMediaFormats.adtsAac);
    final track =
        Track.fromFile(recording, mediaFormat: WellKnownMediaFormats.adtsAac);
    final recorder = SoundRecorder();
    recorder.onStopped = ({wasUser = false}) {
      recorder.release();

      /// recording has finished so play it back to the user.
      QuickPlay.fromTrack(track, onStopped: () {
        /// delete the temp file now we are done with it.
        File(recording).delete();
      });
    };
    recorder.record(track);

    recorder.stop();
  });

  test('Sound Recorder permissions example', () {
    final recording = Track.tempFile(WellKnownMediaFormats.adtsAac);
    final track =
        Track.fromFile(recording, mediaFormat: WellKnownMediaFormats.adtsAac);

    final recorder = SoundRecorder();
    // ignore: unnecessary_lambdas
    recorder.onRequestPermissions = (track) => askUserForPermission(track);
    recorder.record(track);
  });

  test('Sound Recorder #Recording Quality', () {
    final recording = Track.tempFile(WellKnownMediaFormats.adtsAac);
    final track =
        Track.fromFile(recording, mediaFormat: const AdtsAacMediaFormat());

    final recorder = SoundRecorder();
    recorder.onStopped = ({wasUser = false}) {
      recorder.release();
    };

    recorder.record(track);
  });

  test('Sound Recorder #AudioSource ', () {
    final recording = Track.tempFile(WellKnownMediaFormats.adtsAac);
    final track =
        Track.fromFile(recording, mediaFormat: WellKnownMediaFormats.adtsAac);

    final recorder = SoundRecorder();
    recorder.record(track);
  });

  test('Sound Recorder #Monitoring progress ', () {
    // ignore: omit_local_variable_types
    final Stream<RecordingDisposition> stream = SoundRecorder()
        .dispositionStream(interval: const Duration(milliseconds: 100));
    stream.listen((disposition) {});
  });

  test('Sound Recorder #Stopping a recording ', () {
    final recorder = SoundRecorder();
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
