# iOS

## Overview

Once you have added the `Sounds` dependency to you pubspec.yaml you need to modify your iOS `info.plist` file.

You need to set an appropriate message for the `NSMicrophoneUsageDescription` field.

```text
<key>NSMicrophoneUsageDescription</key>
  <string>My app uses the microphone to record your speech and convert it to text.</string>
<key>UIBackgroundModes</key>
<array>
	<string>audio</string>
</array>
```

