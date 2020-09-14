# Migrating from Flutter Sound

## Migration from Flutter Sound to Sounds

Sounds was originally a fork of the Flutter Sounds project however there is very little code left from the original Flutter Sounds project.

The following guide provides some general advice on migrating your project from Flutter Sound to Sounds.

### Playback

In the Sounds package the `ShadePlayer` and `FlutterSoundPlayer` have been deprecated in favour of a single class `SoundPlayer`.

`SoundPlayer` now has two constructors:

Code that previously used `TrackPlayer` should now call the `SoundPlayer.withShadeUI()` constructor.

Code that used the `FlutterSoundPlayer` should now call the `SoundPlayer.noUI()` constructor.

The equivalent method names on the `FlutterSoundPlayer` class have also been shortened.

Example changes:

`FlutterSoundPlayer.startPlayer()` -&gt; `SoundPlayer.play()` 

`FlutterSoundPlayer.pausePlayer()` -&gt; `SoundPlayer.pause()` 

`FlutterSoundPlayer.stopPlayer()` -&gt; `SoundPlayer.stop()`

The new `play` methods replaces both `startPlayer(uri)` and `startPlayerFromBuffer()` and now takes a `Track`.

### subscription

In the `Sounds` the original `SoundPlayer` subscription model is now been unified into a single stream via:

```text
var Stream<PlaybackDisposition> = SoundPlayer.noUI().dispositionStream(interval);
```

The result is a stream of `PlaybackDisposition`s which includes both the audio's duration \(length\) and current position.

### Recording

The `FlutterSoundRecorder` has been replaced with `SoundRecorder`. Changes to the recorder a similar to the changes made to the player.

### Types

Types and enums now consistently use camelCase.

e.g. `t_PLAYER_STATE.IS_STOPPED -> PlayerState.isStopped`

