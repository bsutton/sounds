# Building

## Overview

Note: as of June/2020 the flutter gradle build tools still require Java 8 and will NOT work with Java 11.

Sounds contains plugins for both iOS and Android in order to implement core features.

As such you need access to both an iOS and an Android build environment.

## Git Clone

Clone the three `Sounds` related projects under a common root directory:

```text
mkdir dev
cd dev
git clone git@github.com:bsutton/sounds.git
git clone git@github.com:bsutton/sounds_common.git

# optional, only required if you need to work on codec conversions.
git clone git@github.com:bsutton/sounds_codec.git
```

If you want to locally edit the wiki then you can clone it as well.

```text
git clone git@github.com:bsutton/sounds.wiki.git
```

## Common configuration

You MUST define FLUTTER\_ROOT:

```text
export FLUTTER_ROOT=/home/bsutton/apps/flutter
```

You will also need to create a `local.properties` file in your `sounds\android` directory with content similar to: \(Adjust the paths to match your system.\)

`sounds\android\local.properties`

```text
sdk.dir=/home/bsutton/Android/Sdk
flutter.sdk=/home/bsutton/apps/flutter
flutter.buildMode=debug
flutter.versionCode=1
```

And for your example create:

`sounds\example\android\local.properties`

```text
sdk.dir=/home/bsutton/Android/Sdk
flutter.sdk=/home/bsutton/apps/flutter
flutter.buildMode=debug
flutter.versionCode=1
```

If you are going to build `sounds_codec` then you will need the above `local.properties` files under the `sounds_codec` directory. The `sounds_common` project does NOT require these paths as it does not have any platform specific code.

## Visual Code

When I'm working purely on the Dart code in Sounds I prefer to use Visual Code.

You will need to install the dart-code extension and the Flutter extension.

## Android Studio

If you need to edit/debug the Java Code then Android Studio is required \(Visual Code's Java dev cycle is still crap at this point\).

### Install the Flutter Plugin

Open 'File \| Settings' Find the Plugins entry and the select Flutter from the Marketplace and install it.

### Import Sounds

Import `Sounds` into Android Studio using these [instructions](https://medium.com/codespace69/how-to-import-existing-flutter-project-in-android-studio-aa9d9e5c77b)

### Building with Android Studio

#### Initialise the project

Before opening `sounds` or `sounds_codec` in Android Studio you MUST first build the example app from the cli.

```text
cd sounds\example
flutter build apk
cd sounds_codec\example
flutter build apk
```

You can now import the project into Android Studio.

After importing `Sounds` into Android Studio you need to ensure the top level 'sounds' directory is selected in your Project view.

To build the `Sounds` Java Code:

Find the `android` directory in the `Sounds` project tree in the IDE.

Right click the `android` directory and select

\`Flutter \| Open Android Module in Android Studio'

Wait for Android Studio to sync the Gradle settings. This can take a while.

Once complete select

Build \| Make Project

If the `Make Project` setting is still disabled then the gradle sync probably hasn't finished.

## osx

Tools

* java - I used brew to install java.
* xcode - install from the app store.

Once you have installed xcode run:

```text
flutter doctor -v
```

Then following the instructions for Xcode to complete xcodes configuration.

Now install cocoapods:

{% embed url="https://guides.cocoapods.org/using/getting-started.html" %}

I had trouble after installing cocoapods and had to follow these instructions to install the ruby build tools

[https://stackoverflow.com/questions/53135863/macos-mojave-ruby-config-h-file-not-found](https://stackoverflow.com/questions/53135863/macos-mojave-ruby-config-h-file-not-found)

Run

```text
cd sounds\example
flutter build ios --no-codesign
```

Now import the project into xcode and build.

