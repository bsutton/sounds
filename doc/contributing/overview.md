# Overview

## Overview

`Sounds` is a big project and we need all of the help we can get.

So how can you get involved?

## Objective

The objective of the `Sounds` project is to provide audio playback and recording on iOS and Android within the Flutter framework.

`Sounds` aims to deliver a simple to use but complete API as well as a set of 'ready to use' Widgets.

A key objective of `Sounds` is to provide an OS agnostic API. That is, the intent is to avoid OS specific features exposed via the UI. A developer should be able to use the `Sounds` tooling without consideration as to the OS they are running on.

## Documentation

Any project is only as good as its documentation.

A key objective of `Sounds` is to provide quality documentation which makes it easy for both experienced and novices users to use the `Sounds` package.

## Community

Development is to be done as a collaborative approach to problem solving.

New ideas should be started by raising an issue to give the community a chance to discuss the pros and cons of the proposed change.

The community should be supportive of all contributors and users and negative language will not be tolerated.

### Coding Standards

The dart code base will adhere the 'effective dart' lint rules.

Standards will be defined for the Java and Objective-C code bases as we move forward.

Code MUST be free of errors and warnings before it will be accepted.

All code must be formatting using the standard dartfmt tool before it is submitted.

Code MUST be well commented.

All public API's must include examples code in the comments.

Careful consideration is to be given to what methods/class are exposed as part of the public api. The objective is to expose the smallest API possible.

Abbreviations in variable, method and class names should be avoided.

The code should attempt to adhere to conventions that are recognisable to the broader Flutter community and any recommended by the Google Flutter team.

## Minimise included packages

Dart suffers from dll hell \(where different package version from different dependencies conflict\). To avoid being a source of dll hell we should aim to include the minimal set of package dependencies possible. We will have to balance this requirement with effort and long term maintenance issues.

ReCase is a good example. In reviewing the code base I found we had only used 3-4 lines of code from the package. So I copied those lines into our own class. Minimal maintenance will be required and we have eliminated usage of a popular package.

## Prefer dart over Java or Objective-C

Note: we are in the process of migrating code to Swift.

If functionality can be implemented in Dart then it should be implemented in Dart.

Any code written in Java or Objective-C takes twice as much labour to support and debugging in these environments is still less than ideal on the Flutter platform.

## Unit Tests

Currently `Sounds` has no unit tests. This is an issue that we will need to remedy sooner rather than later. In the early stages of the project we will be lenient on code submitted without unit tests but as we move forward there will be an expectation for all code be submitted with unit tests.

