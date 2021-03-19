# Quickplay

## Overview

QuickPlay provides the simplest method to play audio.

QuickPlay is ideal for playing short sounds but can play audio of any duration.

QuickPlay does not provide a UI and will play the audio from start to end.

You have no control over the audio once it starts but you don't have to do any cleanup once it completes.

QuickPlay supports playback from any type of Track as well as directly from a number of common sources.

| Source | Constructor |
| :--- | :--- |
| Asset from a Track | QuickPlay.fromTrack\(Track.fromAsset\(\)\) |
| Buffer from a Track | QuickPlay.fromTrack\(Track.fromBuffer\(\)\) |
| File from a Track | QuickPlay.fromTrack\(Track.fromFile\(\)\) |
| URL from a Track | QuickPlay.fromTrack\(Track.fromFile\(\)\) |
| File | QuickPlay.fromFile\(\) |
| URL | QuickPlay.fromURL\(\) |
| Buffer | QuickPlay.fromBuffer\(\) |

## Supported MediaFormats

You can only play from a source which contains a natively supported `MediaFormat`.

You can get a list of natively supported media formats for the devices OS and SDK level by calling `NativeMediaFormats.decoders`.

### MediaFormatException

If you try to play audio with a unsupported `MediaFormat` then a `MediaFormatException` will be thrown.

### Play an asset

```dart
var track = Track.fromAsset('assets/rock.wav');
QuickPlay.fromTrack(track);

QuickPlay.fromAsset('beep.aac', volume: 0.5);
QuickPlay.fromTrack(Track.fromAsset('assets/ring.aac'), volume: 0.5);
```

### Set the volume.

You can set the volume of playback.

The volume must be a value between 0.0 and 1.0 \(11 will not work\).

The default volume is 0.5.

```dart
var track = Track.fromAsset('assets/rock.wav');
QuickPlay.fromTrack(track, volume: 1.0);
```

### Play from an audio file

```dart
var track = Track.fromFile('/some/path/on/your/phone/rock.wav');
QuickPlay.fromTrack(track);

Quickplay.fromFile('/some/path/on/your/phone/rock.wav', volume: 0.8);
```

### Play from a URL

When playing from a URL `Sounds` will download the complete file before it starts playback. If you want better control over the playback then consider downloading the resource first or use the `SoundPlayerUI` widget.

```dart
var track = Track.fromURL('https://web.address/rock.wav');
QuickPlay.fromTrack(track, volume: 0.2);

QuickPlayer.fromURL('https://web.address/rock.wav');
```

## onStopped

If you need a notification when `QuickPlay` completes then you can register a callback via the `onStopped` property.

```dart
var track = Track.fromAsset('assets/rock.wav');

var quickPlayer = QuickPlay.fromTrack(track, volume: 1.0);
quickPlayer.onStopped(({wasUser}) => print('playback has ended'));
```

