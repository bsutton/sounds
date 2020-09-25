# Beep, Beep

A common use case for Sounds is to play simple audio files such as a beep.

The best way to play these short audio files is to use the [Quickplay](../api/quickplay.md) API.

The Quickplay API simply allows you to trigger the playback of a audio Track. There is no UI involved and resource cleanup is automatic.

We recommend that you ship your short audio files as Flutter assets and load the asset using the `Track.fromAsset` method.

You should also read the section on [caching](../api/caching.md) as you may want to cache the tracks to reduce lag between the user clicking a button and the audio playing.

