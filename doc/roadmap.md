# Roadmap

## Overview

This document is intended to provide a road map for the development of `Sounds`.

`Sounds` is intended to provide a comprehensive audio system for the recording and playback of audio in a Flutter application.

The `Sounds` project provides two distinct layers

* API
* Widgets

The API provides a high level interface for controlling audio playback and recording.

The Widgets provide out of the box solutions to audio playback and recording. The Widgets are intended to be high quality widgets in their own right but are built on top of the API to provide examples of how a user might go about building their own widgets.

## Near term goals

### Stabilise the API

The API is intended to provide a complete and simple api for audio playback and recording.

The API now needs to be reviewed by the community in order to include any feed back/improvements before we create a fixed 1.0 version of the api.

~~Remove FFMpeg and codec conversion into a separate package to reduce bloat in the core package and make codec conversion an optional inclusion.~~ Done

### Under review

~~The main area of concern with the API is the use of Codecs. The current Codec enum describes both a codec and a container.~~ Done

~~The issue~~ [~~Wrap Codec in a MediaFormat~~](https://github.com/bsutton/sounds/issues/5) ~~describes a solution that clearly defines the Codec and Container and allows us to specifiy other details relating to the Media Format such as channels and bit rate.~~ Done

Using a MediaFormat also opens the way for [Re-architect codec support into separate packages](https://github.com/bsutton/sounds/issues/3) as it will allow us to fully describe the media format when doing codec translation. The [sounds\_codec](https://github.com/bsutton/sounds_codec) project has been started to host this code.

We need to review and make decision on.

* Audio focus
* iosSetCategory

### Improvements to the standard Widgets

Currently the included widgets are visually a little clunky \(particularly the recording widget\). Work needs to be done to improve the aesthetics of these widgets and allow a user to customise the look of these widgets to some extent.

### Unit Tests

To ensure the long term stability of the Sounds package we need to have a strong set of Unit Tests that provides good code coverage and allows us to ensure that each package is stable before we release it.

### Release

Release a stable 1.0 version.

## Mid Term goals

### Split MediaFormat trans coding into a separate package

~~The current project has both a light and a heavy flavor which supports a small or broader set of components via the ffmpeg library.~~ Done

The issue [Re-architect codec support into separate packages](https://github.com/bsutton/sounds/issues/3) describes a plan to move MediaFormat support into separate packages that will allow users to pick and choose which MediaFormat they need to support in their application.

This will allow users to minimise the size of their application.

It will also allow third parties to add support for additional MediaFormat.

The [sounds\_codec](https://github.com/bsutton/sounds_codec) hosts this work.

## Long Term goals

Possible ideas:

Support for Streaming  


