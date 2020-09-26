# SoundPlayer

## Overview

The `SoundPlayer` class provide an API for playing audio.

The `SoundPlayer` provides detailed control over audio playback \(pause/resume/seek\) including monitoring playback progress.

The `SoundPlayer` operates in one of two modes:

| Type | Constructor | Description |
| :--- | :--- | :--- |
| Headless | SoundPlayer.noUI\(\) | audio is played back with no UI. You need to build your own UI to control playback. |
| OS Shade | SoundPlayer.withShadeUI\(\) | the OS' built in media player \(often referred to as the Shade or Notification Area\) is displayed allowing audio playback to be controlled. Using the Shade allows the user to control the audio even if their phone is locked. |

A `SoundPlayer` can be reused to play multiple audio tracks. This is particularly useful if you are using the `SoundPlayer.withShadeUI()` constructor as it means you can transition from one `Track` to the next track without the OS' media player 'flickering' as you change tracks.

### Alternatives

If you simply want to play an audio file from start to end without any controls \(e.g. play a beep\) the you should consider using [QuickPlay](quickplay.md).

If you need a Widget to allow the user to control playback then use [SoundPlayerUI.noUI\(\)](soundplayerui.md).

If you need to play audio and allow the user to control the audio via the OS' Shade \(the OS' built in audio player\) then use `SoundPlayerUI.withShadeUI()`.

## Supported Media

`Sounds` only support audio media formats \(codec\) that the OS supports natively. If you need to play audio from a non-native source then you need to trans-code the media first.

See [MediaFormat](mediaformat.md) for additional details on supported formats.

## Headless Playback \(no UI\)

The `SoundPlayer` uses the `Track` class as the source of audio.

To playback a headless `Track` \(i.e. without a UI\)

```dart
var track = Track.fromAsset('assets/billyrock.acc');
var player = SoundPlayer.noUI();
player.onStopped = ({wasUser}) => player.release();
player.play(track);
```

Its important to call `player.release()` when you have finished with the playback otherwise you can leave the playback hardware locked and unavailable to other apps.

## OS Shade \(using the OS' media UI\)

Both Android and iOS allow you to play audio via OS' own media player.

The OS media player is displayed on the lock screen and/or the notification area sometimes referred to as a Shade.

`Sounds` allows you to play a Track using the OS' Shade.

```dart
var player = SoundPlayer.withShadeUI();
player.onStopped = ({wasUser}) => player.release();
player.play(Track.fromFile('sample.blit'));
```

```dart
var player = SoundPlayer.withShadeUI();
player.onStopped = ({wasUser}) => player.release();
player.play(Track.fromFile('sample.blit'));
```

### Avoiding flicker

When using the OS' Media Player \(via `SoundPlayer.withShadeUI()`\) and you transition between tracks make certain you use the same instance of the `SoundPlayer`.

If you create a new instance of the `SoundPlayer` for each track then the OS' Media Player will flicker between tracks.

In this case you won't want to call `player.release()` when the track stops playing. Rather you need to track the player yourself and call release once you have stopped playing tracks.

This will often mean that you should call `player.release()` in your widgets `dispose()` method.

```dart
SoundPlayer player;

@override
void initState()
{
    super.initState();
    player = SoundPlayer.withShadeUI();
    // called when the user taps the skip forward button on the OS' Media Player
    player.onSkipForward = onSkipForward;
}

/// some 
void onSkipForward()
{
   var track = getNextTrack();
    player.play(track);
}

@override
void dispose()
{
    player.release();
    super.dispose();
}
```

### Play in background

If you use the OS' Shade then you can instruct Sounds to play the audio in the background.

Normally when playing audio, if your application is switched to the background then your audio will stop. If you pass the playInBackground flag then your audio will continue playing even whilst your app is in the background.

```dart
var player = SoundPlayer.withShadeUI(playInBackground:true);
player.onStopped = ({wasUser}) => player.release();
player.play(Track.fromFile('sample.blit'));
```

### Control the OSs' UI

The OSs' media player has three buttons, skip forward, skip backwards and pause. By default the skip buttons are disabled and the pause button enabled.

You can modify the the state of these buttons with the `SoundPlayer.withShadeUI` constructor.

```dart
var player = SoundPlayer.withShadeUI(canPause:true, canSkipBackward:false
	, canSkipForward: true);
player.onStopped =  ({wasUser}) => player.release();
player.play(Track.fromFile('sample.blit'));
```

### Display artist details

You can also have the OS' audio player display the artist details by specifying properties on a `Track`.

```dart
var track = Track.fromFile('sample.aac');
track.title = 'Reckless';
track.artist = 'Sounds';
track.albumArtUrl = 'http://some image url';

var player = SoundPlayer.withShadeUI()
player.onStopped = ({wasUser}) => player.release();
player.fromTrack(track);
```

The title, artist and album art will be displayed on the OSs' Audio Player.

## Focus

`Sounds` allows you to control the `Audio Focus` during playback.

Audio Focus allows you to control how your playback interacts with any other app which is also doing playback.

The app that currently has the 'Audio Focus' is considered to be the primary audio which normally equates to 'this one should be the loudest'. The different focus modes dictate how the volume of any other audio being played will be affected.

AudioFocus supports the following Modes:

| Mode | Description |
| :--- | :--- |
| focusAndKeepOthers | request focus and allow other audio to continue playing at their current volume. |
| focusAndStopOthers | request focus and stop other audio playing |
| focusAndHushOthers | request focus and reduce the volume of other players. In the Android world this is know as 'Duck Others' \(but that is a really stupid name :\). |
| abandonFocus | relinquish the audio focus. If another app takes the focus we will now be treated as the 'other' app. |

Each of the `Sounds` media players will automatically request the focus using `AudioFocus.focusAndHushOthers`.

You can explicitly request and abandon focus as you play audio:

```dart
player.requestFocus(); // Get the audio focus
player.play(track);
// wait
player.play(track2);
player.abandonFocus(); // Release the audio focus
```

## Seek player

When using the `SoundPlayer` you can seek to a specific position in the audio stream before or whilst playing the audio.

```dart
await player.seekTo(Duration(seconds: 1));
```

## Setting volume.

The volume is a value between 0.0 and 1.0. The volume defaults to 1.0.

Note: this method is under review and may be moved to an argument on the `play` method. Currently, volume can only be changed when the player is running. You must ensure that the play method has completed before calling setVolume.

```dart
var player = SoundPlayer.noUI();
await player.play(fileUri);
player.setVolume(0.1);
```

## Monitoring

Sounds uses Dart streams to allow you to monitor both recording and playback progress.

If you are playing from a URL \(`Track.fromURL`\) then the progress will also reflect the download progress.

The `PlaybackDisposition` class contains the following fields:

* state - indicates the playback state.
* progress - when the `state` is `loading` indicates the loading progress using a value from 0.0 to 1.0. 1.0 indicating that loading has completed. When loading from a URL source we may not be able to show progress in which case the value will remain at 0.0 for the entire download. At the end of the download the progress will be set to 1.0.
* position - when state is `playing` then indicates the playback position as a time offset from the start of the audio.
* duration - the duration of the audio. Reflects the duration of the audio being played.

You can use a [StreamBuilder](https://api.flutter.dev/flutter/widgets/StreamBuilder-class.html) which will greatly simplify the construction of UI components \(or you can use one of the new Sounds UI widgets\).

To obtain a subscription to the `SoundPlayer` stream:

```dart
var Stream<PlaybackDisposition> = SoundPlayer.noUI().dispositionStream(interval);
```

The result is a stream of `PlaybackDisposition`s which includes both the audio's duration \(length\) and current position.

## Race Conditions

It is common when directly controlling playback to encounter race conditions.

An example of a race conditions is attempting to stop the player just as the track naturally ends.

You should be prepared to handle the state related errors whenever you try to change the state of playback \(e.g. pause/resume/stop\).

Some of the causes of Race Conditions.

* Track naturally ends as you attempt to stop or pause the audio.
* User changes the playback state via the Shade \(when it is enabled\).
* The Application pauses causing audio playback to stop.

## System pauses

`Sounds` aims to be a good citizen and play nicely with other media players. To this end `Sounds` listens to OS application pause/resume events. This essentially means that if you application is sent to the background then `Sounds` will stop playback and release any audio resources that it is holding.

When you app is brought back to the foreground `Sounds` will automatically resume playback from where the audio left off.

## Cleanup

Once you have finished using the `SoundPlayer` you MUST call the `release` method to release any audio resources held by the player.

You MUST also ensure that the player has been released when your widget is detached from the ui.

You will often do this in a widgets dispose method:

```dart
@override
void dispose() {
	player.release();
	super.dispose();
}
```

