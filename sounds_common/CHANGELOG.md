# 1.0.8
Changed default logging level from debug to info
pubspec updated with new version number

# 1.0.7
pubspec updated with new version number
Fixed issue #22 After resume track was not in correct state due to incorrect release method.
change log statements to debug rather than error.

# 1.0.7
Fixed issue #22 After resume track was not in correct state due to incorrect release method.
change log statements to debug rather than error.
released 1.0.6
Fixed a bug in the downloader. The percentage was always 0.
released 1.0.5
removed the required annotation from Track.fromAsset
released 1.0.4.
Changed Download download method to a static.
removed unnecessary code. the temp file uses a UUID so it will never be pre-existing.
made the progress argument an named optional.
exposed the Downloader class.
released 1.0.3
updated description.
Fixed a bug = not ==.
provided an example
released 1.0.2
added repository and documenation keysl
removed unused depencency.
released 1.0.1
Merge pull request #1 from bsutton/add-license-1
Create LICENSE
change Log.e to Log.d
Asserts were not being converted to disk on ios.
Fixed a bug where the mediaFormat was being ignored.
now throws an exception if the asset path is null.
removed the duration provider as its was simplier to just have each MediaFormat provide a getDuration method.
moved native media formats back into the sounds package to help with the implementatino of getDuration. The are also only usable in the sounds package because of the getDuration requirements.
exported duration_providers.
added equality operator.
Using the default codec (0) resulted in no recording so have moved back to aac.
renamed media formats to be of the form container/codec.
Replaced references to Codec with MediaFormat. Removed codec from MediaFormat as is not meaningful given the way audio mixes containers and codec in some nasty ways and often you can't define the two separately.
ignored .history
changed common to a nativemediaformat so it can be used to trigger recordings.
wip change from Codec to MediaFormat and extracting sounds_codec.
wip
wip
First commit

# 1.0.7
Fixed issue #22 After resume track was not in correct state due to incorrect release method.
change log statements to debug rather than error.
# 1.0.6
Fixed a bug in the downloader. The percentage was always 0.

# 1.0.5
removed the required annotation from Track.fromAsset

# 1.0.4
Exposed the Downloader class as part of the public api.
# 1.0.3
Minor cleanup of warnings to make pub.dev happy.
One minor bug detected in currently unused code.
# 1.0.2
updated documenation links.
# 1.0.1

First working version.
Contains a completed version using MediaFormat.
## 1.0.0

- Initial version, created by Stagehand
