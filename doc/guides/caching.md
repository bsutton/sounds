# Caching

If you repeatedly need to play a sound \(such as a beep\) you may want to cache the audio.

The simplest way to cache audio is to cache a [Track](../api/track.md) object which can be re-used as many times as necessary.

When creating a [Track](../api/track.md) set the `autoRelease` argument to false.

```text
var track = Track.fromFile('path/to/audio', autoRelease=false);
...
track.release();
```

By default `autoRelease` is set to true and Sounds manages the Track resources for you.

If you set `autoRelease` to `false` you MUST call `Track.release` when you no longer need the Track.

You may re-use the Track any number of times and you only need to call `Track.release` once.

You may re-use the Track after calling `Track.release` but you must once again call `Track.release.`

