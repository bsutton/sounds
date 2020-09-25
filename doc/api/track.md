# Track

## Overview

The Track class holds track information as well as the audio media.

Sounds plays audio from a `Track` and records into a `Track`.

The Track class has the following constructors:

* `Track.fromFile`
* `Track.fromAsset`
* `Track.fromBuffer`
* `Track.fromURL`

Each constructor loads audio media from a different source.

### fromAsset

To play audio from a Flutter asset copy the file to your assets directory in the root of your Flutter project. \(i.e. under the folder that contains your pubspec.yaml.\)

`assets/sample.acc`

Add the asset to the 'assets' section of your pubspec.yaml

```yaml
flutter:
  assets:
  - beep.acc
```

Now play the file.

```dart
/// play the audio with no controls
QuickPlay.fromAsset('assets/beep.acc');

/// If you need to control/monitor the playback
var player = SoundPlayer.noUI();
player.onStopped = ({wasUser}) => player.release();
player.play(Track.fromAsset('assets/beep.aac'));
```

### fromFile

To play a track from a file use:

```dart
var track = Track.fromFile('/path/to/media');
QuickPlay.fromTrack(track, volume: 1.0);
```

When playing a file the path to the file MUST be a path on your Phone.

A common mistake is to provide a path to a file on your development PC. If you are looking to playback a static audio file \( a file that you will ship with your app \) then you should store it as an asset and use `Track.fromAsset`.

The `fromFile` constructor is used if you are dynamically loading audio files into the app. This might be as the result of recording on the app or you might retrieve the audio from a REST API or a URL \(consider `fromURL` in this case\).

### fromBuffer

To play a track from a buffer use:

```dart
Uint8List buffer = ....
// Load a local audio file into a buffer
Uint8List buffer = (await rootBundle.load('assets/samples/audio.mp3'))
    	.buffer
    	.asUint8List();

Track.fromBuffer(buffer)
QuickPlay.fromTrack(track, volume: 1.0);
```

### fromURL

To play a track from a url use:

```dart
Track.fromURL('https://file-examples.com/wp-content/uploads/2017/11/file_example_MP3_700KB.mp3');
QuickPlay.fromTrack(track, volume: 1.0);
```

#### Cacheing remote \(URL\) audio

When using `Track.fromURL` `Sounds` must first fully cache the audio file before it can start playing.

If you are using the `SoundPlayerUI` widget then the progress indicator will reflect the download progress.

If you need better control over the caching process of audio then I would recommend that you pre-cache the audio and then pass it to `Sounds` using `Track.fromPath`.

`Sounds` provides a convenience class [Downloader](downloader.md) to help download remote content.

## MediaFormat

When recording to or transcoding from a `Track` class you need to pass the [MediaFormat](mediaformat.md).

When doing playback you must pass an audio file that is encoded using a supported MediaFormat or an MediaFormatNotSupportedException will be thrown.

If you are looking to play an audio file that is encoded using a non native MediaFormat you must transcode the audio file to a supported MediaFormat. See the Sounds\_codec package for tools for transcoding audio.

## Meta Data

Tracks also allow you to store meta data about the track.

* title
* artist
* album art

You can specify just one field for the Album Art to display on the lock screen. Either :

* albumArtUrl
* albumArtFile
* albumArtFile

If no Album Art field is specified, Sounds will try to display the App icon.

```dart
var track = Track.fromFile('assets/rock.mp3');
track.title = 'Quarantine Jig';
track.artist = 'The Jiggy Kids';
```

## temporary file

The Track class also provides a convenience method to create a temporary file in the systems temp directory. This can be useful when using the recording api.

You are responsible for deleting the file once done.

The temp file name will be of the form`<uuid>.<mediaformat>`.

The [MediaFormat](mediaformat.md) has no affect on this file except to set the file's extension.

You could still be really stupid and save data in some other format into this file. But you're not that stupid are you :\)

```dart
   var file = Track.tempfile(MediaFormat.mp3)
   print(file);
   > /tmp/12asf7890a234.mp3
```

