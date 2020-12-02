# Android



## Overview

Once you have added the `Sounds` dependency to you pubspec.yaml you need to modify your Android `AndroidManifest.xml` file.

Added the following permissions to `AndroidManifest.xml`:

```text
<uses-permission android:name="android.permission.RECORD_AUDIO" />
<uses-permission android:name="android.permission.FOREGROUND_SERVICE" />
```

## MediaFormats

For a complete list of Audio Codecs supported on Android [https://developer.android.com/guide/topics/media/media-formats](https://developer.android.com/guide/topics/media/media-formats)

