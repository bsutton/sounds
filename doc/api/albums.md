# Albums

## Overview

Sounds supports the concept of Albums which are, as you would expect, a collection of `Track`s which can be played in order.

The `Album` uses the OSs Media Player \(Shade\) to display the tracks as they are played.

A user can use the skip back, forward and pause buttons to navigate the album.

### Playing an Album

If you want to play a collection of tracks then you can create an Album with a static set of Tracks or a virtual set of Tracks.

#### Play album with static set of Tracks

```dart
var album = Album.fromTracks([
    Track.fromFile('sample.acc'),
    Track.fromURL('http://fqdn/sample.mp3'),
]);
player.onStopped = ({wasUser}) => player.release();
album.play();
```

By default an Ablum displays the OSs' audio UI \(Shade\). You can suppress the UI via by passing in `SoundPlayer.noUI()` to the Album in which case the `Tracks` will be played sequentially until they complete. \(I'm not certain this is actually useful\).

```dart
var album = Album.fromTracks([
    Track.fromFile('sample.acc'),
    Track.fromURL('http://fqdn/sample.mp3'),
]
, session: SoundPlayer.noUI());
player.onStopped = ({wasUser}) => player.release();
album.play();
```

#### Play album with a virtual set of Tracks

Virtual tracks allow you to create an album of infinite size which could be useful if you are pulling audio from an external source.

If you create a virtual album you MUST implement the `onSkipForward` , `onSkipBackwards` and `onFirstTrack` methods to supply the album with Tracks on demand.

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

### Controlling Playback

The `SoundPlayer` provides fined grained control over how the audio is played as well as been able to monitor playback and respond to user events.

Importantly `SoundPlayer` also allows you to play multiple audio files using the same session.

Maintaining the same session is important if you are using the OSs' audio UI for user control. If you don't use a single `SoundPlayer` then the user will experience flicker between tracks as the OSs' audio player is destroyed and recreated between each track.

The `Album` class provides an easy to use method of utilising a single session without the complications of an `SoundPlayer`.

```dart
var player = SoundPlayer.withShadeUI();

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

