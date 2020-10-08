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

import android.annotation.SuppressLint;
import android.content.Context;
import android.media.AudioFocusRequest;
import android.media.AudioManager;
import android.media.MediaPlayer;
import android.os.Build;
import android.os.Handler;
import android.util.Log;

import androidx.annotation.UiThread;

import java.time.Duration;

import static com.bsutton.sounds.ErrorCodes.errnoAudioServiceDied;
import static com.bsutton.sounds.ErrorCodes.errnoGeneral;
import static com.bsutton.sounds.ErrorCodes.errnoIOError;
import static com.bsutton.sounds.ErrorCodes.errnoMalformedMedia;
import static com.bsutton.sounds.ErrorCodes.errnoTimeout;
import static com.bsutton.sounds.ErrorCodes.errnoUnsupportedMediaFormat;

//-------------------------------------------------------------------------------------------------------------

public class SoundPlayer extends SoundsProxy  {
	final static String TAG = "SoundPlayer";
	final PlayerAudioModel model = new PlayerAudioModel();

	// Used to make callback on the main UI thread
	final private Handler mainUIHandler = new Handler();

	// stores the current audio focus mode so we can restore it
	// after resuming.
	private AudioFocusRequest audioFocusRequest = null;
	protected AudioManager audioManager;

	private boolean playInBackground;

	 private SoundsPlatformApi.SoundPlayerProxy playerProxy;
	 private SoundsPlatformApi.TrackProxy trackProxy;

	void initializeSoundPlayer(SoundsPlatformApi.SoundPlayerProxy playerProxy, boolean playInBackground) {
		this.playerProxy = playerProxy;

		audioManager = (AudioManager) SoundsPlugin.ctx.getSystemService(Context.AUDIO_SERVICE);

		this.playInBackground = playInBackground;
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
	void releaseSoundPlayer()  throws SoundsException {
		// no op.
	}


	public void startPlayer(SoundsPlatformApi.TrackProxy track, Duration startAt ) throws SoundsException {
		assert (track.getPath() != null);

		this.trackProxy = track;
		if (this.model.getMediaPlayer() != null) {
			/// re-start after media has been paused
			Boolean isPaused = !this.model.getMediaPlayer().isPlaying()
					&& this.model.getMediaPlayer().getCurrentPosition() > 1;

			throw new SoundsException(ErrorCodes.errnoAlreadyPlaying, "Already playing. Call stop first.");
		}

		/// This causes an IllegalStateException to be throw by the MediaPlayer.
		/// Looks to be a minor bug in the android MediaPlayer so we can ignore it.
		this.model.setMediaPlayer(new MediaPlayer());

		try {
			this.model.getMediaPlayer().setDataSource(track.getPath());


			/// set up the listeners before we start.
			this.model.getMediaPlayer().setOnPreparedListener(mp -> onPreparedListener(mp));
			// Detect when finish playing.
			this.model.getMediaPlayer().setOnCompletionListener(mp -> completeListener(mp));
			this.model.getMediaPlayer().setOnErrorListener((mp, what, extra) -> onError(mp, what, extra));

			this.model.getMediaPlayer().prepare();
		} catch (Exception e) {
			throw new SoundsException(ErrorCodes.errnoGeneral, "startPlayer() Exception" + e.getCause().getClass().getSimpleName() + " " + e.getMessage());
		}
	}

	// listener for the MediaPlayer
	// Called when the MediaPlayer has finished preparing the media for playback.
	private void onPreparedListener(MediaPlayer mp) {
		Log.d(TAG, "mediaPlayer prepared and start");
		mp.start();
		startProgressTimer(mp);
	}

	// Called by the media player if an error occurs during playback.
	private boolean onError(MediaPlayer mp, int what, int extra) {
		stopProgressTimer(mp, false);
		/// reset the player.
		mp.reset();
		mp.release();
		this.model.setMediaPlayer(null);
		SoundsPlatformApi.OnError args =
				 translateErrorCodes(what, extra);
				new SoundsPlatformApi.OnError();

				mainUIHandler.post(new Runnable() {
					@Override
					public void run() {
						new SoundsPlatformApi.SoundsFromPlatformApi(SoundsPlugin.getBinaryMessenger()).onError(args, (reply) -> {});
					}
				});
		return true;


	}

	// Called when the audio stops, this can be due
	// the natural completion of the audio track or because
	// the playback was stopped.
	private void completeListener(MediaPlayer mp) {
		stopProgressTimer(mp, true);
		/*
		 * Reset player.
		 */
		Log.d(TAG, "Playback completed.");

		SoundsPlatformApi.OnPlaybackFinished args = new SoundsPlatformApi.OnPlaybackFinished();
		args.setPlayer(playerProxy);
		args.setTrack(trackProxy);

		mainUIHandler.post(new Runnable() {
			@Override
			public void run() {
				new SoundsPlatformApi.SoundsFromPlatformApi(SoundsPlugin.getBinaryMessenger()).onPlaybackFinished(args, (reply) -> {});
			}
		});


		if (mp.isPlaying()) {
			mp.stop();
		}

		mp.reset();
		mp.release();
		model.setMediaPlayer(null);
	}

	public void stopPlayer() throws SoundsException {
		MediaPlayer mp = this.model.getMediaPlayer();

		if (mp == null) {
			throw new SoundsException(ErrorCodes.errnoUnknownPlayer, "The MediaPlayer does not exist");
		}

		try {
			stopProgressTimer(mp, true);
			mp.stop();
			mp.reset();
			mp.release();
			this.model.setMediaPlayer(null);

		} catch (Exception e) {
			throw new SoundsException(ErrorCodes.errnoGeneral, "stopPlayer() Exception" + e.getCause().getClass().getSimpleName() + " " + e.getMessage());
		}
	}

	public void pausePlayer() throws SoundsException {
		MediaPlayer mp = this.model.getMediaPlayer();
		if (mp == null) {
			throw new SoundsException(ErrorCodes.errnoUnknownPlayer, "The MediaPlayer does not exist");
		}

		try {
			stopProgressTimer(mp, true);
			mp.pause();

		} catch (Exception e) {
			throw new SoundsException(ErrorCodes.errnoGeneral, "pausePlayer() Exception" + e.getCause().getClass().getSimpleName() + " " + e.getMessage());
		}

	}

	public void resumePlayer() throws SoundsException {
		MediaPlayer mp = this.model.getMediaPlayer();

		if (mp == null) {
			throw new SoundsException(ErrorCodes.errnoUnknownPlayer, "The MediaPlayer does not exist");
		}

		if (mp.isPlaying()) {
			throw new SoundsException(ErrorCodes.errnoAlreadyPlaying, "The Audio is already playing");
		}

		try {
			startProgressTimer(mp);
			mp.seekTo(mp.getCurrentPosition());
			mp.start();
			Log.d(TAG, "resumed");
		} catch (Exception e) {
			throw new SoundsException(ErrorCodes.errnoGeneral, "resumePlayer() Exception" + e.getCause().getClass().getSimpleName() + " " + e.getMessage());
		}
	}

	public void seekToPlayer(Duration seekTo) throws SoundsException {
		MediaPlayer mp = this.model.getMediaPlayer();

		if (mp == null) {
			throw new SoundsException(ErrorCodes.errnoUnknownPlayer, "The MediaPlayer does not exist");
		}

		int currentMillis = mp.getCurrentPosition();
		Log.d(TAG, "currentMillis: " + currentMillis);
		// millis += currentMillis; [This was the problem for me]

		int seekToMillis = (int)seekTo.toMillis();

		Log.d(TAG, "seekTo: " + seekToMillis);

		mp.seekTo(seekToMillis);
	}

	public void setVolume(float volume) throws SoundsException {
		MediaPlayer mp = this.model.getMediaPlayer();

		if (mp == null) {
			throw new SoundsException(ErrorCodes.errnoUnknownPlayer, "The MediaPlayer does not exist");
		}
		mp.setVolume(volume, volume);
	}

	public void setProgressInterval(Duration interval) {
		this.model.progressInterval = interval;
	}

	private void startProgressTimer(MediaPlayer mp) {
		// make certain no tickers are currently running.
		stopProgressTimer(mp, false);

		mainUIHandler.post(() -> sendPlaybackProgress(mp, false));
	}

	private void stopProgressTimer(MediaPlayer mp, boolean sendFinal) {
		/// send a final update before we stop the ticker
		/// so dart sees the last position we reached.
		if (sendFinal) {
			sendPlaybackProgress(mp, true);
		}
		//mainUIHandler.removeCallbacksAndMessages(null);
	}

	// We cache the duration as during shutdown we need to send a final
	// progress message to flutter and the mediaplay may not be available
	Integer duration ;
	long getDuration(MediaPlayer mp)
	{
		if (duration == null)
		{
			duration = mp.getDuration();
		}
		return duration;
	}
	@UiThread
	private void sendPlaybackProgress(MediaPlayer mp, boolean sendFinal) {
		try {

			SoundsPlatformApi.OnPlaybackProgress args = new SoundsPlatformApi.OnPlaybackProgress();
			args.setPlayer(playerProxy);
			args.setTrack(trackProxy);
			args.setDuration(getDuration(mp));

			if (mp.isPlaying())
				args.setPosition((long) mp.getCurrentPosition());

			if (sendFinal)
				args.setPosition(getDuration(mp));

			if (sendFinal || mp.isPlaying()) {
				mainUIHandler.post(new Runnable() {
					@Override
					public void run() {
						new SoundsPlatformApi.SoundsFromPlatformApi(SoundsPlugin.getBinaryMessenger()).onPlaybackProgress(args
								, (reply) -> {
								});
					}
				});
				// reschedule ourselves.
				mainUIHandler.postDelayed(() -> sendPlaybackProgress(mp, false), (model.progressInterval.toMillis()));
			}
		} catch (IllegalStateException e) {
			Log.d(TAG, "IllegalStateException: this can occur when the player is shutting down, so don't panic." );
		}
	}

	/**
	 * changes the curretn audioFocus mode and then requests it.
	 * @param audioFocus
	 */
	void requestAudioFocus(SoundsPlatformApi.AudioFocusProxy audioFocus) {
		long agnosticMode = audioFocus.getAudioFocusMode();

		int androidMode = AudioManager.AUDIOFOCUS_GAIN;
		if (agnosticMode == audioFocus.getStopOthersNoResume())
			androidMode = AudioManager.AUDIOFOCUS_GAIN; //1
		else if (agnosticMode == audioFocus.getStopOthersWithResume())
			androidMode = AudioManager.AUDIOFOCUS_GAIN_TRANSIENT_EXCLUSIVE; // 4;
		else if (agnosticMode == audioFocus.getHushOthersWithResume())
			androidMode = AudioManager.AUDIOFOCUS_GAIN_TRANSIENT_MAY_DUCK; // 3;
		/// 2 - transient -not currently supported.

		requestFocus();
	}


	@SuppressLint("NewApi")
	private void requestFocus() {
		if (canRequestAudioFocus()) {
			if (audioManager.requestAudioFocus(audioFocusRequest) != AudioManager.AUDIOFOCUS_REQUEST_GRANTED)
			{
				Log.w(TAG, "Unable to requests audio focus - Grant denied");
			}
		}
	}

	private boolean  canRequestAudioFocus()
	{
		if (audioFocusRequest == null) {
			if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {

				audioFocusRequest = new AudioFocusRequest.Builder(AudioManager.AUDIOFOCUS_GAIN)
						// .setAudioAttributes(mPlaybackAttributes)
						// .setAcceptsDelayedFocusGain(true)
						// .setWillPauseWhenDucked(true)
						// .setOnAudioFocusChangeListener(this, mMyHandler)
						.build();
			} else
				Log.w(TAG, "Unable to requests audio focus - old android version");
		}

		return audioFocusRequest != null;

	}

	@SuppressLint("NewApi")
	void releaseAudioFocus() {
		if (canRequestAudioFocus()) {
			if (audioManager
					.abandonAudioFocusRequest(audioFocusRequest) != AudioManager.AUDIOFOCUS_REQUEST_GRANTED)
			{
				Log.w(TAG, "Unable to abandon audio focus - Grant denied");
			}
		}
	}

	/// Attempts to translate Android media errors into general error strings.
	/// These strings need to match equavalent error generated from iOS.
	SoundsPlatformApi.OnError translateErrorCodes(int mediaPlayerError, int extra) {
		SoundsPlatformApi.OnError error = new SoundsPlatformApi.OnError();

		if (mediaPlayerError == MediaPlayer.MEDIA_ERROR_IO) {
			error.setErrorCode(errnoIOError);
			error.setError("File or Network Error");
		} else if (mediaPlayerError == MediaPlayer.MEDIA_ERROR_MALFORMED) {
			error.setErrorCode(errnoMalformedMedia);
			error.setError("Malformed audio. Does not match the expected MediaFormat");
		} else if (mediaPlayerError == MediaPlayer.MEDIA_ERROR_SERVER_DIED) {
			error.setErrorCode(errnoAudioServiceDied);
			error.setError("Media server stopped");
		} else if (mediaPlayerError == MediaPlayer.MEDIA_ERROR_TIMED_OUT) {
			error.setErrorCode(errnoTimeout);
			error.setError("Timeout");
		} else if (mediaPlayerError == MediaPlayer.MEDIA_ERROR_UNKNOWN) {
			error.setErrorCode(errnoGeneral);
			error.setError("An unknown error occured");
		} else if (mediaPlayerError == MediaPlayer.MEDIA_ERROR_UNSUPPORTED) {
			error.setErrorCode(errnoUnsupportedMediaFormat);
			error.setError("Unsupported MediaFormat");
		} else {
			error.setErrorCode(errnoGeneral);
			error.setError("Unknown error code: " + mediaPlayerError);
		}

		Log.e(TAG, "MediaPlayer error: " + error.getError() + " what: " + mediaPlayerError + " extra: " + extra);
		return error;
	}

}
