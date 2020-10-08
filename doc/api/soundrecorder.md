# SoundRecorder

## Overview

The `SoundRecorder` class provides an api for recording audio.

Detailed SoundRecorder API documentation can be found on [pub.dev](https://pub.dev/documentation/sounds/latest/sounds/sounds-library.html).

If you need a widget then you should be using `SoundRecorderUI`.

The `SoundRecorder` class records audio into a [Track](track.md).

As of this time the `SoundRecorder` can only record into a Track that has been created using `Track.fromFile()` and the `MediaFormat` must be a natively supported format.

### MediaFormat selection

The Track defines the [MediaFormat](mediaformat.md) that will be used to record the audio. You should select the `MediaFormat` carefully. `AdtsAacMediaFormat` is generally the best chooice as it is supported on both platforms.

#### Native MediaFormat

Each platform \(Android/iOS\) natively supports a small set of MediaFormat. If you choose a non native MediaFormat then `Sounds` throw a `MediaFormatException`.

When creating a `Track` to record to you must specify the `MediaFormat`. You can either directly use one of the `MediaFormats` derived from `NativeMediaFormat` or use the convenience class `WellKnowMediaFormats`.

The set of supported `NativeMediaFormat` classes are:

* MediaFormat
* AdtsAacMediaFormat
* OggOpusMediaFormat
* CafOpusMediaFormat
* Mp3MediaFormat
* OggVorbisMediaFormat
* PCMMediaFormat

The `WellKnownMediaFormats` classes exposes the following properties:

```dart
class WellKnownMediaFormats {
  /// Native MediaFormat for adts/aac
  static AdtsAacMediaFormat adtsAac = AdtsAacMediaFormat();

  /// MediaFormat for caf/opus
  static CafOpusMediaFormat cafOpus = CafOpusMediaFormat();

  /// MediaFormat pcm
  static PCMMediaFormat pcm = PCMMediaFormat();

  /// MediaFormat ogg/opus
  static OggOpusMediaFormat oggOpus = OggOpusMediaFormat();

  /// Native MediaFormat ogg/vorbis
  static OggVorbisMediaFormat oggVorbis = OggVorbisMediaFormat();

  /// Native MediaFormat mp3
  static MP3MediaFormat mp3 = MP3MediaFormat();
}
```

To obtain a recording in a non-native `MediaFormat`, record the audio using one of the `NativeMediaFormats` and then use the [sounds\_codec](https://github.com/bsutton/sounds_codec) package to trans-code the results into the desired `MediaFormat`.

The follow table details the navively support MediaFormat on each platform.

|  | AAC | OGG/Opus | CAF/Opus | MP3 | OGG/Vorbis | PCM |
| :--- | :--- | :--- | :--- | :--- | :--- | :--- |
| iOS | Yes | Yes | Yes | No | No | Yes |
| Android | Yes | No | No | No | No | No |

Note: the supported formats does vary depending on the SDK Version. Call `MediaFormat.isNativeEncoder` on the desired `MediaFormat` to determine if the format is supported on the current OS/SDK version. `AdtsAacMediaFormat` is the safest as it is supported on both OS's and has been for some time.

### Recording

To record you must specify the `Track` to record into using the `Track.fromFile` constructor. The Track file MUST exists and should be empty. When you start recording any existing content will be deleted.

Once you have finished recording you MUST release the `SoundRecorder` instance by calling `SoundRecorder.release()`.

In the following example we create a temporary file to record into.

Once recording is stopped the `onStopped` method will be called.

We then play the recording to the user use [QuickPlay](quickplay.md) and finally when QuickPlay completes we delete the temporary recording.

In the real world you probably want to save the recording rather than just deleting it.

```dart
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
```

## Permissions

In order to record audio you need to request access to the devices microphone.

`Sounds` will NOT request permissions. It is your responsibility to ensure that the appropriate permissions have been granted.

If the appropriate permissions are not available a `RecordingPermissionException` will be thrown.

You might want to look at the package [permission\_handler](https://pub.dev/packages/permission_handler) to obtain the required permissions.

{% hint style="info" %}
Most platforms require application level configuration to grant a permission. See the [Platforms](../contributing/platform-implementations.md) section for details.
{% endhint %}

You can request the microphone permission at any time however we recommend that you don't request the permission until the user performs an action that requires the microphone. By waiting until the user actually wants to access a feature you are more likely to have the user accept the permissions request.To facilitate this behaviour the `SoundRecorder` class provides a callback that is called just before recording starts. You can use this callback to prompt the user for the required permissions.

```dart
    var recording = Track.tempFile(WellKnownMediaFormats.adtsAac);
    var track =
        Track.fromFile(recording, mediaFormat: WellKnownMediaFormats.adtsAac);

    var recorder = SoundRecorder();
    recorder.onRequestPermissions = (track) => askUserForPermission(track);
    recorder.record(track);
```

### Recording quality

You can control the audio quality of a recording via the `MediaFormat` used when you create the `Track` you are going to record into.

```dart
  var recording = Track.tempFile(WellKnownMediaFormats.adtsAac);
    var track = Track.fromFile(recording,
        mediaFormat: AdtsAacMediaFormat(
          sampleRate: 16000,
          numChannels: 1,
          bitRate: 16000,
        ));

    var recorder = SoundRecorder();
    recorder.onStopped = ({bool wasUser}) {
      recorder.release();
    };

    recorder.record(track, audioSource: AudioSource.mic);
```

The above examples uses the default values so you can exclude any you don't need to change.

## Audio Source

When recording you may want to choose the audio source.

The default audio source is the microphone. The set of supported sources is platform dependant.

TODO: provide a table of supported sources and what we do when an invalid source is passed.

You choose the audio source when calling `SoundRecorder.record()`.

```dart
    var recording = Track.tempFile(WellKnownMediaFormats.adtsAac);
    var track =
        Track.fromFile(recording, mediaFormat: WellKnownMediaFormats.adtsAac);

    var recorder = SoundRecorder();
    recorder.record(track, audioSource: AudioSource.mic);
```

See the [AudioSource](audiosource.md) class for details on the available sources.

### Monitoring progress

Whilst recording you may want to monitor the progress of the recording. You can do this using by calling `SoundRecorder.dispositionStream`.

```dart
    Stream<RecordingDisposition> stream = SoundRecorder()
        .dispositionStream(interval: Duration(milliseconds: 100));
    stream.listen((disposition) {});
```

Typically you would consume the stream using a Flutter `StreamBuilder` but how you us it is up to you.

When subscribing to a `SoundRecorder` stream you may set an interval. By default you will receive an stream event every 10 milliseconds.

The `RecordingDisposition` object provided by the stream contains both the current duration of the recording and the current decibels \(how load it is\).

```dart
class RecordingDisposition {
  final Duration duration;
  final double decibels;
}
```

### Stopping a recording

To stop a recording you call `SoundRecorder.stop()`.

```dart
 var recorder = SoundRecorder();
    recorder.record(Track.fromFile('path to file',
        mediaFormat: WellKnownMediaFormats.adtsAac));

    /// some widget event
    void onTap() {
      recorder.stop();
    }
```

### Pause recorder

You can pause the recording at any point between calling start/stop.

On Android this API verb needs al least SDK-24.

```dart
recorder.pause();
```

**Resume recorder**

If you pause the recording you need to resume the recording.

On Android this API verb needs at least SDK-24.

```dart
recorder.resume();
```

### cleanup

Create a recorder you must ensure that you call `release()` on the recorder instance. If you fail to call release then you make stop other applications \(and your own app\) from doing any more recording.

You MUST also ensure that the recorder has been stopped when your widget is detached from the ui. Overload your widget's dispose\(\) method to stop the recorder when your widget is disposed.

```dart
@override
void dispose() {
	recorder.release();
	super.dispose();
}
```

