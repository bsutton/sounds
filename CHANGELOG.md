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

