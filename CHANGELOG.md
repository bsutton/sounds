# 1.0.0-beta.11
Updated comments to avoid confusion regarding dispositions streams

# 1.0.0-beta.10
Added example of setting logging level for application

# 1.0.0-beta.9
Merge branch 'master' of https://github.com/bsutton/sounds into master
Fixed #26 by adding conditional to _onSystemPause and _onSystemResume
Create FUNDING.yml
released beta.8
Merge branch 'master' of github.com:bsutton/sounds
Fixed a bug in the stop() method. It was not calling the _plugin.stop method.
no longer used.
updated pubspec version
released 1.0 beta7
updated to latest pubspec package api.
updated to reflect api changes.
Added additional logging.
minor cleanup.
1.0.0-beta.6 release
released 1.0.0.-beta.6
Changed  the onStopped  from a setter to a ctor argument as there was a risk that it wouldn't be called. Also removed the 'wasUser' as a QuickPlay can't be stopped by a user.
Updated to latest version of pubspec package.
add missing codec
Added missing 'result' call in the shadeplayer init.
added missing lazy initialization of slots for the shade player.
Merge branch 'master' of github.com:bsutton/sounds
released beta 5
added button to test playing remote url via shade.
added button to test playing remote url via shade.
released 1.0 beta4
Upgraded to sounds_common 1.0.6 to fix a bug in the percentage complete in the SoundPlayerUI. It was always reporting 0percent complete even when progressing.
released 1.0.0.beta3
Added a test to play via the shade.
Fixed a bug where the shadeStatus was being sent as a double when an int was expected.
SoundPlayer: removed code left over from when we had a fixed frequency coming up from the OS. Change the dispostionStream method to not take an interval and exposed the setProgressInterval so it can be directly modified.
Fixed doco for onStopped. missing wasUser arg.
Fixed a bug with the channel name of the shade player.
released beta 2.
removed as its not used.
upgraded to sounds_common 1.0.4
removed notes on the mimum support interval as there is no longer a minimum.
Exposed the convenience Downloader class.
released beta 1.0
upgraded to using sounds_common 1.0.3
Merge branch 'master' of github.com:bsutton/sounds
added logging
added a log message.
set default interval to 0.8 and fixed a bug converting from millseconds to seconds.
added login to progress indicator.c changed 1000 to 1000.0.
reformatted code using the standard vscode java settings which will be used as the standard going forward :<
reformatted by the vscode java plugin. renamed updateRecorderProgress to updateProgress. Added loging to start/stop tim.er
Merge branch 'master' of github.com:bsutton/sounds
changed current position to string to match android/ios/dart code.
changed current_position to a string to match the dart code expectations
syntax fixes after the progress refactoring
refactored code to have a single 'progress' message when recording that contains both the db level and the duration.
added log10 test
Fixed the db amplitude messags where were stuck on 100%'
Merge branch 'master' of github.com:bsutton/sounds
Fixed the db calculations. Now matches the java code.
simplified the non-zero check.
added loggin for updateProgress.
fixed incorrect arg name
had to pass slot and the callback signature was incorrect.
formatting.
Moved getDuration into SoundPlayerManager as it can be called before a SoundPlayer is created.
released 0.9.2
Merge branch 'master' of github.com:bsutton/sounds
Added hacks for flutter issue #19830
added dart-code recommended settings.
added repository and documenation keysl
Update README.md
released 0.9.1
released 0.9.0.
added missing import.
removed unnecessary logsl.
Merge branch 'master' of github.com:bsutton/sounds
corrected channel name
fixed npe with format arg
added support for lazy initialisation of slots.
renamed flauto to sound
Merge branch 'master' of github.com:bsutton/sounds
incorrect channel name.
fixed syntax errors
Merge branch 'master' of github.com:bsutton/sounds
fixed syntax errors
added missing declaration.
Merge branch 'master' of github.com:bsutton/sounds
change the milliseconds to an int to match the java code.
bug uuid  was just 'instance of' rather than a uuid. Fixed bugs extracting the return data.
refactored getDuration as its not really part of the SoundPlayer as it can work without having to initialise a player. I've placed it in the plugin for the moment as nowhere better to place it really.
Fixed a bug where the callbackUid could not be encoded into a map.
sound_player_ui no requires that the Track has a MediaFormat as we need to get the duration.
changed to using the name as the key
removed temp_file as it duplicates functionality in FileUtil.
only check the mediaformat for support if it is passed other wise let the OS throw the error.
Fixed the naming convention on native formats. Fixed a bug where the sdk level did not match the actually encode/decoder suport levles.
changed to using the wellknown formats so the lookup will always match.
changed encoder and decoder to return the more useful NativeMediaFormat.
exported native media formats.
removed unused array.
changed to only display the natively supported list of codecs.
bug where mediaFormat wasn't being assigned.
removed the duration provider as its was simplier to just have each MediaFormat provide a getDuration method.
removed dead code.
changed ctor name.
Forced recording track to use a NativeMediaFormat.
renamed SoundPlayer ctor withUI to withShadeUI
Fixed compile bug by passing the correct context.
renamed flautoPlayerPlugin to soundPlayerPlugin
add missing package
added missing package statement and removed unused imports.
implemented getDuration.
change invokeMethod to invokeCallback to make its intent clearer.
Moved the native media formsts back into sounds so the native duration method is easier to register. They are also only useful if the sounds package is used.
renamed startPlayerFromTrack to startShadePlayer. Also seperated out classes into their own files.
removed old demos and renamed existing ones.
tweaked the text greeting.
Fixed mis-matched types.
fixed mis-match argument name.
Merge branch 'master' of github.com:bsutton/sounds
upgraded to 10.0
formatting
replaced deprecated apis
updated platform to 10.
bluetooth was being set via the wrong interface and error wasn't declared.
Merge branch 'master' of github.com:bsutton/sounds
upgraded the audio property settings for the speaker and bluetooth when recording is started. The logic has changed in that I now only set the speaker and bluetooth settings the first time recording is started on a SoundRecorder instance were previously it was doing it every time.
Merge branch 'master' of github.com:bsutton/sounds
fixed a cast problem (hopefully)
renamed flautoPlayerManager to soundPlayerManager.
Fixed compiler bugs as the SoundRecorderManager and SoundRecorder were both incorrectly typed.
renamed flautoPlayerSlots to playerSlots.
Fixed a bug where the freeSlot method was declared in the wrong class.
added casts to remove warnings and removed unnecessary conversions. Removed test for path as recording now always requires a path'
added self-> removed unused var
update the deployment target as we are using iosCategory which is a 10.x feature
removed redundant conversions and add self-> to remove warnings
changed timer to nullable as we actually return nil sometimes
fixed case with shadePlayerManager caused by global replace
Fixed incorrect assignment of asset to file
reverted to R8 until google stop adding automatically
added the required _Null declarations
renamed media formats to be of the form container/codec.
Fixes for // See https://github.com/flutter/flutter/issues/19830
restored becuase its required by the build system.
fixed the package statemnt .
added platform to bring in line with the default files created by flutter create.
wip working on getting andriod/ios build working.
updates for the rename of track player to shade player.
added main as android studio requires it.
Added so we can build with android studio as it requires it to exist.
renamed track player to shade player.
Changed Codec references to MediaFormat and removed the mediaFormat argument from any playback related methods. Removed the last bits of databuffer support from the android code.
trying to get gradle build  to work.
renamed TrackPlayer to ShadePlayer
aligned the plugin arguments.
changed setSubscriptionDuration to setSubscriptionInterval. Changed secs argement to millisecs for setSubscriptionDuration and setDbPeakLevelUpdate.  IsEncoderSupported and isDecoderSupport as now implemented in dart as they were just lookup tables. Altered startRecorder and startPlayer to work with the new MediaFormat.
removed ffmpeg from sounds
wip change from Codec to MediaFormat and extracting sounds_codec.
wip
wip
initial work in creating sounds_commons and sounds_codec.
released 0.8.9
removed ext_storage dependency as its no longer used.
released 0.8.8
removed LogLevel as its not used and for some reason its visible in the api doco (dispite me not exporting it).
released 0.8.7
released 0.8.6
continuing improvements to the doco.
added _nullable to the pointer as required by the latest version of xcode.
Fixed error no visible @interface for 'FFmpegPlugin' declares the selector 'alloc'. As the var name was the same case as the type.
released 0.8.5
Fixed compile error on Recase.
released 0.8.4. Fixed wiki links.
relesed 0.8.3
work on documentation
doco
renamed playbackEnabled to enablePlayback
setup imags directory for wiki.
revered to old logger for compatability
removed recase as was conflicting without projects for one line of code.
cancel is a method not a getter.
released 0.8.2
Fixed additonal lints and fixed a bug in the downloader not closing a subscription.
ZZMerge branch 'master' into dev
Merge branch 'dev' of github.com:bsutton/flutter_sound into dev
Merge branch 'dev' of github.com:bsutton/flutter_sound into dev
Merge branch 'dev' of github.com:bsutton/flutter_sound into dev
0.8.1 release
0.8.1 release
part of 0.8.1 release. Now prints the git tag name.
Merge branch 'dev' of github.com:bsutton/flutter_sound into dev
0.8.1 release. Essentially cleanup of lints formatting. First pass at cleanup of readme.
0.8.1 release. Essentially cleanup of lints formatting. First pass at cleanup of readme.
Some initial cleanup of doco.
Customised the logo.
rough pass at forking flutter sound.
Added logic to support older phones (api < 10) specifying AAC which isn't supported. We now change AAC to DEFAULT (which actually results in an aac recording) which supports these older phones.
change example package name to com.flutter_sound.
Added force options so we can force the final db update to be reflected in the ui.
increased the animation duration to smooth out the animation.
send final db of zero so any listening UI is reset.
Fixed some bugs and recorder ui is now essentially working but looks a little rough.
minor doco updates.
Added ability to create a track from an asset. This allows the widget to show a progress indicator as the asset is prepared which can take some time for large assets. It also makes it easier for the likes of QuickPlay to play from an asset.
We were missing the awaits so the build was triggering before the duration was recalculated. You also can't have awaited methods in a call to setState.
Added logic to request permissions.When codec changes we now correctly truncate the recording (as the current recording won't match the new codec).
changes to the ui class so that it responds correctly if a new track is passed to the widget. Previously it didn't update the duration/title etc if the track was changed during a build cycle.
duration is an int. For some reason I was processing it as a string :<
The recorder plugin no longer returns a 'finalPath' as the recording is no longer able to change the recording path. The ios code still returns a path but we just ignore it.
Added a new event onError which the sound player java plugin emits to indicate errors occuring during playback. If an error occurs the audio stops and this is indicated to the soundplayerui by emitting a stopevent. The code attempts to put the media player back into a state where it can be reused.
Placed the file management global methods into a class and exported them as the are fairly useful.
When stopping after being paused stop was not being called.
Added error handler if the play failed. Prviously we would calls the api to hang. General cleanup of the error handlers.
Added an error handle so that we correctly report an error if the media is invalid. Previously the code simply wouldn't return.
implemented asBuffer method to convert any audio type to an buffer.
Added error handling if the duration isn't returned.
renamed dataBuffer to buffer. Added method to get the buffer and a method to convert any Track type to a buffer.
added support for key arg in widgets. Moved to using the short ctors for creating playbackdispositions.
Added short hand ctor for recording and init.
Added method to read a file into a buffer.
Fixed a bug in Log.d which was suppressing most debug logging.
minor  doco changes. reduced logging.
added effective dart and pedantic deps so we can clean out more lints. Cleaned lints.
move work on the fromPath to fromFile mods.
tweaks to log messages.
Moved duration method into Codec as the duration logic is dependant on what codec is in use.
I've also renamed all occurances of the ctor 'fromPath' to 'fromFile' as this provides for a less ambigous naming convention.
SoundPlayer now generates progress events when downloading audio from a URL or when preparing a codec. The SoundPlayerUI now displays a circular progress indicator based on the above stream.  This code sets the scene for streaming.I've also removed the reliance on the underlying java/object-c code to download the urls which should simplify maintenance long term.
Missed a change required when renaming Author to Artist.
renamed SoundPlayer to FlutterSoundPlayer for better backward compatibility.
removed lint warnings.
renamed the Track author to artist as the data does actually represent the artist not the author.
fixed a bug where the pause was being sent rather than resume.
Merge branch 'master' of github.com:bsutton/flutter_sound
back port of 5.0 bug fixes. Fix for #340. Fixes for IllegalStateExceptions on play completion. Fixes for slot allocation bugs which incorrectly assume slots are allocated an initialised in order. This may need to be fixed in ios as well. Fixes for the ticker running during pause and after stop. Aligneg the recorder and players tick mechanism so that both are pausable. I would guess ios will need a similar fix. Removed androidEncoder/androidOutputformat as it is no longer used. Changed the name of androidAudioSource to audioSource. Note: this will need a change in the dart code. Track was not setting the art file. Added onPlayerReady callbacks. 4.0 will safely ignore these.
ugraded to flutter 1.17.0
Removed onFinished in favour of onStopped. It turns out you can't actually tell the difference as the plugin calls onFinished whether the player stops naturally or is stopped via user or api. As such the onStopped is a better verb as onFinished is mis-leading (it implies that the recording finished to completion). This will also simplify cleanup as users no longer have to hook both onStopped and onFinished.
Fixed an IllegalStateException caused by sending a progress update after the player had stopped. Also a little bit of code cleanup.
improved log message.
add missing initialiser.
reduced the level of logging.
Added logic to suppress duplicate log messages.
Fixed a resource leak in sound_recorder_ui.
I think this was a merge bug. The pauseHandler was getting called twice causing an npe.
Correct the tag text. And improved exception logging.
Improved the error when initialisation times out.
Fixed a few bugs. Release was being called twice. The recording button wasn't toggling when the recording state changed.
removed warnings.
change all spelling of initialise to the usa spelling.
Merge branch 'master' of github.com:bsutton/flutter_sound
Possible fix for #340. Looks like the problem is that a user can click a media button before Flauto is fully initialised. We now discard any media button events until Flauto is fully initialised.
Fixed a bug where the play method didn't handle the new Track.fromURL method.
added logic to protect from duplicate release.
renamed var.
Added additional logging and the slot expansion logic from SoundPlayer.
Added protection against duplicate releases. Now throws an exception explaining the problem.
Fixed a bug in slot management. The dart code now supports lazy initialisation of java slots. This caused an index out of bounds error as the java code assumed that slots will be allocated and initialised in a single action.  Slots are now grown dynamically as required.
Added support for hush others to demo2 and 3. Remove the play on osUI for demo 3 as it is all about SoundPlayerUI. Fixed a bug in RemotePlay as it now needs to use Track.fromURL Renamed AudioFocusMode to AudioFocus as the mode seemed redundant. Added AudioFocus to the ctors for SoundPlayerUI.
removed the rewind on app resume as this seems a bit opinionated. We may need to expose the app pause/resume events so that users of the api can make this type of decision themselves.
fixed npe if track is null when system pauses app.
Merge branch 'dev' into master
changed onConnected to onPlayerReady to make for clearer dart code as we will eventually have an onRecorderReady event.
Added logic to stop the recorder when the app is paused. Refactored the internals of AudioPlayer and SoundRecorder so they use the same initialisation mechanism to make maintenance easier. The SoundRecorderUI now responsed to start/stop events coming up from the SoundRecorder so that it correctly reflects the start/stop status of the recorder rather than trying to track it independantly (which didn't work for app pause.)
tweaks to the toString formatting.
Fixes for when the app is paused/resumed.
removed lint warnings.
doco.
Removed the android encoder and outputformats as they are no longer used. The android source has been changed to a simple source with a note that it is currently only supported on android.iOSQuality has become quality with the same notes.
added toString to help with logging.
Added loggers for app pause/resume. extra check that track is playing before we try to stop it.
Added lifecycle handler so we stop/resume the player when the app is stopped/resumed.
implemented a simplified example.
removed unecessary log.
added a logger for callbacks.
Made channel private as its not accessed outside of this class.
Added UIThread annotation. Not certain how useful they are at this stage.
Removed permission grants out of the api. It is now up to the user to request the permissions. The recorder provides a callback requestPermissions which allows the developer to request the permision only when they are required.
removed warning.
Fixed an npe (or was it just a better debug break point spot.)
Fixed a bug where the demo tried to stop the player when it wasn't playing. The stopPlayer method now throws an exception if you try this.
upgraded the build tools.
cleaned up the logic around providing updates back to date. Fixed a bug in the recorder resume as it wasn't restarting the updates. Fixed a bug in the player pause it it wasn't stopping the updates. I've modified the player so it uses the same mechanism as the record to send updates. The recorder looked like it made stoping/restarting upates easier so that was choosen as the model.
Now throws an exeception if you try to record anything other than a path. Should look at supporting buffers later on.
Changed the informUser callback to make it easier to work with. Fixed a bug where setState was being called during dispose(). Added error handling fro the request permissions and fixed a bug where request was called even though we had all necessary permissions.
Added logic to optimise out calls to set subscriptions. Now only calls if the subscription changes.
Made the storage type explicit to simplify the logic. You can now pass a null databuffer to fromBuffer which is useful if you a recording.
Merge with Brett Master branch. many regressions in "demo1.dart" (the old example/main.dart)
Working on the example App
Added a stop method which stops both player and recorder.
fixed some bits that got broken during the merge (duplication of methods)
exposed a stop() method and an of() method.
Merge branch 'master' of github.com:bsutton/flutter_sound
Merge remote-tracking branch 'upstream/dev'
Merge branch 'master' into master
updated doco to reflect new classes.
tweaked the min size to be zero when audio not playing.
Bug in release logic was setting onDisk to false even if the track was created from a path which release doesn't affect.
change the import so it connects to demo2.
added a comment to onFinished
added PauseButtonMode enum although I don't understand its usage.
cleaned up the api and fix bugs around starting a recording when the player was running.
Fixed a bug where onFinished could revert a play state from disabled to stopped which can occur due to race conditions when stopping.
changed onStop to onStopped as it more accruately reflects that the event is triggered after the stop has occured. Added a controller namespace to make the code easier to read.
Fixed a bug where on an exception I was completing twice.
as we have been treading on each others toes I've moved my versions of the example app to demo2 and demo3 and create a separate directory with the utils classes used by both of these.
Created SoundPlayer and TrackPlayer classes.
Fixed bug where the stop() method was closing the stream.
renamed SoundPlayer to AudioPlayer
Update issue templates
Update issue templates
Working on the old example app
minor corrections.
The new recordingplaybackController. Links a RecorderUI and PlaybackUI so they can be used to record/playback as a single unit.
changes required to work with the RecorderPlaybackController.
wip the new soundrecorder ui.
/// [RecordedAudio] is used to track the audio media /// created during a recording session via the SoundRecorderUI. ///
reflection of changes to Track which now has an explict storagepath.
Working on a re-initialisation after we are sent to the background or stopped.
We new have an explicit field 'storagePath' rather than assuming that path/url contained the correct path.
just some logging.
added map so we can get an extension from a codec.
change the return type to Duration so its consistent with rest of api.
now tracks the last duration.
exported RecorderPlaybackController and SoundRecorderUI
remove the reentrant logic as the UI now lets you test this directly.
improvements to help with inmplementation of SoundRecorderUI and the RecorderPlayabackController. The 'record' method now takes a Track which is consistent with how the SoundPlayer works. Now uses the RecordingTrack to store the recording.
split out of track.cart. Now updated the duration of the attached track as we recorde.
split fromUrl out of fromPath and improvments to the storage logic.
tempFile now actualy creates the file as SoundRecorder expects the file to exists.
minor improvements to argument names.
split fromURL out of fromPath. Improvements to how audio is stored.  Added a method to obtain the duration of a track.
Split fromURL out of fromPath to make the use cases more obvious.
Made a separate ocpy of the drop downs so @larpoux can make changes to the original main.dart. example 3 demos the new recorderplaybackcontroller.
Change return type to Duration.
added missing permissions.
removed ther rawAmplitude log as it clutters the debug console.
Port the 4.0.2+2 bug fix
Fix a crash that we had when accessing the global variable AndroidActivity from `BackGroundAudioSerice.java` [#317]
Fix a crash that we had when accessing the global variable AndroidActivity from `BackGroundAudioSerice.java` [#317]
Working on the old example app
Split example out into separate file as @Larpoux wants a single file version in main.dart.
added range clipping to ensure db is always reported in a valid range.
Updated doco including an example.
Merge remote-tracking branch 'upstream/master'
moved playback into three separate players
Fixes to the error processing so UI can update its state correctly.
moved remote file details to the RemotePlayer.
removed the media types we nolonger use.
Created custom widgets for each type of playback.
Added a buildcontext to onload so that users can display errors if required.
change playback stream to a broadcast as you should be able to listen as many times as you want. Fixed the interval had used microseconds by mistake.
Added a [rewind] method which required tracking of the current position. As such I'm now internally tracking the playback disposition and then only sending it up the stream at the requested frequency.Added a 'palyInBackground' parameter on the ctors but as yet I'm not certain what I need to tell the underlying plugin to do.The stop method now releases all resources.Improved doco.Still need to add code to the plugin to emit - _onSystemAppPaused and _onSystemAppResumed.
The old example compiles (but do not still run)
Port 4.0.1 to "dev". Not tested !
Release 4.0.1+1
"s.static_framework = true" in flutter_sound.podspec
Flutter sound is not compatible with "use_frameworks!" and "use_moular_headers!"
the podspec file was missing
Forgot to remove ffmpeg dependency in flutter_sound.podspec
Podfile does not need any more any hack for ffmpeg
Added additional readme notes.
Hid a number of internal methods.
made closeDispositionStream private.
removed ext as per the 4.0 requirements.
Release 4.0.0
Cleaned up the size of spinkit so the slider doesn't bounce when we show the spin kit.
Improved the layout and removed a flicker issue with spin kit cause by the index resetting to zero due to the limit.
Merge branch 'baselineforfailedstartup'
added missing log.dart imports.
added missing async to invokeMethod.
Changed call to asyncPrepare as current call to synchronous prepare was causing flutter ui to skip frames (for 2-3 seconds for a remote url).
added missing log.dart imports.
added missing async to invokeMethod.
Changed call to asyncPrepare as current call to synchronous prepare was causing flutter ui to skip frames (for 2-3 seconds for a remote url).
added logger class and changed all print statements to a log statements.
comment about deprecated code.
re-instated updatePlaybackState as found its purpose.
fixed an invalid paramter name.
Looks like i've fixed the onConnection issue. This required a major plumbing work as we needed to send an event backup through the channel from the plugin when the connection completes. The current method relied on the connection completing quickly which doesn't always happen.  We still need to send onConnection events for the iOS code and for no tracked android player.
WIP - experimentation on setting up plugin unit tests.
removed warning.
Added tick builder so spin kit doesn't display during small transitions (<100ms).
prepareStream is async.
moved init of date formatter up so it is ready when we need it.
tick builder to control when the spin kit is displayed.
removed warning.
pre restore to original versions.
Fixed a bug where the _player was being recreated even though the class wasn't being moved.
Fixed a bug where _track wasn't being whe play started.
Fixed bug where slots are shared in the java plugin but not by the dart plugin. Dart player plugin now shares slots.
Added back logic to play on OSs ui. Removed old code. Moved to QuickPlay for concurrent playback.
updated log statements.
removed unused pieces.
removed unused casts.
Fixed a possible npe.
changed arg name to be consistent with player.
Fixed compile issues due to new exeception. Need fix my dev environment so I see compile errors:<
removed warning.
brought sound_recorder inline with soundplayer techniques.
merged into single file.
move to util dir.
reworked the plugin hierarchy to make room for the recorder. Also remove duplicated code between tracker plugin and player plugin.
Merge branch 'master' of github.com:bsutton/flutter_sound
Changed QuickPlay is its a one liner to play audio. Good for beeps etc.Updated the doco on how to use SoundPlayer.
Changed QuickPlay is its a one liner to play audio. Good for beeps etc. Updated the doco on how to use SoundPlayer.
pre deletion of QuickPlay
removed internal notes.
renamed audiosession to SoundPlayer and SoundPlayer to QuickPlay.
updated to match new codec names.
Merge branch 'master' of github.com:bsutton/flutter_sound
reorged the code to reduce the public api and place libraries in logical locations.
draft recording api doco.
experiments.
disabled all buttons for noUI.
Work on cleaning up the focus request api. Still has some questionable uses as I don't think we are doing everything that is required.
major refactoring to make sessions explicit. Current there are compile issues with the recorder. This code is untested.
Fixes: #307 Added countdown latch to fix onConnect race condition.
Merge branch 'dev' into master
Structure of possible album api.
renamed start() to play(). rename types ToEvent to PlayerEvent and TonEventWithCause to PlayerEventWithCause.
Removed updatePlaybackState as it appears that it is no longer required.
Modified the Codec enum to remove the codec prefix off each enums name. Implemented logic to map a file extension to a codec. For consistency I now force users to either pass a uri with a know file extension or an explicit codec as I think it will reduce confusion as to whether a codec is needed. In theory the OS can work out the coded isn some cases but given this isn't necessarily consistent the explict approach should make the api easier to use.
new API verb in ffmpeg_util : `isFFmpegAvailable()`
Rename some of the codecs and add new ones that we must support soon
Copyleft in sources. Change the Codec enum
gitignore Podfile.lock
Merge with 4.0.0-beta.3
Some initial work on documenting the api.
renamed PlayBar to Playbar
Improved the documentation on playbar. Fixed a potential NPE when showTitle is true but no title or track has been provided. Made the layout of title/track a little smarter when only one of the two is available.
flutter_sound_lite
flutter_sound_lite
flutter_sound_lite
Change the recorder so the record button is enabled by default. If you try to record when its in an invalid state the a snackbar is displayed tell you how to correct it. I did this as even after using the UI a lot it wasn't obvious why the record option was disabled.
Fixed bug where Playbar wasn't calling release when replacing a SoundPlayer.
meged code changes and removed lots of lints :)
Merge branch 'master' of github.com:bsutton/flutter_sound
ignored .gradle directory.
moved to effective linter.
Added a fix for play mp3 players. The position can be greater than the duration need the end of playback. We now just make duration = position.
spelling.
Added logic to try and reset the os plugin when a hot reload occurs. Doesn't work as the plugin ignores calls to releases. Fixed a bug when showing tracks if the player doen't exists when a build occurs.
renamed connector to proxy and added logger for registration.
renamed as most code refered to .wav extension.
Added logic to ignore attempts to stop player when already stopped. Just prints a log message and ignores the request.
Fixed a bug where on hot reload we would stop the soundplayer rather than the Playbar. Also was stopping it even when it was already stopped. removed if in array to avoid having to upgrade sdk.
Added missing await when skipping which caused an inconsistent state. Updated code to reflect that the showOSUI is now an arg to the SoundPlayer ctor.
formatting.
Added logic to allow the playbar to show the album title.
Added santity checsk to the playback position as the android subsystem can generate -ve values during transitions.
Change to using milliseconds so we get finer grained slider movement.
Moved showOSUI to a ctor argument. We can't switch plugin once the SoundPlayer is setup so this needs needs to be defined up front. If we rationalised the plugins into a single plugin then we could switch modes dynamically. I don't think this is much of an issue except that two plugins is a maintenance headache. Created plugin for track player so we can switch between plugins to use the OS ui. Added handlers for skipForward/backwards. Documented seekTo can be called at any time.
Fixed a bug in the release logic.
renamed arg offset to position for consistency.
Fixed a bug in seek due to second/millisecond conversions.
removed encapsulation for playerModule as per lint.
rolled onFinish up into a lambda.
removed unused imports. Removed track.dart as no longer used.
Merge branch 'dev' into master
bug hushOthers lacked default.
the use OS UI switch is now always enabled. Previously was only enabled when media was stopped but no longer works as a player dosen't always exists.
fixed bug where the playstate module wasn't being set.
Fixed a bug where the show OS UI setting was not being applied.
Added packages required by playbar
reduced logging.
working through the kinks.
utility to do basic performance measurements.
Made the hush (duckOthers) a setting on the SoundBar which is applied when start() is called.
Experiment with the proposed api changes.
remove redundant import.
renamed the plug pause/resume handlers to differentiate them from the user methods.
made audioPlayerFinished private.
renamed isDecoderSupported to isSupported as this allows us to make is symetrical with the recorder and the encode/decode is implied by the fact it is a player/recorder.
merge Pull request #301 from Brett
Merge with beta-2
Added missing initialisation.
some initial work on setting up a mock unit test for startPlayer. Not in a working state.
added directoryExists method.
changes to updatePRogress args.
Fixed a copy/paste. bug in the findSlot
Fixed bug where exists test was assuming a file rather than a directory.
fixed mised name method. Removed an invalid assert. change arguments to updateProgress to only pass the required json arg.
added mising module initialising. tempFile is now aswync.
minor change to error message.
added logic to create the full diretory tree if it doesn't exist.
added metho to test if a directory exists.
removed flutter prefix from class names.
wip first clean compile after refactor.
WIP refactoring to a single player/recorder. removal of lint errors and directory re-organisation.
Merge with 3.1.10
Merge with 3.1.10
Trying to catch Android crash during a dirty Timer. [#289]
Merge with 3.1.9
Merge with 3.1.9
Looking to fix the Android crash when AndroidActivity is null (#296)
Looking to fix the Android crash when AndroidActivity is null (#296)
Merge with Version 4.0.0-beta.2
Version 4.0.0-beta.1
Remove Bsutton's example which is not ready to be published
Merge pull request #293 from bsutton/master
Add possibility to specify an Album Art local File in the Track object
fixed spelling.
moving to PlaybackDisposition model.
removed v1 as given we are breaking the api. Users requiring v1 can use 3.x branch.
removed unused field onUpdateProgress.
renmed player_state to playback_disposition
rename enums to use UpperCamelCase
fixed a toString method displaying the old fieldname.
Made additional members private.  Change _startPlayer to use named args rather than a map. Map for invokeMethod is now built within the method reducing the use of untyped maps. Removed some duplicated methods from tracked_player.
renamed types to conform to UpperCamelCase
Fixed a casing error and was incorrectly multiplying by 1000.
dbLevel now needs to be taken from the RecordingDispositon.
fixed a cast error.
Added logic to subtract pause time from recordings.
fixed an assert. We can be paused or recording.
Added RecorderPluginConnector to reduce our public api. Made fields private.
removed duplicated quotes.
renamed to match the class name.
moving to new dispositionStream.
Moved FlautoPlayerPlugin to its own file. t_CODEC renamed Codec. Moved PlayStatus to its own file.
refactored file names to bring in line with google best pratices. Working on controlling exposure of only methods/classes that we want to be part of the public interface.
minor change. removed unnecessary if statement.
Moved FlautoRecorderPlugin to its own file. Rework to implement the new dispositionStream api.
changed to using the new dispositionStream.
Moved TrackPlayerPlugin to its own class. t_CODEC renamed Codec.
moved classes to their own file and into src acording to best practices.
removing lint warngins. renamed Duck to Hush as it makes more sense from a user perspetive.
New class to pass duration and db in a single stream.
moved to src directory in accordance with google recommended best pratices.
Added basic documenation. Removed future from fileExists.
Made a number of methods private. Fixed the return signature of setPlayerCallback as it does not return a future.
removed redundant call to recorderModule.setDbLevelEnabled(true);
removed lint warnings.
removed lint warnings.
refactored listeners into separate methods.
Fix some regressions during the last merge
I hope that I have not lost something from Bsbutton during the merge
flutter_ffmpeg is now embedded inside flutter_sound
Fix a bug ('async') when the app forget to initalize its Flutter Sound module. [#287](https://github.com/dooboolab/flutter_sound/issues/287)
Fix a bug ('async') when the app forget to initalize its Flutter Sound module. [#287](https://github.com/dooboolab/flutter_sound/issues/287)
removed additional lint warnings.
Merge branch 'master' of github.com:bsutton/flutter_sound
partial fix for the UI not returning to the correct state.
Fixed a regression with the 'arg' name.
added doco.
Merge branch 'master' into master
changed recording to not be disabled when the codec isn't supported as the user can't tell why. We now catch the error and display a reason.
changed snackbar to red.
created explicit exception for each recording failure.
Added snackbar when recording fails to start with cause.
Added logic to reset slider when recording stops.
Modified audioPlayerFinished so we now pass it a PlayStatus rather than passing around an untyped map.
Fixed issue - stop/pause buttons still enabled when playback completes.
Fixed issue where you can't play an asset.
Release 3.1.7
Merge remote-tracking branch 'upstream3/master : requestPermission argument. @matsu911. [#283]'
Beginning cleanin Warnins. There sre still 442 warnings remaining !
Added requestPermission argument with default value true
Pedantic?
Additional notes on audio-lts settings.
removed unused imports.
reverted to limit range 5 to 6.
refactored the example to improve its maintainablility. Also fixed a number of bugs. Improved the usbility by adding a couple of error messages.
Fixes for pedantic lints
added pedantic lints and fixed all reported issues.
upgraded permission handler to 5.0
CHANGELOG
CHANGELOG
Version 3.1.6
Merge "conflict with permission_handler" [#274]
[#267] and [#248]
fixed permission_handler version
fixed conficts with permission_handler 5.x.x
Merge pull request #268 from oliversd/pr/fix-typo-android-documentation-ffmpeg
Fix error on documentation for Android FFmpeg setup
Remove warnings when doing "flutter pub publish"
Remove warnings when doing "flutter pub publish"
Fix a bug when initializing Flutter Embedded V1 on Android [#267]
Release 3.1.4
isRecording -> false when the Recorder is paused
v3.1.2
Flutter Sound depends on "permission_handler: ^4.4.0"
Update deleted readme
Flutter Modules are re-entrant (concurrency) (#257)
Release 3.0.0+1
Fix issue #254 (#256)
Release 3.0.0
[FLAUTO] (#243)
Release 2.1.1
Enh/custom path handling (#225)
Release 2.0.5
Resolve #221 (#224)
Use AAC-LC format instead of MPEG-4 (#209)
Release 2.0.4 (#211)
OGG/OPUS support on iOS (#199)
Release 2.0.3
Resolve #198
Resolve #194
Release 2.0.2 for quick support for #203
Resolve #193 and release 2.0.1
Bump up to 2.0.0 with androidx compatibility
Release 1.9.0
Compatibility with Android SDK 19 (#185)
Release 1.8.0 and update changelog
Fix issue #175 (#181)
Fix for Bug #128 (#177)
Android minSdkVersion is 22 instead of 23. SDK before 22 fails (#179)
Update stale.yml
Create stale.yml
Release 1.7.0
Create a new method : startPlayerFromBuffer, to play from a buffer (#170)
fixes returned filePath on iOS (#168)
[Release] 1.6.0 (#167)
Release 1.5.2
refactor: postfix GetDirectoryOfType to avoid conflicts (#147)
Release 1.5.1
Release 1.5.0
Use NSCachesDirectory... (#141)
Update readme
Release 1.4.8
Update readme
Release 1.4.7 (#138)
Resolve #135
Release/1.4.5 (#133)
Release 1.4.4
Stopped recording generating infinite db values. (#131)
Release 1.4.3
Improved db calcs. (#123)
Added missing close markers
Added discussion on disposing recorder/player and showed detailed usage of futures.
Update README.md
Remove buymeacoffee
Update readme
Add paypal donate link
Release 1.4.2
fix uiThread bug
Release 1.4.1
Fixed bug in which mediaRecorder was stopping instead of mediaPlayer
Added isPlaying and isRecording getters
Fixed 'mediaplayer went away with unhandled events'  bug
fix(example): remove milliseconds conversion
Release 1.4.0
Bump version to 1.3.7, update changelog.
Android: Move to compile/target SDK version 28.
Set up for bluetooth microphone input on iOS
iOS: Fix for seekToPlayer not returning correct type, not correctly applying adjustment in seconds, and not calling updateProgress callback
Release 1.3.7
Merge pull request #66 from ened/command-queue-2
Update change log & plugin version.
Android: Add a task scheduler to run recording related tasks on.
Android: Enable Java8 source & target compatibility
Remove unused getPlatformVersion implementation.
Android: Upgrade Gradle dependencies
Merge pull request #64 from dooboolab/revert-63-android-command-queue
Revert "Android command queue for recording related tasks"
Merge pull request #63 from ened/android-command-queue
Update change log & plugin version.
Android: Add a task scheduler to run recording related tasks on.
Android: Enable Java8 source & target compatibility
Remove unused getPlatformVersion implementation.
Android: Upgrade Gradle dependencies
Release 1.3.5
Merge pull request #59 from JoniDS/master
Tweak: Adjust dbPeak range (0-160) to better match the -160<->160 iOS range.
Fix: bitRate nullability check for iOS was wrong and throwing an exception when bitRate was not specified
Merge pull request #5 from dooboolab/master
Release 1.3.4
Merge pull request #54 from JoniDS/master
Have consistent argument positioning
Add ability to specify bitrate Change Android file extension to M4A
Merge pull request #4 from dooboolab/master
Release 1.3.3
Merge pull request #49 from JoniDS/master
Add Android encoder settings Add iOS quality settings Fix typo
Merge pull request #3 from dooboolab/master
Release 1.3.2
Release 1.3.1
Merge pull request #47 from Ajmal-M-A/master
Fix : Initialize Date Formatting once
Fix : issue in showing wrong recorder time text
Merge pull request #44 from JoniDS/fix/ios-remote-playing
Merge pull request #43 from JoniDS/feature/db-meter
Re-create AudioPlayer on every startPlayer (to change Url)
Fix: Allow remote audio playing irregardless of protocol (iOs) Fix: When playing a sound for the second time (different from the first sound), the first sound would be played instead (iOs)
FIX: Merge broke Android startRecorder
Merge pull request #2 from dooboolab/master
Release 1.3.0.
Merge pull request #36 from JoniDS/feature/db-meter
Add amplitude docs to Readme
Release 1.2.7.
Merge pull request #41 from edman/master
Merge pull request #40 from mikeyyg96/master
Delete unit_test.dart
Fix file URI for recording and playing in iOS
working_seeker_with_audio_example
Release 1.2.6.
Merge pull request #39 from dooboolab/SliderExample
Fixed slider example.
Merge pull request #38 from mikeyyg96/master
Slider widget with seek
Release 1.2.5.
Merge pull request #35 from haideraltahan/master
Android now converts to int. iOS use the double for sampling rate.
Fix: start DB peak not starting (iOS) Fix: using double when int is enough for startRecorder(numChannels,sampleRate) on Android
Rollback regressions
Remove forgotten line
fix merging conflicts
Merge pull request #1 from dooboolab/master
Fix typos
Initial implementation of recording sound level (https://github.com/dooboolab/flutter_sound/issues/11)
Fixed Android Bug
Reduce the size of audio in ios.
Release 1.2.3.
Release 1.2.2.
Merge pull request #29 from JoniDS/feature/android_audio_settings
Merge pull request #24 from MagicalTux/master
Implementation of https://github.com/dooboolab/flutter_sound/pull/24 for Android (numChannels & sampleRate)
merged improved 662d212 from https://github.com/Shigawire
Release 1.2.1.
Release 1.2.0.
Update README.md
Release 1.1.5.
Merge pull request #9 from justsoft/master
Fix seekPlayer, setVolume, setSubscriptionDuration throw exception on Android
Release 1.1.4.
Fix broken image in pub.
Fix broken image in pub.
Released to 1.1.3.
Updated readme.
Update readme.
Trying to mockup and test plugin. Related: https://github.com/flutter/flutter/issues/21172.

# 1.0.0-beta.8
Fixed a bug in the stop() method. It was not calling the _plugin.stop method.
no longer used.

# 0.9.3
identical to beta 7 to stop people being wedged by the deployment bug in 0.9.2

# 1.0.0-beta.7
This release contains a breaking change.
QuickPlay has been updated to take onStopped as a ctor argument to ensure that it always gets called.

updated to latest pubspec package api.
updated to reflect api changes.
Added additional logging.
minor cleanup.

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

