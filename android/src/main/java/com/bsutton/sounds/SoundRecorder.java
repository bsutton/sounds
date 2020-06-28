package com.bsutton.sounds;
/*
 * This file is part of Sounds.
 *
 *   Sounds is free software: you can redistribute it and/or modify
 *   it under the terms of the Lesser GNU General Public License
 *   version 3 (LGPL3) as published by the Free Software Foundation.
 *
 *   Sounds is distributed in the hope that it will be useful,
 *   but WITHOUT ANY WARRANTY; without even the implied warranty of
 *   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *   GNU General Public License for more details.
 *
 *   You should have received a copy of the Lesser GNU General Public License
 *   along with Sounds.  If not, see <https://www.gnu.org/licenses/>.
 */


import android.content.Context;
import android.media.MediaRecorder;
import android.os.Build;
import android.os.Environment;
import android.os.Handler;
import android.os.SystemClock;
import android.util.Log;

import androidx.annotation.UiThread;

import org.json.JSONObject;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.concurrent.ExecutorService;
import java.util.concurrent.Executors;

import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.embedding.engine.plugins.activity.ActivityAware;
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding;
import io.flutter.plugin.common.BinaryMessenger;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;

import io.flutter.plugin.common.PluginRegistry;
import io.flutter.plugin.common.PluginRegistry.Registrar;


public class SoundRecorder
{
	static final String ERR_RECORDER_IS_NULL      = "ERR_RECORDER_IS_NULL";
	static final String ERR_RECORDER_IS_RECORDING = "ERR_RECORDER_IS_RECORDING";


	final static String             TAG                = "SoundRecorder";
	final        RecorderAudioModel model              = new RecorderAudioModel ();
	final public Handler            progressTickHandler      = new Handler ();
	final public Handler            dbPeakLevelTickHandler = new Handler ();
	
	int    slotNo;
	private final ExecutorService taskScheduler = Executors.newSingleThreadExecutor ();
	private Handler mainHandler = new Handler();

	SoundRecorder ( int aSlotNo )
	{
		slotNo = aSlotNo;
	}


	SoundRecorderPlugin getPlugin ()
	{
		return SoundRecorderPlugin.flautoRecorderPlugin;
	}


	void initializeSoundRecorder ( final MethodCall call, final Result result )
	{
		result.success ( "Sounds Recorder Initialized" );
	}

	void releaseSoundRecorder ( final MethodCall call, final Result result )
	{
		result.success ( "Sounds Recorder Released" );
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

	public void startRecorder ( final MethodCall call, final Result result )
	{
		Log.d(TAG, "startRecorder: " + call.argument("path"));
		Integer      sampleRate          = call.argument ( "sampleRate" );
		Integer      numChannels         = call.argument ( "numChannels" );
		Integer      bitRate             = call.argument ( "bitRate" );
		int          encoder              = call.argument ( "encoder" );
		int          format              = call.argument ( "format" );
		int          audioSource 		 = call.argument ( "audioSource" );
		final String path                = call.argument ( "path" );
		_startRecorder ( numChannels, sampleRate, bitRate, encoder, format, audioSource, path, result );

	}

	public void _startRecorder (
		Integer numChannels, Integer sampleRate, Integer bitRate, Integer encoder, int format, int audioSource, String path, final Result result
	                           )
	{
		assert(path != null);
		final int v = Build.VERSION.SDK_INT;
		MediaRecorder mediaRecorder = model.getMediaRecorder ();

		if ( mediaRecorder == null )
		{
			mediaRecorder = new MediaRecorder ();
			model.setMediaRecorder (mediaRecorder );
		}

		try
		{
			if (path == null) {
				result.error(TAG, "InvalidArgument", "path must NOT be null.");
				return;
			}

			mediaRecorder.reset();
			try
			{
				mediaRecorder.setAudioSource ( audioSource );
			}
			catch (RuntimeException e)
			{
				result.error(TAG, "Permissions", "Error setting the AudioSource. Check that you have permission to use the microphone.");
				return;
			}
			mediaRecorder.setOutputFormat ( format );
			mediaRecorder.setOutputFile ( path );
			mediaRecorder.setAudioEncoder ( encoder );

			if ( numChannels != null )
			{
				mediaRecorder.setAudioChannels ( numChannels );
			}

			if ( sampleRate != null )
			{
				mediaRecorder.setAudioSamplingRate ( sampleRate );
			}

			// If bitrate is defined, then use it, otherwise use the OS default
			if ( bitRate != null )
			{
				mediaRecorder.setAudioEncodingBitRate ( bitRate );
			}

			mediaRecorder.prepare ();
			mediaRecorder.start ();

			this.model.startTime = SystemClock.elapsedRealtime ();
			startTickerUpdates();

			result.success("Success");
		}
		catch ( Exception e )
		{
			Log.e ( TAG, "Exception: ", e );
			result.error( TAG, "Error starting recorder", e.getMessage() );
			try
			{
				boolean b = _stopRecorder( );

			} catch (Exception e2)
			{

			}
		}
	}

	// Starts the progress and Db level tickers if required.
	private void startTickerUpdates()
	{
		// make certain no tickers are currently running.
		stopTickerUpdates();
		progressTickHandler.post ( () -> sendProgressUpdate() );

		if ( this.model.shouldProcessDbLevel ) {
			dbPeakLevelTickHandler.post (() -> sendDBLevelUpdate() );
		}
	}

	// stops the progress and Db level tickers.
	private void stopTickerUpdates()
	{
		progressTickHandler.removeCallbacksAndMessages ( null );
		dbPeakLevelTickHandler.removeCallbacksAndMessages(null);
	}

	// Sends an Db Level update to the dart code and then
	// reschedule ourselves to do it again.
	@UiThread
	private void sendDBLevelUpdate()
	{
		MediaRecorder recorder = model.getMediaRecorder ();
		if ( recorder != null )
		{
			double maxAmplitude = recorder.getMaxAmplitude ();

			// Calculate db based on the following article.
			// https://stackoverflow.com/questions/10655703/what-does-androids-getmaxamplitude-function-for-the-mediarecorder-actually-gi
			//
			double ref_pressure = 51805.5336;
			double p            = maxAmplitude / ref_pressure;
			double p0           = 0.0002;

			double db = 20.0 * Math.log10 ( p / p0 );

			// if the microphone is off we get 0 for the amplitude which causes
			// db to be infinite.
			if ( Double.isInfinite ( db ) )
			{
				db = 0.0;
			}

			// Log.d ( TAG, "rawAmplitude: " + maxAmplitude + " Base DB: " + db );
			invokeCallbackWithDouble (  "updateDbPeakProgress", db );

			// schedule the next update.
			dbPeakLevelTickHandler.postDelayed ( () ->  sendDBLevelUpdate(), ( model.peakLevelUpdateMillis ) );
		}
	}

	// Sends a duration progress update to the dart code.
	// This method then re-queues itself.
	@UiThread
	private void sendProgressUpdate()
	{
		long time = SystemClock.elapsedRealtime () - model.startTime;
		try
		{
			JSONObject json = new JSONObject ();
			json.put ( "current_position", String.valueOf ( time ) );
			invokeCallbackWithString ( "updateRecorderProgress", json.toString () );
			// Log.d(TAG,  "updateRecorderProgress: " +  json.toString());

			// re-queue ourselves based on the desired subscription interval.
			boolean queued = progressTickHandler.postDelayed ( () ->sendProgressUpdate(), this.model.subsDurationMillis );
			// Log.d(TAG, "progress posted=" + queued + " delay:" + this.model.subsDurationMillis);
		}
		catch ( Exception je )
		{
			Log.d ( TAG, "Exception calling updateRecorderProgress: " + je.toString () );
		}
	}

	public void stopRecorder ( final MethodCall call, final Result result )
	{
		//taskScheduler.submit ( () -> _stopRecorder ( result ) );
		boolean b = _stopRecorder (  );
		if (b)
			result.success ( "Media Recorder is closed" );
		else
			result.success ( " Cannot close Recorder");
	}

	public boolean _stopRecorder (  )
	{
		// This remove all pending runnables
		stopTickerUpdates();

		if ( this.model.getMediaRecorder () == null )
		{
			Log.d ( TAG, "mediaRecorder is null" );

			return true;
		}
		try
		{
			if ( Build.VERSION.SDK_INT >= 24 )
			{

				try
				{
					this.model.getMediaRecorder().resume(); // This is stupid, but cannot reset() if Pause Mode !
				}
				catch ( Exception e )
				{
				}
			}
			this.model.getMediaRecorder().stop();
			this.model.getMediaRecorder().reset();
			this.model.getMediaRecorder().release();
			this.model.setMediaRecorder( null );
		} catch  ( Exception e )
		{
			Log.d ( TAG, "Error Stop Recorder" );
			return false;

		}
		mainHandler.post ( new Runnable ()
		{
			@Override
			public void run ()
			{

			}
		}
		);
		return true;
	}

	public void pauseRecorder ( final MethodCall call, final Result result )
	{
		if ( this.model.getMediaRecorder () == null )
		{
			Log.d ( TAG, "mediaRecorder is null" );
			result.error ( TAG, "Recorder is closed", "\"Recorder is closed\"" );
			return;
		}
		if ( Build.VERSION.SDK_INT < 24 )
		{
			result.error ( TAG, "Bad Android API level", "\"Pause/Resume needs at least Android API 24\"" );
		} else
		{
			stopTickerUpdates();
			this.model.getMediaRecorder().pause();
			result.success( "Recorder is paused");
		}
	}


	public void resumeRecorder ( final MethodCall call, final Result result )
	{
		if ( this.model.getMediaRecorder () == null )
		{
			Log.d ( TAG, "mediaRecorder is null" );
			result.error ( TAG, "Recorder is closed", "\"Recorder is closed\"" );
			return;
		}
		if ( Build.VERSION.SDK_INT < 24 )
		{
			result.error ( TAG, "Bad Android API level", "\"Pause/Resume needs at least Android API 24\"" );
		} else
		{
			// restart tickers.
			startTickerUpdates();
			this.model.getMediaRecorder().resume();
			result.success( true);
		}
	}



	public void setDbPeakLevelUpdate ( final MethodCall call, final Result result )
	{
		int interval = call.argument ( "milli" );
		this.model.peakLevelUpdateMillis = interval;
		result.success ( "setDbPeakLevelUpdate: " + this.model.peakLevelUpdateMillis );
	}

	public void setDbLevelEnabled ( final MethodCall call, final Result result )
	{
		boolean enabled = call.argument ( "enabled" );
		this.model.shouldProcessDbLevel = enabled;
		result.success ( "setDbLevelEnabled: " + this.model.shouldProcessDbLevel );
	}

	public void setSubscriptionInterval ( final MethodCall call, final Result result )
	{
		Log.d(TAG, "setSubscriptionInterval: " + call.argument("milli"));
		if ( call.argument ( "milli" ) == null )
		{
			return;
		}
		int duration = call.argument ( "milli" );

		this.model.subsDurationMillis =  duration;
		result.success ( "setSubscriptionInterval: " + this.model.subsDurationMillis );
	}


}
