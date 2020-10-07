package com.bsutton.sounds;
/*
 * This file is part of Sounds .
 *
 *   Sounds  is free software: you can redistribute it and/or modify
 *   it under the terms of the Lesser GNU General Public License
 *   version 3 (LGPL3) as published by the Free Software Foundation.
 *
 *   Sounds  is distributed in the hope that it will be useful,
 *   but WITHOUT ANY WARRANTY; without even the implied warranty of
 *   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *   GNU General Public License for more details.
 *
 *   You should have received a copy of the Lesser GNU General Public License
 *   along with Sounds .  If not, see <https://www.gnu.org/licenses/>.
 */

import android.content.Context;
import android.media.AudioManager;
import android.os.Handler;
import android.support.v4.media.MediaMetadataCompat;
import android.support.v4.media.session.PlaybackStateCompat;
import android.util.Log;

import androidx.annotation.UiThread;

import java.time.Duration;
import java.util.concurrent.Callable;
import java.util.concurrent.CountDownLatch;
import java.util.concurrent.TimeUnit;

// import io.flutter.embedding.engine.FlutterEngine;
// import io.flutter.embedding.engine.plugins.FlutterPlugin;
//import io.flutter.embedding.engine.plugins.activity.ActivityAware;
// import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding;
// import io.flutter.plugin.common.BinaryMessenger;

public class ShadePlayer extends SoundPlayer {
	private MediaBrowserHelper mMediaBrowserHelper;

	// Used to make callback on the main UI thread
	// for progress updates
	final private Handler tickUIHandler = new Handler();


	private boolean playInBackground;
	private boolean canPause;
	private boolean canSkipBackward;
	private boolean canSkipForward;

	private SoundsPlatformApi.SoundPlayerProxy playerProxy;
	private SoundsPlatformApi.TrackProxy trackProxy;

	ShadePlayer() {
	}


	private boolean connected = false;

	void initializeShadePlayer(SoundsPlatformApi.SoundPlayerProxy playerProxy, boolean playInBackground,
							   boolean canPause, boolean canSkipBackward, boolean canSkipForward) throws SoundsException {

		if (mMediaBrowserHelper != null)
			throw new SoundsException(ErrorCodes.errnoGeneral, "The player has already been initialised");

		this.playerProxy = playerProxy;
		this.playInBackground = playInBackground;
		this.canPause = canPause;
		this.canSkipBackward = canSkipBackward;
		this.canSkipForward = canSkipForward;

		audioManager = (AudioManager) SoundsPlugin.ctx.getSystemService(Context.AUDIO_SERVICE);


		connected = false;
		CountDownLatch connectedLatch = new CountDownLatch(1);

		// If the initialization will be successful, result.success will
		// be called, otherwise result.error will be called.
		mMediaBrowserHelper = new MediaBrowserHelper(new MediaPlayerConnectionListener(connectedLatch, true),
				new MediaPlayerConnectionListener(connectedLatch,  false));
//		// Pass the playback state updater to the media browser
//		mMediaBrowserHelper.setPlaybackStateUpdater(new PlaybackStateUpdater());

		// The connection process has completed.
		try {
			connectedLatch.await(5, TimeUnit.SECONDS);
		} catch (InterruptedException e) {
			throw new SoundsException(ErrorCodes.errnoTimeout, "Timedout waiting for Media to start playing");
		}

		if (connected == false)
			throw new SoundsException(ErrorCodes.errnoGeneral, "Failed to connect to the media browser");

	}


	/**
	 * The callable instance to call when the media player has been connected.
	 */
	private class MediaPlayerConnectionListener implements Callable<Void> {
		// Whether this callback is called when the connection is successful
		private boolean isSuccessfulCallback;
		private CountDownLatch connectedLatch;

		MediaPlayerConnectionListener(CountDownLatch connectedLatch, boolean isSuccessfulCallback) {
			this.isSuccessfulCallback = isSuccessfulCallback;
			this.connectedLatch = connectedLatch;
		}

		@Override
		public Void call() throws Exception {

			// notify initialise that the connection process has completed.
			connected = isSuccessfulCallback;
			connectedLatch.countDown();
			return null;
		}
	}


	@Override
	public void dispose() {
		try {
			releaseSoundPlayer();
		}
		catch (SoundsException e)
		{
			Log.d(TAG, "SoundPlayer.dispose() Exception: " + e.toString());
		}
	}

	@Override
	void releaseSoundPlayer() throws SoundsException {
		checkMediaPlayer();

		// Release the media browser
		mMediaBrowserHelper.releaseMediaBrowser();
		mMediaBrowserHelper = null;
	}

	@Override
	public void startPlayer(SoundsPlatformApi.TrackProxy track, Duration startAt) throws SoundsException {
		this.trackProxy = track;

		checkMediaPlayer();

		String path = track.getPath();

		if (canPause) {
			mMediaBrowserHelper.setPauseHandler(new PauseHandler());
		} else {
			mMediaBrowserHelper.removePauseHandler();
		}

		// Add or remove the handlers for when the user tries to skip the current track
		if (canSkipForward) {
			mMediaBrowserHelper.setSkipTrackForwardHandler(new SkipTrackHandler(true));
		} else {
			mMediaBrowserHelper.removeSkipTrackForwardHandler();
		}
		if (canSkipBackward) {
			mMediaBrowserHelper.setSkipTrackBackwardHandler(new SkipTrackHandler(false));
		} else {
			mMediaBrowserHelper.removeSkipTrackBackwardHandler();
		}

		if (canPause) {
			mMediaBrowserHelper.setPauseHandler(new PauseHandler());
		} else {
			mMediaBrowserHelper.removePauseHandler();
		}


		// Pass to the media browser the metadata to use in the notification
		mMediaBrowserHelper.setNotificationMetadata(track);

		CountDownLatch mediaStartedLatch = new CountDownLatch(1);

		// Add the listeners for the onPrepared and onCompletion events
		mMediaBrowserHelper.setMediaPlayerOnPreparedListener(new MediaPlayerOnPreparedListener(mediaStartedLatch, trackProxy.getPath()));
		mMediaBrowserHelper.setMediaPlayerOnCompletionListener(new MediaPlayerOnCompletionListener());

		// Send the audio file to the media player
		mMediaBrowserHelper.mediaControllerCompat.getTransportControls().playFromMediaId(path, null);

		// The media player is started in the on prepared callback
		// we wait for it to start.
		try {
			mediaStartedLatch.await(5, TimeUnit.SECONDS);
		} catch (InterruptedException e) {
			throw new SoundsException(ErrorCodes.errnoTimeout, "Timedout waiting for Media to start playing");
		}

		startProgressTimer();

	}

	private Duration trackDuration;

	private void startProgressTimer( ) {
		// Set timer task to send event to RN
		trackDuration = Duration.ofMillis(mMediaBrowserHelper.mediaControllerCompat.getMetadata()
				.getLong(MediaMetadataCompat.METADATA_KEY_DURATION));

		// make certain no tickers are currently running.
		stopProgressTimer( false);

		tickUIHandler.post(() -> sendPlaybackProgress(trackDuration));
	}

	private void stopProgressTimer(boolean sendFinal) {
		/// send a final update before we stop the ticker
		/// so dart sees the last position we reached.
		if (sendFinal) {
			sendPlaybackProgress(trackDuration);
		}
		tickUIHandler.removeCallbacksAndMessages(null);
	}

	@UiThread
	private void sendPlaybackProgress(Duration trackDuration) {
		try {

			PlaybackStateCompat playbackState = mMediaBrowserHelper.mediaControllerCompat
					.getPlaybackState();

			if (playbackState != null) {

				long currentPosition = playbackState.getPosition();


				SoundsPlatformApi.OnPlaybackProgress args = new SoundsPlatformApi.OnPlaybackProgress();
				args.setPlayer(playerProxy);
				args.setTrack(trackProxy);
				args.setDuration(trackDuration.toMillis());
				args.setPosition(currentPosition);

				// send the update
				tickUIHandler.post(new Runnable() {
					@Override
					public void run() {
						new SoundsPlatformApi.SoundsFromPlatformApi(SoundsPlugin.getBinaryMessenger()).onPlaybackProgress(args, null);
					}
				});
				// reschedule ourselves.
				tickUIHandler.postDelayed(() -> sendPlaybackProgress(trackDuration), (model.progressInterval.toMillis()));
			}
			else
			{
				Log.e(TAG, "PlaybackState is null!");
			}

		} catch (Exception e) {
			Log.d(TAG, "Exception: " + e.toString());
		}
	}

	public void stopPlayer() throws SoundsException {
		// This remove all pending runnables
		stopProgressTimer(true);
		checkMediaPlayer();

		try {
			// Stop the playback
			mMediaBrowserHelper.stop();
		} catch (Exception e) {
			throw new SoundsException(ErrorCodes.errnoGeneral, e.getMessage());
		}
	}



	@Override
	public void pausePlayer() throws SoundsException {
		checkMediaPlayer();

		try {
			stopProgressTimer(true);
			// Pause the media player
			mMediaBrowserHelper.pausePlayback();
		} catch (Exception e) {
			Log.e(TAG, "pausePlay exception: " + e.getMessage());
			throw new SoundsException(ErrorCodes.errnoUnknownPlayer, e.getMessage());
		}
	}

	@Override
	public void resumePlayer() throws SoundsException {
		checkMediaPlayer();

		// Throw an error if we can't resume the media player because it is already
		// playing
		PlaybackStateCompat playbackState = mMediaBrowserHelper.mediaControllerCompat.getPlaybackState();

		try {
			startProgressTimer();
			// Resume the player
			mMediaBrowserHelper.resumePlayback();
		} catch (Exception e) {
			Log.e(TAG, "mediaPlayer resume: " + e.getMessage());
			throw new SoundsException(ErrorCodes.errnoGeneral, e.getMessage());
		}
	}

	@Override
	public void seekToPlayer(Duration seekTo) throws SoundsException {
		checkMediaPlayer();

		mMediaBrowserHelper.seekTo(seekTo.toMillis());
		// Should declaratively change state:
		// https://stackoverflow.com/questions/39719320/seekto-does-not-trigger-onplaybackstatechanged-in-mediacontrollercompat
		mMediaBrowserHelper.playPlayback();
	}

	@Override
	public void setVolume(float volume) throws SoundsException {
		checkMediaPlayer();

		// Get the maximum value for the volume
		int maxVolume = mMediaBrowserHelper.mediaControllerCompat.getPlaybackInfo().getMaxVolume();
		// Get the value of the new volume level
		int newVolume = (int) Math.floor(volume * maxVolume);

		// Adjust the media player volume to the given level
		mMediaBrowserHelper.mediaControllerCompat.setVolumeTo(newVolume, 0);
	}

	public void setPlaybackProgressInterval(Duration interval) {
		this.model.progressInterval = interval;
	}

	private void checkMediaPlayer() throws SoundsException {
		if (mMediaBrowserHelper == null) {
			Log.e(TAG, "initializePlayer() must be called before this method.");
			throw new SoundsException(ErrorCodes.errnoUnknownPlayer, "The MediaBrowser has not been initialised");
		}
	}

	// -------------------------------------------------------------------------------------------------------------------------------


	/**
	 * A listener that is triggered when the pause buttons in the notification are
	 * clicked.
	 */
	private class PauseHandler implements Callable<Void> {
		private boolean mIsSkippingForward;

		PauseHandler() {
		}

		@Override
		public Void call() throws Exception {
			PlaybackStateCompat playbackState = mMediaBrowserHelper.mediaControllerCompat.getPlaybackState();
			if (playbackState.getState() == PlaybackStateCompat.STATE_PLAYING) {
				SoundsPlatformApi.OnShadePaused args = new SoundsPlatformApi.OnShadePaused();
				args.setPlayer(playerProxy);
				args.setTrack(trackProxy);
				new SoundsPlatformApi.SoundsFromPlatformApi(SoundsPlugin.getBinaryMessenger()).onShadePaused(args, null);
			}
			else
			{
				SoundsPlatformApi.OnShadeResumed args = new SoundsPlatformApi.OnShadeResumed();
				args.setPlayer(playerProxy);
				args.setTrack(trackProxy);
				new SoundsPlatformApi.SoundsFromPlatformApi(SoundsPlugin.getBinaryMessenger()).onShadeResumed(args, null);

			}


			return null;
		}
	}

	/**
	 * A listener that is triggered when the skip buttons in the notification are
	 * clicked.
	 */
	private class SkipTrackHandler implements Callable<Void> {
		private boolean mIsSkippingForward;

		SkipTrackHandler(boolean isSkippingForward) {
			mIsSkippingForward = isSkippingForward;
		}

		@Override
		public Void call() throws Exception {
			if (mIsSkippingForward) {
				SoundsPlatformApi.OnShadeSkipForward args = new SoundsPlatformApi.OnShadeSkipForward();
				args.setPlayer(playerProxy);
				args.setTrack(trackProxy);
				new SoundsPlatformApi.SoundsFromPlatformApi(SoundsPlugin.getBinaryMessenger()).onShadeSkipForward(args, null);

			} else {
				SoundsPlatformApi.OnShadeSkipBackward args = new SoundsPlatformApi.OnShadeSkipBackward();
				args.setPlayer(playerProxy);
				args.setTrack(trackProxy);
				new SoundsPlatformApi.SoundsFromPlatformApi(SoundsPlugin.getBinaryMessenger()).onShadeSkipBackward(args, null);
			}

			return null;
		}
	}

//	/**
//	 * A function that triggers a function in the Dart code to update the playback
//	 * state.
//	 */
//	private class PlaybackStateUpdater implements Function<BackgroundAudioService.SystemPlaybackState, Void> {
//		@Override
//		public Void apply(BackgroundAudioService.SystemPlaybackState newState) {
//			invokeCallbackWithInteger("updatePlaybackState", newState.stateNo);
//			return null;
//		}
//	}

	/**
	 * The callable instance to call when the media player is prepared.
	 */
	private class MediaPlayerOnPreparedListener implements Callable<Void> {

		private String mPath;
		CountDownLatch mediaStartedLatch;

		private MediaPlayerOnPreparedListener(CountDownLatch mediaStartedLatch, String path) {
			mPath = path;
			this.mediaStartedLatch = mediaStartedLatch;
		}

		@Override
		public Void call() throws Exception {
			// The content is ready to be played, then play it
			mMediaBrowserHelper.playPlayback();

			// the audio is running.
			mediaStartedLatch.countDown();

			return null;
		}



	}

	/**
	 * The callable instance to call when the media player calls the onCompletion
	 * event.
	 */
	private class MediaPlayerOnCompletionListener implements Callable<Void> {
		MediaPlayerOnCompletionListener() {
		}

		@Override
		public Void call() throws Exception {
			// Reset the timer
			Log.d(TAG, "Plays completed.");
			stopProgressTimer(true);


			SoundsPlatformApi.OnPlaybackStopped args = new SoundsPlatformApi.OnPlaybackStopped();
			args.setPlayer(playerProxy);
			args.setTrack(trackProxy);
			args.setErrorCode(0L);

			tickUIHandler.post(new Runnable() {
				@Override
				public void run() {
					new SoundsPlatformApi.SoundsFromPlatformApi(SoundsPlugin.getBinaryMessenger()).onPlaybackStopped(args, null);
				}
			});
			return null;
		}
	}

}
// ---------------------------------------------------------------------------------------------------------------------------------
