# Debugging

## Overview

When you face the following error,

```text
* What went wrong:
A problem occurred evaluating project ':app'.
> versionCode not found. Define flutter.versionCode in the local.properties file.
```

Please add below to your `example/android/local.properties` file.

```text
flutter.versionName=1.0.0
flutter.versionCode=1
flutter.buildMode=debug
```

