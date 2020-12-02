# Monitoring

## Overview

If you are building your own widget you might want to display a progress bar that displays the current recording or playback position.

The easiest way to do this is via the `SoundPlayerUI/SoundRecordingUI` widgets but if you want to write your own then you will want to use the `dispositionStream` with a StreamBuilder.

To use a `dispositionStream` you need to create an `SoundPlayer or SoundRecorder` instance.

```dart
class MyWidgetState
{
	/// use .noUI() as you are going to build your own UI.
	var player = SoundPlayer().noUI();

	void initState()
	{
		super.initState();

	}

	void dispose()
	{
		player.release();
		super.dispose();
	}

	 Widget build() {
    	 return Row(children:
		 	[Button('Play' onTap: onPlay)
		 		, StreamBuilder<PlaybackDisposition>(
					stream: player.dispositionStream,
					initialData: PlaybackDisposition.zero(),
					builder: (context, snapshot) {
					var disposition = snapshot.data;
					return Slider(
						max: disposition.duration.inMilliseconds.toDouble(),
						value: disposition.position.inMilliseconds.toDouble(),
						onChanged: (value) =>
							player._seek(Duration(milliseconds: value.toInt())),
					);
            		}
				))
			]);
      },
    ));

  /// you would wire this to a button
  void onPlay()
  {
	  player.play(Track.fromFile('sample.aac'));
  }

   /// you would wire this to a pause button
  void onPause()
  {
	  player.pause();
  }

   /// you would wire this to a button
  void onResume()
  {
	  player.resume();
  }
}
```

