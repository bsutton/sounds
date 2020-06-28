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
import android.media.AudioFocusRequest;
import android.media.AudioManager;
import android.media.MediaMetadataRetriever;
import android.media.MediaPlayer;
import android.net.Uri;
import android.os.Build;
import android.os.Handler;
import android.util.Log;

import androidx.annotation.UiThread;

import org.json.JSONException;
import org.json.JSONObject;

import java.util.HashMap;
import java.util.Map;

import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel.Result;


//-------------------------------------------------------------------------------------------------------------


public class SoundPlayer
{
	enum t_SET_CATEGORY_DONE
	{
		NOT_SET,
		FOR_PLAYING, // sounds did it during startPlayer()
		BY_USER // The caller did it himself : Sounds must not change that)
	}
	;



	final static  String           TAG         = "SoundPlayer";
	final         PlayerAudioModel model       = new PlayerAudioModel ();
	final private Handler           tickHandler = new Handler ();
	t_SET_CATEGORY_DONE setActiveDone     = t_SET_CATEGORY_DONE.NOT_SET;
	AudioFocusRequest   audioFocusRequest = null;
	AudioManager        audioManager;
	int                 slotNo;


	static final String ERR_UNKNOWN           = "ERR_UNKNOWN";
	static final String ERR_PLAYER_IS_NULL    = "ERR_PLAYER_IS_NULL";
	static final String ERR_PLAYER_IS_PLAYING = "ERR_PLAYER_IS_PLAYING";

	SoundPlayer ( int aSlotNo )
	{
		slotNo = aSlotNo;
	}


	SoundPlayerPlugin getPlugin ()
	{
		return SoundPlayerPlugin.soundPlayerPlugin;
	}


	void initializeSoundPlayer ( final MethodCall call, final Result result )
	{
		audioManager = ( AudioManager ) SoundPlayerPlugin.androidContext.getSystemService ( Context.AUDIO_SERVICE );
		result.success ( "Flutter Player Initialized" );
	}

	void releaseSoundPlayer ( final MethodCall call, final Result result )
	{
		result.success ( "Flutter Recorder Released" );
	}


	void getDuration(final MethodCall call, final Result result )
	{
		/// let the dart code resume whilst we get the results.
		result.success("queued");

		String callbackUuid = "Not supplied";
		try
		{
			final String path = call.argument ( "path" );
			/// used so we can handle multiple calls in parallel.
			callbackUuid = call.argument ( "callbackUuid" );

			Uri uri = Uri.parse(path);
			MediaMetadataRetriever mmr = new MediaMetadataRetriever();
			mmr.setDataSource(Context.getAppContext(),uri);
			String durationStr = mmr.extractMetadata(MediaMetadataRetriever.METADATA_KEY_DURATION);
			int milliSeconds = Integer.parseInt(durationStr);

			Map<String, Object> args = new HashMap<String, Object> (); 
			args.put("callbackUuid", callbackUuid);
			args.put("milliseconds", milliSeconds);

			Map<String, Object> dic = new HashMap<String, Object> ();
			dic.put ( "slotNo", slotNo );
			dic.put ( "arg", args );
			getPlugin ().invokeCallback ( "durationResults", dic );
		}
		catch (Throwable e)
		{
			sendError(e.getMessage(), 0, 0, callbackUuid);
		}

	}


	void invokeCallbackWithString ( String methodName, String arg )
	{
		Map<String, Object> dic = new HashMap<String, Object> ();
		dic.put ( "slotNo", slotNo );
		dic.put ( "arg", arg );
		getPlugin ().invokeCallback ( methodName, dic );
	}

	void invokeCallbackWithDouble ( String methodName, double arg )
	{
		Map<String, Object> dic = new HashMap<String, Object> ();
		dic.put ( "slotNo", slotNo );
		dic.put ( "arg", arg );
		getPlugin ().invokeCallback ( methodName, dic );
	}

	public void startPlayer ( final MethodCall call, final Result result )
	{
		final String path = call.argument ( "path" );
		_startPlayer(path, result);
	}

	public void _startPlayer ( String path, final Result result )
	{
		assert(path != null);
		if ( this.model.getMediaPlayer () != null )
		{
			/// re-start after media has been paused
			Boolean isPaused = !this.model.getMediaPlayer ().isPlaying () && this.model.getMediaPlayer ().getCurrentPosition () > 1;

			if ( isPaused )
			{
				this.model.getMediaPlayer ().start ();
				result.success ( "player resumed." );
				return;
			}

			Log.e ( TAG, "Player is already running. Stop it first." );
			result.success ( "player is already running." );
			return;
		} 

		/// This causes an IllegalStateException to be throw by the MediaPlayer.
		/// Looks to be a minor bug in the android MediaPlayer so we can ignore it.
		this.model.setMediaPlayer ( new MediaPlayer () );
		
		try
		{
			this.model.getMediaPlayer ().setDataSource ( path );
			if ( setActiveDone == t_SET_CATEGORY_DONE.NOT_SET )
			{
				setActiveDone = t_SET_CATEGORY_DONE.FOR_PLAYING;
				requestFocus ();
			}

			/// set up the listeners before we start.
			this.model.getMediaPlayer().setOnPreparedListener(mp -> onPreparedListener(mp, result));
			// Detect when finish playing.
			this.model.getMediaPlayer ().setOnCompletionListener ( mp -> completeListener(mp));
			this.model.getMediaPlayer().setOnErrorListener((mp, what, extra) -> onError(mp, what, extra));

			this.model.getMediaPlayer ().prepareAsync ();
		}
		catch ( Exception e )
		{
			Log.e ( TAG, "startPlayer() exception", e );
			result.error ( ERR_UNKNOWN, ERR_UNKNOWN, e.getMessage () );
		}
	}

	// listener for the MediaPlayer 
	// Called when the MediaPlayer has finished preparing the media for playback.
	private void onPreparedListener(MediaPlayer mp, final Result result)
	{
		Log.d(TAG, "mediaPlayer prepared and start");
		mp.start();
		startTickerUpdates(mp);
		result.success("");
	}
						
	// Called by the media player if an error occurs during playback.
	private boolean onError(MediaPlayer mp, int what, int extra)
	{
		String description = translateErrorCodes(extra);
		Log.e(TAG, "MediaPlayer error: " + description + " what: " + what + " extra: " + extra);

		stopTickerUpdates(mp, false);
		/// reset the player.
		mp.reset();
		mp.release ();
		this.model.setMediaPlayer(null);

		sendError(description, what, extra, null);

		return true;
	}

	void sendError(String description, int what, int extra, String callbackUuid)
	{
		try {
			JSONObject json = new JSONObject();
			json.put("description", description);
			json.put("android_what",  what);
			json.put("android_extra",  extra);
			if (callbackUuid != null)
			{
				json.put("callbackUuid",  callbackUuid);
			}
			invokeCallbackWithString("onError", json.toString());
		} catch (JSONException e) {
			Log.e(TAG, "Error encoding json message for onError: what=" + what + " extra=" + extra);
		}
	}

	// Called when the audio stops, this can be due
	// the natural completion of the audio track or because
	// the playback was stopped.
	private void completeListener(MediaPlayer mp)
	{
		stopTickerUpdates(mp, true);
		/*
		 * Reset player.
		 */
		Log.d ( TAG, "Plays completed." );
		try
		{
			JSONObject json = new JSONObject ();
			json.put ( "duration", String.valueOf ( mp.getDuration () ) );
			json.put ( "current_position", String.valueOf ( mp.getCurrentPosition () ) );
			invokeCallbackWithString ( "audioPlayerFinishedPlaying", json.toString () );
		}
		catch ( Exception e )
		{
			Log.d ( TAG, "Json Exception: " + e.toString () );
		}
		if ( mp.isPlaying () )
		{
			mp.stop ();
		}
		if ( ( setActiveDone != t_SET_CATEGORY_DONE.BY_USER ) && ( setActiveDone != t_SET_CATEGORY_DONE.NOT_SET ) )
		{

			setActiveDone = t_SET_CATEGORY_DONE.NOT_SET;
			abandonFocus ();
		}

		mp.reset ();
		mp.release ();
		model.setMediaPlayer ( null );
	}

	private void startTickerUpdates(MediaPlayer mp) {
		// make certain no tickers are currently running.
		stopTickerUpdates(mp, false);

		tickHandler.post ( () -> sendUpdateProgress(mp) );
	}

	private void stopTickerUpdates(MediaPlayer mp, boolean sendFinal) {
		/// send a final update before we stop the ticker
		/// so dart sees the last position we reached.
		if (sendFinal)
		{
			sendUpdateProgress(mp);
		}
		tickHandler.removeCallbacksAndMessages ( null );
	}

	@UiThread
	private void sendUpdateProgress(MediaPlayer mp)
	{
		try
		{
			JSONObject json = new JSONObject();
			json.put("duration", String.valueOf(mp.getDuration()));
			json.put("current_position", String.valueOf(mp.getCurrentPosition()));
			invokeCallbackWithString("updateProgress", json.toString());

			// reschedule ourselves.
			tickHandler.postDelayed(() -> sendUpdateProgress(mp), (model.subsDurationMillis));
		}
		catch ( Exception e )
		{
			Log.d ( TAG, "Exception: " + e.toString () );
		}
	}

	public void stopPlayer ( final MethodCall call, final Result result )
	{
		MediaPlayer mp = this.model.getMediaPlayer();

		if ( mp == null )
		{
			result.success ( "Player already Closed");
			return;
		}
		if ( ( setActiveDone != t_SET_CATEGORY_DONE.BY_USER ) && ( setActiveDone != t_SET_CATEGORY_DONE.NOT_SET ) )
		{

			setActiveDone = t_SET_CATEGORY_DONE.NOT_SET;
			abandonFocus ();
		}

		try
		{
			stopTickerUpdates(mp, true);
			mp.stop ();
			mp.reset ();
			mp.release ();
			this.model.setMediaPlayer ( null );
			result.success ( "stopped player." );
		}
		catch ( Exception e )
		{
			Log.e ( TAG, "stopPlay exception: " + e.getMessage () );
			result.error ( ERR_UNKNOWN, ERR_UNKNOWN, e.getMessage () );
		}
	}

	public void pausePlayer ( final MethodCall call, final Result result )
	{
		MediaPlayer mp = this.model.getMediaPlayer ();
		if ( mp == null )
		{
			result.error ( ERR_PLAYER_IS_NULL, "pausePlayer()", ERR_PLAYER_IS_NULL );
			return;
		}
		if ( ( setActiveDone != t_SET_CATEGORY_DONE.BY_USER ) && ( setActiveDone != t_SET_CATEGORY_DONE.NOT_SET ) )
		{
			setActiveDone = t_SET_CATEGORY_DONE.NOT_SET;
			abandonFocus ();
		}

		try
		{
			stopTickerUpdates(mp, true);
			mp.pause ();
			result.success ( "paused player." );
		}
		catch ( Exception e )
		{
			Log.e ( TAG, "pausePlay exception: " + e.getMessage () );
			result.error ( ERR_UNKNOWN, ERR_UNKNOWN, e.getMessage () );
		}

	}

	public void resumePlayer ( final MethodCall call, final Result result )
	{
		MediaPlayer mp = this.model.getMediaPlayer ();

		if ( mp == null )
		{
			result.error ( ERR_PLAYER_IS_NULL, "resumePlayer", ERR_PLAYER_IS_NULL );
			return;
		}

		if ( mp.isPlaying () )
		{
			result.error ( ERR_PLAYER_IS_PLAYING, ERR_PLAYER_IS_PLAYING, ERR_PLAYER_IS_PLAYING );
			return;
		}
		if ( setActiveDone == t_SET_CATEGORY_DONE.NOT_SET )
		{
			setActiveDone = t_SET_CATEGORY_DONE.FOR_PLAYING;
			requestFocus ();
		}

		try
		{
			startTickerUpdates(mp);
			mp.seekTo( mp.getCurrentPosition () );
			mp.start();
			result.success ( "resumed player." );
		}
		catch ( Exception e )
		{
			Log.e ( TAG, "mediaPlayer resume: " + e.getMessage () );
			result.error ( ERR_UNKNOWN, ERR_UNKNOWN, e.getMessage () );
		}
	}

	public void seekToPlayer (final MethodCall call, final Result result)
	{
		MediaPlayer mp = this.model.getMediaPlayer ();

		int millis = call.argument ( "milli" ) ;

		if ( mp == null )
		{
			result.error ( ERR_PLAYER_IS_NULL, "seekToPlayer()", ERR_PLAYER_IS_NULL );
			return;
		}

		int currentMillis = mp.getCurrentPosition ();
		Log.d ( TAG, "currentMillis: " + currentMillis );
		// millis += currentMillis; [This was the problem for me]

		Log.d ( TAG, "seekTo: " + millis );

		mp.seekTo ( millis );
		result.success ( String.valueOf ( millis ) );
	}

	public void setVolume ( final MethodCall call, final Result result )
	{
		MediaPlayer mp = this.model.getMediaPlayer ();

		double volume = call.argument ( "volume" );

		if ( mp == null )
		{
			result.error ( ERR_PLAYER_IS_NULL, "setVolume()", ERR_PLAYER_IS_NULL );
			return;
		}

		float mVolume = ( float ) volume;
		mp.setVolume ( mVolume, mVolume );
		result.success ( "Set volume" );
	}


	public void setSubscriptionInterval ( final MethodCall call, Result result )
	{
		if ( call.argument ( "milli" ) == null )
		{
			return;
		}
		int duration = call.argument ( "milli" );

		this.model.subsDurationMillis = duration ;
		result.success ( "setSubscriptionInterval: " + this.model.subsDurationMillis );
	}

	void androidAudioFocusRequest ( final MethodCall call, final Result result )
	{
		Integer focusGain = call.argument ( "focusGain" );

		if ( Build.VERSION.SDK_INT >= Build.VERSION_CODES.O )
		{
			audioFocusRequest = new AudioFocusRequest.Builder ( focusGain )
				// .setAudioAttributes(mPlaybackAttributes)
				// .setAcceptsDelayedFocusGain(true)
				// .setWillPauseWhenDucked(true)
				// .setOnAudioFocusChangeListener(this, mMyHandler)
				.build ();
			Boolean b = true;
			setActiveDone = t_SET_CATEGORY_DONE.NOT_SET;

			result.success ( b );
		} else
		{
			Boolean b = false;
			result.success ( b );
		}
	}

	boolean requestFocus ()
	{
		if ( Build.VERSION.SDK_INT >= Build.VERSION_CODES.O )
		{
			if ( audioFocusRequest == null )
			{
				audioFocusRequest = new AudioFocusRequest.Builder ( AudioManager.AUDIOFOCUS_GAIN )
					//.setAudioAttributes(mPlaybackAttributes)
					//.setAcceptsDelayedFocusGain(true)
					//.setWillPauseWhenDucked(true)
					//.setOnAudioFocusChangeListener(this, mMyHandler)
					.build ();
			}
			return ( audioManager.requestAudioFocus ( audioFocusRequest ) == AudioManager.AUDIOFOCUS_REQUEST_GRANTED );
		} else
		{
			return false;
		}
	}

	boolean abandonFocus ()
	{
		if ( Build.VERSION.SDK_INT >= Build.VERSION_CODES.O )
		{
			if ( audioFocusRequest == null )
			{
				audioFocusRequest = new AudioFocusRequest.Builder ( AudioManager.AUDIOFOCUS_GAIN )
					//.setAudioAttributes(mPlaybackAttributes)
					//.setAcceptsDelayedFocusGain(true)
					//.setWillPauseWhenDucked(true)
					//.setOnAudioFocusChangeListener(this, mMyHandler)
					.build ();
			}
			return ( audioManager.abandonAudioFocusRequest ( audioFocusRequest ) == AudioManager.AUDIOFOCUS_REQUEST_GRANTED );
		} else
		{
			return false;
		}

	}

	void setActive ( final MethodCall call, final Result result )
	{
		Boolean enabled = call.argument ( "enabled" );

		Boolean b = false;
		try
		{
			if ( enabled )
			{
				if ( setActiveDone != t_SET_CATEGORY_DONE.NOT_SET )
				{ // Already activated. Nothing todo;
					setActiveDone = t_SET_CATEGORY_DONE.BY_USER;
					result.success ( b );
					return;
				}
				setActiveDone = t_SET_CATEGORY_DONE.BY_USER;
				b             = requestFocus ();
			} else
			{
				if ( setActiveDone == t_SET_CATEGORY_DONE.NOT_SET )
				{ // Already desactivated
					result.success ( b );
					return;
				}

				setActiveDone = t_SET_CATEGORY_DONE.NOT_SET;
				b             = abandonFocus ();
			}
		}
		catch ( Exception e )
		{
			b = false;
		}
		result.success ( b );
	}

	/// Attempts to translate Android media errors into general error strings.
	/// These strings need to match equavalent error generated from iOS.
	String translateErrorCodes(int what)
	{
		String error;
		if (what == MediaPlayer.MEDIA_ERROR_IO)
		{
			error = "File or Network Error";
		}
		else if (what == MediaPlayer.MEDIA_ERROR_MALFORMED)
		{
			error = "Malformed audio. Does not match the expected MediaFormat";
		}
		else if (what == MediaPlayer.MEDIA_ERROR_SERVER_DIED)
		{
			error = "Media server stopped";
		}
		else if (what == MediaPlayer.MEDIA_ERROR_TIMED_OUT)
		{
			error = "Timeout";
		}
		else if (what == MediaPlayer.MEDIA_ERROR_UNKNOWN) {
			error = "An unknown error occured";
		}
		else if (what == MediaPlayer.MEDIA_ERROR_UNSUPPORTED) {
			error = "Unsupported MediaFormat";
		}
		else 
		{
			error = "Unknown error code: " + what;
		}
		return error;
	}

}

