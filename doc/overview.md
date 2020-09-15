# Overview

The API is split into two categories:

* Low level API
* Widgets

Detailed API documentation is available on [pub.dev](https://pub.dev/packages/sounds).

The Low level API provides detailed but simple control over audio playback and recording.

Sounds ships with two Widgets and a Widget Controller:

* SoundPlayerUI
* SoundRecorderUI

The Widget Controller provides a class that links a SoundPlayerUI widget to a SoundRecorderUI widget and coordinates the widgets so they can be used to together allowing the user to record and review their recording from a single interface.

The provided Widgets have been written using the Low Level API and as such provide a source of sample code if you need to write your own custom widgets.

## Getting Started

If you just need to go 'beep' then start with [QuickPlay](quickplay.md).

If you want to give the user direct control over audio playback then use the [SoundPlayerUI](soundplayerui.md).

Use the [SoundRecorderUI](soundrecorderui.md) to give the user a standard interface for recording. 

If you want allow the user to control the audio via the phones notification area \(shade\) then use [SoundPlayer.withShade](soundplayer.md#os-shade-using-the-os-media-ui).

If you need to be able to programmatically control playback \(start/stop/resume\) then us [SoundPlayer.noUI](soundplayer.md#headless-playback-no-ui).

