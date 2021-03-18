import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:sounds/sounds.dart';

void main() {
  test('Sound Recorder Doco', () {
    final recording = Track.tempFile(WellKnownMediaFormats.adtsAac);
    final track =
        Track.fromFile(recording, mediaFormat: WellKnownMediaFormats.adtsAac);
    final recorder = SoundRecorder();
    recorder
      ..onStopped = ({wasUser = false}) {
        recorder.release();

        /// recording has finished so play it back to the user.
        QuickPlay.fromTrack(track, onStopped: () {
          /// delete the temp file now we are done with it.
          File(recording).delete();
        });
      }
      ..record(track)
      ..stop();
  });

  test('Sound Recorder permissions example', () {
    final recording = Track.tempFile(WellKnownMediaFormats.adtsAac);
    final track =
        Track.fromFile(recording, mediaFormat: WellKnownMediaFormats.adtsAac);

    SoundRecorder()
      ..onRequestPermissions = askUserForPermission
      ..record(track);
  });

  test('Sound Recorder #Recording Quality', () {
    final recording = Track.tempFile(WellKnownMediaFormats.adtsAac);
    final track =
        Track.fromFile(recording, mediaFormat: const AdtsAacMediaFormat());

    final recorder = SoundRecorder();
    recorder
      ..onStopped = ({wasUser = false}) {
        recorder.release();
      }
      ..record(track);
  });

  test('Sound Recorder #AudioSource ', () {
    final recording = Track.tempFile(WellKnownMediaFormats.adtsAac);
    final track =
        Track.fromFile(recording, mediaFormat: WellKnownMediaFormats.adtsAac);

    SoundRecorder().record(track);
  });

  test('Sound Recorder #Monitoring progress ', () {
    SoundRecorder()
        .dispositionStream(interval: const Duration(milliseconds: 100))
        .listen((disposition) {});
  });

  test('Sound Recorder #Stopping a recording ', () {
    final recorder = SoundRecorder()
      ..record(Track.fromFile('path to file',
          mediaFormat: WellKnownMediaFormats.adtsAac))
      ..resume();

    /// some widget event
    // ignore: unused_element
    void onTap() {
      recorder.stop();
    }
  });
  test('Sound Recorder #AudioSource ', () {});

  test('Sound Recorder #AudioSource ', () {});
}

Future<bool> askUserForPermission(Track _) async => true;
