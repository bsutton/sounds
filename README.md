# Sounds

Sounds is a fork of the Flutter Sound project.

Sounds is almost a complete rewrite of the dart code from Flutter Sound.
The aim of the rewrite has been resolve a number of issues apparent in Flutter Sound:
* jank during playback.
* crashes due to threading issues.
* redesign the api so it is clean and consistent.
* design an api that will accomodate future expansion of the core feature set.
* provide additional features.
* Hide internal apis from the public api.
* Provide a consistent error handling mechanisim via exceptions.
* Remove duplicated code.
* Bring the code in line with Google's recommended best practices.

<img src="https://raw.githubusercontent.com/bsutton/sounds/master/SoundsLogo.png" width="70%" height="70%" />

<p align="left">
  <a href="https://pub.dartlang.org/packages/sounds"><img alt="pub version" src="https://img.shields.io/pub/v/sounds.svg?style=flat-square"></a>
</p>

## Overview
The Sounds package is a Flutter package that provides audio recording and playback functionality for both the `android` and `ios` platforms.

Sounds provides both a high level api and widgets for recording and playback.

The api is designed so you can use the supplied widgets or roll your own.

The Sounds package supports playback from:
* Assets
* Files
* URL
* Native Streams (with sync).

## Features
The Sounds package includes the following features
* Play audio without any UI
* Play audio using the built in SoundPlayerUI Widget.
* Play audio using the OSs' Media Player
* Roll your own UI utilising the Sounds api.
* Record audio without any UI
* Record audio using the builtin SoundRecorderUI Widget.
* Roll your own Recording UI utilising the Sounds api.
* Support for releasing/resuming resources when the app pauses/resumes.


## Roadmap 
See the [Roadmap](https://github.com/bsutton/sounds/wiki/RoadMap.md)  for details on the future of Sounds.

## Contributing
See the [Contributing](https://github.com/bsutton/sounds/wiki/Contributing.md) guide for details on contributing to Sounds.


The key classes are:

## Api classes

QuickPlay - instantly play an audio file (no ui). Perfect for the odd beep.

Track - Defines a track including the artist details and the audio media.

Album - play a collection of tracks via the OSs' audio UI.

SoundPlayer - provides an api for playing audio including pause/resume/seek.

SoundRecorder - api for recording audio.

## Widgets

SoundPlayerUI - displays an HTML 5 style audio controller widget.

SoundRecorderUI - displays a recording widget.

RecorderPlaybackController - pairs a SoundPlayerUI and SoundRecorderUI to provide a co-ordinated recording/playback UI.

Note: there are some limitations on the supported codecs. See the [codec] section below.

![Demo](https://raw.githubusercontent.com/bsutton/sounds/master/example.png)



# Playback via api
The Sounds package uses a 'Track' class to hold the audio media and meta data for both playback and recording.

Sounds allows you to recorded to a Track and then immediately play the track back to the user.

## Track
The Track class holds track information as well as the audio media.

The Track class has the following constructors:
* `Track.fromFile`
* `Track.fromAsset`
* `Track.fromBuffer`
* `Track.fromURL`


To play a track from a file use:
```dart
var player = SoundPlayer.withUI();
player.onStopped = ({wasUser}) => player.release();
player.seekTo(Duration(seconds: 5)); // yes, you can call seek before play.
player.play(Track.fromURL(uri));
```

To play a track from a buffer use:

```dart
var player = SoundPlayer.withUI();
player.onStopped = ({wasUser}) => player.release();
player.seekTo(Duration(seconds: 5));
player.play(Track.fromBuffer(buffer));
```

To play a track from an asset use:

```dart
var player = SoundPlayer.withUI();
player.onStopped = ({wasUser}) => player.release();
player.seekTo(Duration(seconds: 5));
player.play(Track.fromAsset('asset/somfile.aac'));
```

The Track class constructors take a file path, asset, url or buffer and a codec.

The Track details are now set via properties:

```dart
var track = Track.fromFile('path to media');
track.title = 'Quarantine Jig';
track.artist = 'The Jiggy Kids';
var player = SoundPlayer.withUI();
player.onStopped = ({wasUser}) => player.release();
player.play(track);
```

### Monitoring

Sounds uses streams to allow you to monitor both recording and playback progress.

You can now use a StreamBuilder which will greatly simplify the construction of UI components (or you can use one of the new Sounds UI widgets).

#### SoundPlayer Monitoring

To obtain a subscription to the `SoundPlayer` stream:

```dart 
var Stream<PlaybackDisposition> = SoundPlayer.noUI().dispositionStream(interval);
```

The result is a stream of `PlaybackDisposition`s which includes both the audio's duration (length) and current position.


#### SoundRecorder
The `SoundRecorder` subscription model is the same as for the `SoundPlayer` except that a set of `RecordingDisposition`s are streamed :

```dart
var Stream<RecordingDisposition>
  = SoundRecorder(). dispositionStream(interval);
```

The `RecordingDisposition` contains both the duration of the recording and the decibels.

```dart
class RecordingDisposition {
  final Duration duration;
  final double decibels;
}
```


# QuickPlay
The Sounds package includes a number of convenience classes to make playback easy.


`QuickPlay` plays a single audio file immediatley (there is no `play` method).

This is ideal for small audio files and has the benefit that it frees its own resources.

The audio file is played from start to end. You can't monitor nor stop the stream.

```dart
QuickPlay.fromFile('beep.aac', volume: 0.5);
QuickPlay.fromTrack(Track.fromAsset('assets/ring.aac'), volume: 0.5);
```

`Album` allows you to create an album of Track (statically or dynamically) and play them sequentially via the OSs' UI.


# Migration from Flutter Sound to Sounds

## Playback

In the Sounds package the `TrackPlayer` and `FlutterSoundPlayer` have been depreacted in favor of a single class `SoundPlayer`.

`SoundPlayer` now has two constructors:

Code that previously used `TrackPlayer` should now call the `SoundPlayer.withUI()` constructor.

Code that used the `FlutterSoundPlayer` should now call the `SoundPlayer.noUI()` constructor.

The equivalent method names on the `FlutterSoundPlayer` class have also been shortend.

Example changes:

`FlutterSoundPlayer.startPlayer()` -> `SoundPlayer.play()`
`FlutterSoundPlayer.pausePlayer()` -> `SoundPlayer.pause()`
`FlutterSoundPlayer.stopPlayer()` ->  `SoundPlayer.stop()`

The new `play` methods replaces both `startPlayer(uri)` and `startPlayerFromBuffer()` and now takes a `Track`.

## subscription

In the SoundPlayer the original `SoundPlayer` subscription model is now been unified into a single stream via:

```dart 
var Stream<PlaybackDisposition> = SoundPlayer.noUI().dispositionStream(interval);
```

The result is a stream of `PlaybackDisposition`s which includes both the audio's duration (length) and current position.

## Recording
The `FlutterSoundRecorder` has been replaced with `SoundRecorder`.
Changes to the recorder a similar to the changes made to the player.


## Types
Types and enums now consistently use camelCase.

e.g.
`t_PLAYER_STATE.IS_STOPPED -> PlayerState.isStopped`



# Install

For help on adding as a dependency, view the [documentation](https://flutter.io/using-packages/).

Sounds comes in two flavors :
- the **FULL** flavor : sounds
- the **LITE** flavor : sounds_lite

The big difference between the two flavors is that the **LITE** flavor does not have `mobile_ffmpeg` embedded inside.
There is a huge impact on the memory used, but the **LITE** flavor will not be able to do some codecs :
- Playback OGG/OPUS on iOS
- Record OGG_OPUS on iOS
And will not be able to offer some helping functions, like `CodecHelper.FFmpegGetMediaInformation()` or `CodecHelper.duration()`

Add `sounds` or `sounds_lite` as a dependency in pubspec.yaml. The actual versions are `^sound: 0.8.0` and `^sounds_lite: 0.8.0`

Note: going forward codec support will be moved into a separate set of packages.

```
dependencies:
  flutter:
    sdk: flutter
  sounds: ^0.8.0
```
or
```
dependencies:
  flutter:
    sdk: flutter
  sounds_lite: ^0.8.0
```

The Sounds sources [are here](https://github.com/bsutton/sounds).

### FFmpeg

Sounds makes use of flutter_ffmpeg. 

```flutter_ffmpeg audio-lts``` is embedding inside the Sounds package. If your App needs to use FFmpeg, you must use the embedded version inside Sounds instead of adding a new dependency in your pubspec.yaml.

Note: this will change once the codecs are broken out into a separate package.

## Post Installation

- On _iOS_ you need to add a usage description to `info.plist`:

  ```xml
  <key>NSMicrophoneUsageDescription</key>
    <string>This sample uses the microphone to record your speech and convert it to text.</string>
  <key>UIBackgroundModes</key>
  <array>
  	<string>audio</string>
  </array>
  ```

- On _Android_ you need to add a permission to `AndroidManifest.xml`:

  ```xml
  <uses-permission android:name="android.permission.RECORD_AUDIO" />
  <uses-permission android:name="android.permission.FOREGROUND_SERVICE" />
  ```


# Using the Sounds package

## QuickPlay
The QuickPlay class provides the simplest means of playing audio.

If you just want to play an audio file then this is the place to start.

By default the QuickPlay doesn't display any UI, it simply plays the audio until it completes.

You have no control over the audio once it starts but you don't have to do any cleanup once it completes.

```dart
QuickPlay.fromFile('path to file');
```

QuickPlay provides a number of constructors that allow you play audio from different sources.

You set the volume and display the OSs' audio player if you choose.

```dart
QuickPlay.fromBuffer(databuffer, codec: Codec.aac, volume: 1.0, withUI: true);
```

## Displaying a UI

If you need a UI to allow your user to control playback then you have three options:

1) Use `SoundPlayer.withUI()` 
This will display the OSs' audio player allowing the user to control playback.

2) Use Sounds's SoundPlayerUI widget which provide a HTML5 like audio player.

3) Directly use `SoundPlayer.noUI()` to roll your own widget. You can start with the SoundPlayerUI code as an example of how to do this.

The API is documented in detail at [pub.dev](https://pub.dev/documentation/sounds/latest/)

## Play audio from an asset

To play audio from a project asset copy the file to your assets directory in the root of your dart project. (i.e. under the folder that contains your pubspec.yaml.)

```assets/sample.acc```

Add the asset to the 'assets' section of your pubspec.yaml

```
flutter:
  assets:
  - sample.acc
```

Now play the file.

```dart
/// play the audio with no controls
QuickPlay.fromFile('beep.acc');

/// If you need to control/monitor the playback
var player = SoundPlayer.noUI();
player.onStopped = ({wasUser}) => player.release();
player.play(Track.fromFile('sample.aac'));
```

CRITICAL:

You must be certain to release the player once you have finished playing the audio.

You can reuse a `SoundPlayer` as many times as you want as long as you call `SoundPlayer.release()` once you are done with it.

`Track.fromFile` uses the passed filename extension to determine the correct codec to play. If you need to play a file with an extension that doesn't match one of the known file extensions then you MUST pass in the codec.

See the [codec](https://pub.dev/documentation/sounds/latest/codec/codec-library.html) documentation for details on the supported codecs.

## Specify a codec

If you audio file doesn't have an appropriate file extension then you can explicitly pass a codec.

```dart
var player = SoundPlayer.noUI();
player.onStopped = ({wasUser}) => player.release();
player.play(Track.fromFile('sample.blit', codec: Codec.mp3));
```

## Play audio from an external URL

You can play a remote audio file by passing a URL to QuickPlay.

See the [codec](https://pub.dev/documentation/sounds/latest/codec/codec-library.html) documentation for details on the supported codecs.

```dart
var player = SoundPlayer.noUI();
player.onStopped = ({wasUser}) => player.release();
player.play(Track.fromURL('https://some audio file', codec: Codec.mp3););
```

## Play audio from an in memory buffer
When playing a audio file from a buffer you MUST provide the codec.


See the [codec](https://pub.dev/documentation/sounds/latest/codec/codec-library.html) documentation for details on the supported codecs.

```dart
Uint8List buffer = ....
var player = SoundPlayer.noUI();
player.onStopped = ({wasUser}) => player.release();
player.play(Track.fromBuffer(buffer, codec: Codec.mp3));
```

## Play audio allowing the user to control playback via OSs' UI

`SoundPlayer` can display the OSs' Audio player UI allowing the user to control playback.

```dart
var player = SoundPlayer.withUI();
player.onStopped = ({wasUser}) => player.release();
player.play(Track.fromFile('sample.blit', codec: Codec.mp3));
```

## Control the OSs' UI

The OSs' media player has three buttons, skip forward, skip backwards and pause.
By default the skip buttons are disabled and the pause button enabled.

You can modify the the state of these buttons with the `SoundPlayer.withUI` constructor.

```dart
var player = SoundPlayer.withUI(canPause:true, canSkipBackward:false
	, canSkipForward: true);
player.onStopped =  ({wasUser}) => player.release();
player.play(Track.fromFile('sample.blit', codec: Codec.mp3));
```

## Display artist details
You can also have the OSs' audio player display the artist details by
specifying properties on a `Track`.

```dart
var track = Track.fromFile('sample.aac');
track.title = 'Reckless';
track.artist = 'Sounds';
track.albumArtUrl = 'http://some image url';

var player = SoundPlayer.withUI()
player.onStopped = ({wasUser}) => player.release();
player.fromTrack(track);
```
The title, artist and album art will be displayed on the OSs' Audio Player.

# Albums
Sounds supports the concept of Albums which are, as you would expect, a collection of `Track`s which can be played in order.

The `Album` uses the OSs Media Player to display the tracks as they are played.

A user can use the skip back, forward and pause buttons to navigate the album.

## Playing an Album

If you want to play a collection of tracks then you can create an Album with a static set of Tracks or a virtual set of Tracks.

### Play album with static set of Tracks

```dart
var album = Album.fromTracks([
	Track.fromFile('sample.acc'),
	Track.fromURL('http://fqdn/sample.mp3'),
]);
player.onStopped = ({wasUser}) => player.release();
album.play();
```
By default an Ablum displays the OSs' audio UI.
You can suppress the UI via by passing in `SoundPlayer.noUI()` to the Album in which case the `Tracks` will be played sequentially until they complete. (I'm not certain this is actually useful).

```dart
var album = Album.fromTracks([
	Track.fromFile('sample.acc'),
	Track.fromURL('http://fqdn/sample.mp3'),
]
, session: SoundPlayer.noUI());
player.onStopped = ({wasUser}) => player.release();
album.play();
```

### Play album with a virtual set of Tracks

Virtual tracks allow you to create an album of infinite size which
could be useful if you are pulling audio from an external source.

If you create a virtual album you MUST implement the `onSkipForward`
, `onSkipBackwards` and `onFirstTrack` methods to supply the album with Tracks on demand.

```dart
 var album = Album.virtual();
 album.onFirstTrack = (int currentTrackIndex, Track current)
		=> Track('http://random/xxxx');
album.onSkipForward = (int currentTrackIndex, Track current)
		=> Track('http://random/xxxx');
album.onSkipBackwards = (int currentTrackIndex, Track current)
		=> Track('http://random/xxxx');
player.onStopped = ({wasUser}) => player.release();
album.play();

```

## Controlling Playback
The `SoundPlayer` provides fined grained control over how the audio is played as well as been able to monitor playback and respond to user events.

Importantly `SoundPlayer` also allows you to play multiple audio files using the same session. 

Maintaining the same session is important if you are using the OSs' audio UI for user control. 
If you don't use a single `SoundPlayer` then the user will experience flicker between tracks as the OSs' audio player is destroyed and recreated between each track.

The `Album` class provides an easy to use method of utilising a single session without the complications of an `SoundPlayer`.


```dart
var player = SoundPlayer.withUI();

var track = Track.fromFile('sample.aac');
track.title = 'Corona Virus Rock';
player.onStarted => print('started');
player.onStopped = ({wasUser}) =>  print('stopped');
player.onPause => print('paused');
player.onResume => print('resumed');
player.play(track);

...

player.release();

```


## Monitor playback position
If you are building your own widget you might want to display a progress bar that displays the current playback position.

The easiest way to do this is via the `SoundPlayerUI` widget but if you want to write your own then you will want to use the `dispositionStream` with a StreamBuilder.

To use a `dispositionStream` you need to create an `SoundPlayer`.

```dart
class MyWidgetState
{
	/// use .noUI() as you are going to build your own UI.
	var player = SoundPlayer().noUI();

	void initState()
	{
		super.initState();

	}

	void dispose()
	{
		player.release();
		super.dispose();
	}

	 Widget build() {
    	 return Row(children:
		 	[Button('Play' onTap: onPlay)
		 		, StreamBuilder<PlaybackDisposition>(
					stream: player.dispositionStream,
					initialData: PlaybackDisposition.zero(),
					builder: (context, snapshot) {
					var disposition = snapshot.data;
					return Slider(
						max: disposition.duration.inMilliseconds.toDouble(),
						value: disposition.position.inMilliseconds.toDouble(),
						onChanged: (value) =>
							player._seek(Duration(milliseconds: value.toInt())),
					);
            		}
				))
			]);
      },
    ));

  /// you would wire this to a button
  void onPlay()
  {
	  player.play(Track.fromFile('sample.aac'));
  }

   /// you would wire this to a pause button
  void onPause()
  {
	  player.pause();
  }

   /// you would wire this to a button
  void onResume()
  {
	  player.resume();
  }
}
```

## Codec compatibility

The following codecs are supported by sounds:

|                 | AAC | OGG/Opus | CAF/Opus | MP3 | OGG/Vorbis | PCM |
| :-------------- | :-: | :------: | :------- | :-- | :--------- | :-- |
| iOS encoder     | Yes |   Yes    | Yes      | No  | No         | Yes |
| iOS decoder     | Yes |   Yes    | Yes      | Yes | No         | Yes |
| Android encoder | Yes |    No    | No       | No  | No         | No  |
| Android decoder | Yes |   Yes    | No       | Yes | Yes        | Yes |

This table will be updated as codecs are added.

# SoundRecorder Usage
The `SoundRecorder` class provides an api for recording audio.

The `SoundRecorder` does not have a UI so you must either build your own or you can use Sounds's `SoundRecorderUI` widget.


## Recording

When you have finished with your `SoundRecorder` you MUST call `SoundRecorder.release()`.

```dart
var track = Track.fromFile('fred.aac');
var recorder = SoundRecorder();
recorder.onStopped = ({wasUser}) {
	recorder.release();
	// quick play will release the track resources!
 	QuickPlay.fromTrack(track);
});
recorder.record(track);
```


`SoundRecorder` requests the necessary permissions (microphone and storage) when you call `SoundRecorder.start()`.

If you want to control the permissions yourself you need to set `SoundRecorder.requestPermission = false`.


```dart
var recorder = SoundRecorder.tempPath();
recorder.requestPermission = false;
recorder.start();
```

## Monitoring duration and dbLevels.

`SoundRecorder` provides a stream that you can listen to to get live updates as the recording progresses.

The stream of `RecordingDisposition` events contain the duration of the recording and the instantanous dB level.

The dbLevel is in the range of 0-120dB.

```dart
SoundRecorder recorder = SoundRecorder.toPath('path to store recording', codec: Codec.aac,);
recorder.dispositionStream().listen((disposition) {
	Duration duration = dispostion.duration;
	double dbLevel = disposition.dbLevel;
	print('The recording has grown to: $duration');
	print('At this very moment the the audio is $dbLevel loud');
});

recorder.onStopped(({wasUser}) {
	recorder.release()
	/// Now play the recording back.
	QuickPlay.fromFile(recorder.path).play();
});

recorder.start();
```

### Supported Codecs

Currently a limited set of Codecs are supported by `SoundRecorder`.

#### iOS

- AAC (this is the default)
- CAF/OPUS
- OGG/OPUS
- PCM

#### Android

- AAC (this is the default)


For example, to encode with OPUS you do the following :

```dart
var recorder = SoundRecorder();
recorder.record(Track.fromFile('path to file', codec: Codec.aac));

```

## Stop recorder
You can programatically stop the recorder by calling  `stop()`.

```dart
var recorder = SoundRecorder();
recorder.record(Track.fromFile('path to file', codec: Codec.aac));


/// some widget event
void onTap()
{
	recorder.stop();
}
```

You MUST ensure that the recorder has been stopped when your widget is detached from the ui.
Overload your widget's dispose() method to stop the recorder when your widget is disposed.

```dart
@override
void dispose() {
	recorder.release();
	super.dispose();
}
```

## Pause recorder

On Android this API verb needs al least SDK-24.

```dart
await recorder.pause();
```

#### Resume recorder

On Android this API verb needs al least SDK-24.

```dart
await recoder.resume();
```

## SoundRecorderUI
Sounds contains a standard `SoundRecorderUI` widget that allows you to record.

```dart

void build(BuildContext build)
{
	Track track = Track.fromFile('path to file to record into');
	SoundRecorderUI recorderUI =  SoundRecorderUI(track.
		onStart:  () => onStart(),
		onStopped:  ({wasUser}) => onStop());

	return recorderUI;
}

```

#### iosSetCategory(), androidFocusRequest(), requestFocus() and abandonFocus()  - (optional)

Those three functions are optional. If you do not control the audio focus with the function `requestFocus()`, sounds will request the audio focus each time you call 'play()' on either the `SoundPlayer` or `QuickPlay`.
The focus will be automatically release it when playback is finished or when you call the `stop()` method on the `SoundPlayer`.


## TODO this section needs reviewing as I don't think it is correct.
## The android documentation stats that requestFocus should be called on the play() callback which we do by default.
Before controlling the focus with `requestFocs()` you must call `iosSetCategory()` on iOS or `androidAudioFocusRequest()` on Android. `requesFocus()` and `androidAudioFocusRequest()` are useful if you want to `hush others` (in android terminology duck others).
Those functions are probably called just once when the app starts.
After calling this function, the caller is calling `requestFocus()/abandonFocus() as required`.


You can refer to [iOS documentation](https://developer.apple.com/documentation/avfoundation/avSoundPlayer/1771734-setcategory) to understand the parameters needed for `iosSetCategory()` and to the [Android documentation](https://developer.android.com/reference/android/media/AudioFocusRequest) to understand the parameter needed for `androidAudioFocusRequest()`.

Remark : those three functions do NOT work on Android before SDK 26.

Note: these platform specific methods are under review with the intent to remove any/all platform specific elements to the api.

```dart
if (_hushOthers)
{
	if (Platform.isIOS)
		await player.iosSetCategory( t_IOS_SESSION_CATEGORY.PLAY_AND_RECORD, t_IOS_SESSION_MODE.DEFAULT, IOS_DUCK_OTHERS |  IOS_DEFAULT_TO_SPEAKER );
	else if (Platform.isAndroid)
		await player.androidAudioFocusRequest( ANDROID_AUDIOFOCUS_GAIN_TRANSIENT_MAY_DUCK );
} else
{
	if (Platform.isIOS)
		await player.iosSetCategory( t_IOS_SESSION_CATEGORY.PLAY_AND_RECORD, t_IOS_SESSION_MODE.DEFAULT, IOS_DEFAULT_TO_SPEAKER );
	else if (Platform.isAndroid)
		await player.androidAudioFocusRequest( ANDROID_AUDIOFOCUS_GAIN );
}
...
...
player.requestFocus(); // Get the audio focus
player.play(track);
// wait
player.play(track2);
player.abandonFocus(); // Release the audio focus
```

#### Seek player

When using the `SoundPlayer` you can seek to a specific position in the audio stream before or whilst playing the audio.

```dart
await player.seekTo(Duration(seconds: 1));
```


#### Setting volume.
The volume is a value between 0.0 and 1.0. 
The volume defaults to 1.0.

Note: this method is under review and may be moved to an argument on the `play` method.

```dart
/// Currently, volume can only be changed when the player is running. 
/// You must ensure that the play method has completed before calling
/// setVolume.
var player = SoundPlayer.noUI();
await player.play(fileUri);
player.setVolume(0.1);
```

#### Release the player

You MUST ensure that the player has been released when your widget is detached from the ui.
Overload your widget's `dispose()` method to release the player when your widget is disposed.
In this way you will reset the player and clean up the device resources, but the player will be no longer usable.

```dart
@override
void dispose() {
	player.release();
	super.dispose();
}
```
# Tracks
Tracks allow you to specify meta data some of which can be displayed on the OSs UI or the `SoundPlayerUI`.

```dart
// Create with the path to the audio file
Track track = new Track.fromURL("https://file-examples.com/wp-content/uploads/2017/11/file_example_MP3_700KB.mp3"); // An example audio file
track.title =  "Track Title";
track.artist: "Track Artist";
track.albumArtUrl: "https://file-examples.com/wp-content/uploads/2017/10/file_example_PNG_1MB.png", // An example image
);

// Load a local audio file and get it as a buffer
Uint8List buffer = (await rootBundle.load('samples/audio.mp3'))
    	.buffer
    	.asUint8List();
// Create with the buffer
Track track = new Track.fromBuffer(dataBuffer: buffer);
track.title =  "Track Title";
track.artist: "Track Artist";
track.albumArtUrl: "https://file-examples.com/wp-content/uploads/2017/10/file_example_PNG_1MB.png", // An example image
);
```

You can specify just one field for the Album Art to display on the lock screen. Either :
- albumArtUrl
- albumArtFile
- albumArtFile

If no Album Art field is specified, Sounds will try to display the App icon.

## Informations on a audio file

There are two utilities functions that you can use to have informations on a file.

- CodecHelper.FFmpegGetMediaInformation(_<A_file_path>_);
- CodecHelper.duration(_<A_file_path>_)

The informations got with FFmpegGetMediaInformation() are [documented here](https://pub.dev/packages/flutter_ffmpeg).
The integer returned by CodecHelper.duration() is an estimation of the number of milli-seconds for the given record.

```dart 
int duration = await CodecHelper.duration( this._path[_codec.index] );
Map<dynamic, dynamic> info = await CodecHelper.FFmpegGetMediaInformation( uri );
```

### TODO

- [x] Seeking example in `Example` project
- [x] Volume Control
- [x] Sync timing for recorder callback handler
- [ ] Enable support of third party Codecs
- [ ] Embed Codec into a to MediaFormat.


### DEBUG

When you face the following  error,

```
* What went wrong:
A problem occurred evaluating project ':app'.
> versionCode not found. Define flutter.versionCode in the local.properties file.
```

Please add below to your `example/android/local.properties` file.

```
flutter.versionName=1.0.0
flutter.versionCode=1
flutter.buildMode=debug
```

## Help Maintenance

I've been maintaining quite many repos these days and burning out slowly. If you could help me cheer up, buying me a cup of coffee will make my life really happy and get much energy out of it.
<br/>
<a href="https://www.buymeacoffee.com/bsutton" target="_blank"><img src="https://www.buymeacoffee.com/assets/img/custom_images/purple_img.png" alt="Buy Me A Coffee" style="height: auto !important;width: auto !important;" ></a>
[![Paypal](https://www.paypalobjects.com/webstatic/mktg/Logo/pp-logo-100px.png)](https://paypal.me/bsutton)
