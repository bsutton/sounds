# Short Sounds

A common use case for Sounds is to play short audio files such as a beep.

The best way to play these short audio files is to use the [QuickPlay](../api/quickplay.md) API.

The QuickPlay API simply allows you to trigger the playback of a audio Track. There is no UI involved and resource cleanup is automatic.

```text
QuickPlay.fromAsset('assets/beep.wav', volume: 1.0);
```

We recommend that you ship your short audio files as Flutter assets and load the asset using the`QuickPlay.fromAsset` or `Track.fromAsset` methods.

You should also read the section on [caching](caching.md) as you may want to cache the track to reduce lag between the user clicking a button and the audio playing.

```text

var track = Track.fromAsset('assets/beep.wav', autoRelease=false);

/// beep
QuickPlay.fromTrack(track, volume: 0.5);

/// beep again using the same track
QuickPlay.fromTrack(track, volume: 0.5);

/// we are done with beeping.
track.release();
```

In this example we use the `autoRelease`flag to stop Sounds automatically releasing resources after the Track finishes playing.

Because we set `autoRelease=false` when loading the Track, we are now responsible for calling `Track.release()` to clean up any resources associated with the Track. 

For small audio files it is quite reasonable to cache the Track \(i.e. don't call release\) for extended periods of time.

Being a good citizen you should probably free any cached resources if your app gets paused.

