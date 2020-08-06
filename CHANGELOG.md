# 1.0.0-beta.6
Fixed #22
Updated to latest version of pubspec package.
add missing codec
Added missing 'result' call in the shadeplayer init.
added missing lazy initialization of slots for the shade player.

# 1.0.0-beta.5
added button to test playing remote url via shade.
rebuild without the build.gradle hacks to try and get around the missing .packages error.

# 1.0.0-beta.4
added button to test playing remote url via shade.
released 1.0 beta4
Upgraded to sounds_common 1.0.6 to fix a bug in the percentage complete in the SoundPlayerUI. It was always reporting 0percent complete even when progressing.
released 1.0.0.beta3

# 1.0.0-beta.4
released 1.0 beta4
Upgraded to sounds_common 1.0.6 to fix a bug in the percentage complete in the SoundPlayerUI. It was always reporting 0percent complete even when progressing.
released 1.0.0.beta3

# 1.0.0-beta.4
Upgraded to sounds_common 1.0.6 to fix a bug in the percentage complete in the SoundPlayerUI. It was always reporting 0percent complete even when progressing.
released 1.0.0.beta3

# 1.0.0-beta.3
Added a test to the demo app to play via the shade.
Fixed a bug where the shadeStatus was being sent as a double when an int was expected.
SoundPlayer: removed code left over from when we had a fixed frequency coming up from the OS. Change the dispostionStream method to not take an interval and exposed the setProgressInterval so it can be directly modified.
Fixed doco for onStopped. missing wasUser arg.
Fixed a bug with the channel name of the shade player.

# 1.0.0-beta.2
upgraded to sounds_common 1.0.4
removed notes on the mimum support interval for progress messages as there is no longer a minimum.
Exposed the convenience Downloader class.


# 1.0.0-beta.1
First beta release.
Demo app is working nicely on both android and ios.
All api changes intended for 1.0.0 are now complete including stripping out ffmpeg and moving from Codec to MediaFormat.
Fixed the iOS Db calculations to match android.
Added hacks for flutter issue #19830
added dart-code recommended settings.
added repository and documenation keysl
Update README.md
renamed flauto to sound
refactored getDuration as its not really part of the SoundPlayer as it can work without having to initialise a player. I've placed it in the plugin for the moment as nowhere better to place it really.
sound_player_ui no requires that the Track has a MediaFormat as we need to get the duration.
removed temp_file as it duplicates functionality in FileUtil.
only check the mediaformat for support if it is passed other wise let the OS throw the error.
exported native media formats.
Forced recording track to use a NativeMediaFormat.
renamed SoundPlayer ctor withUI to withShadeUI
renamed startPlayerFromTrack to startShadePlayer. Also seperated out classes into their own files.
removed old demos and renamed existing ones.
updated iOS platform to 10.
added the required _Null declarations in iOS code.
renamed media formats to be of the form container/codec.
Fixes for // See https://github.com/flutter/flutter/issues/19830
# 0.9.2
Updated doco links
committed hacks to work around flutter build bug.
# 0.9.1
Fixed a compile error due to a bad import.
# 0.9.0

This release includes some major changes to the api and the removal of FFMPEG resulting in a significantly small build size.

This release includes #10 #5 and parts of #3.

All api calls which used a Codec now use a MediaFormat.
When playing audio a MediaFormat is no longer required unless you need to obtain the duration.

The platform code for obtaining a duration has bee changed from using ffmpeg to using the platform native methods.

Sounds now only supports playback and recording of native media formats.
The sounds_codec package ( a work in progress ) has been created to provide utility methods for converting media formats. The idea being that if you want to play an non-native audio file that you first convert it to a native format and the play it using sounds. The same goes for recording. Record to a native format and then uses sounds_codec to convert the audio to the desired format.

It is expected that this release will be very close to the 1.0 release api as no major changes are now planned only bug fixes.
# 0.8.9
Removed the ext_storage package as its no longer used.
# 0.8.8
# 0.8.8
### 0.8.7
Continuing work on the doco.

### 0.8.6
continuing improvements to the doco.
added _nullable to the pointer as required by the latest version of xcode.
Fixed error no visible @interface for 'FFmpegPlugin' declares the selector 'alloc'. As the var name was the same case as the type.

### 0.8.5
Fixed compile error on Recase.

### 0.8.4
Fixed the wiki links.

### 0.8.3
doco
renamed playbackEnabled to enablePlayback
setup imags directory for wiki.
revered to old logger for compatability
removed recase as was conflicting without projects for one line of code.
cancel is a method not a getter.

### 0.8.2
Fixed additonal lints and fixed a bug in the downloader not closing a subscription.

## 0.8.1 
Essentially cleanup of lints formatting. 
First pass at cleanup of readme.
Some initial cleanup of doco.
Customised the logo.
rough pass at forking flutter sound.

# 0.8.0
Rough draft of fork.

