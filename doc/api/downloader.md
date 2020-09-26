# Downloader

## Overview

The `Downloader` class is used internally and provided to users as a convenient mechanism for pre-caching audio located at a URL.

Detailed Downloader API documentation can be found on [pub.dev](https://pub.dev/documentation/sounds/latest/sounds/sounds-library.html).

The `Downloader` class can actually be used to download any resource.

The `Downloader` class downloads the URL and saves it into a local file.

It is your responsibility to delete the local file once you have finished with it.

```dart
var saveToFile = TempMediaFile().empty();

await Downloader.download('https://some/path/rock.aac', saveToFile);

var track = Track.fromPath(saveToFile);
...
FileUtil().delete(saveToFile);
```

You can also obtain download progress information.

```dart
var saveToFile = TempMediaFile().empty();

await Downloader.download('https://some/path/rock.aac', saveToFile, progress:   (disposition) {
        print('progress ${disposition.state}, ${disposition.progress}';
    });
```

