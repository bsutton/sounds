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

import android.media.MediaRecorder;
import android.os.Build;
import android.os.Handler;
import android.os.SystemClock;
import android.util.Log;

import androidx.annotation.UiThread;

import java.time.Duration;
import java.util.concurrent.ExecutorService;
import java.util.concurrent.Executors;

import static com.bsutton.sounds.ErrorCodes.errnoInvalidArgument;

public class SoundRecorder extends SoundsProxy {
	static final String TAG = "SoundRecorder";
	static final String ERR_UNKNOWN = "ERR_UNKNOWN";

	static final String ERR_RECORDER_IS_NULL = "ERR_RECORDER_IS_NULL";
	static final String ERR_RECORDER_IS_RECORDING = "ERR_RECORDER_IS_RECORDING";

	final RecorderAudioModel model = new RecorderAudioModel();
	final public Handler progressTickHandler = new Handler();

	int slotNo;
	private final ExecutorService taskScheduler = Executors.newSingleThreadExecutor();
	private Handler mainHandler = new Handler();

	SoundsPlatformApi.SoundRecorderProxy recorderProxy;
	/// The current track we are recording to.
	SoundsPlatformApi.TrackProxy trackProxy;

	void initializeSoundRecorder(SoundsPlatformApi.SoundRecorderProxy proxy) {
		this.recorderProxy = proxy;
	}

	@Override
	public void dispose() {
		try {
			releaseSoundRecorder();
		} catch (SoundsException e) {
			Log.e(TAG, "Error disposing of a SoundRecorder " + e.getMessage());
		}
	}
	void releaseSoundRecorder() throws SoundsException {
		stopRecorder();

	}

	public void startRecorder(SoundsPlatformApi.AudioSourceProxy audioSource, SoundsPlatformApi.TrackProxy track) throws SoundsException {
		this.trackProxy = track;
		SoundsPlatformApi.MediaFormatProxy mediaFormatProxy =track.getMediaFormat();
		int numChannels = mediaFormatProxy.getNumChannels().intValue();
		int sampleRate = mediaFormatProxy.getSampleRate().intValue();
		int bitRate = mediaFormatProxy.getBitRate().intValue();
		String name = mediaFormatProxy.getName();
		final int v = Build.VERSION.SDK_INT;
		MediaRecorder mediaRecorder = model.getMediaRecorder();

		if (mediaRecorder == null) {
			mediaRecorder = new MediaRecorder();
			model.setMediaRecorder(mediaRecorder);
		}

		String path = track.getPath();
		try {
			if (path == null) {
				throw new SoundsException(errnoInvalidArgument, "The Track contained a null path");
			}

			mediaRecorder.reset();
			try {
				mediaRecorder.setAudioSource(audioSource.getAudioSource().intValue());
			} catch (RuntimeException e) {

				throw new SoundsException(ErrorCodes.errnoAudioSourcePermissionDenied,
						"Error setting the AudioSource. Check that you have permission to use the microphone.");
			}
			AndroidMediaFormat mediaFormat = AndroidMediaFormat.generate(mediaFormatProxy);
			mediaRecorder.setOutputFormat(mediaFormat.format);
			mediaRecorder.setOutputFile(path);
			mediaRecorder.setAudioEncoder(mediaFormat.encoder);
			mediaRecorder.setAudioChannels(numChannels);
			mediaRecorder.setAudioSamplingRate(sampleRate);
			mediaRecorder.setAudioEncodingBitRate(bitRate);

			mediaRecorder.prepare();
			mediaRecorder.start();

			this.model.startTime = SystemClock.elapsedRealtime();
			startProgressTimer();


		} catch (Exception e) {
			Log.e(TAG, "Exception: ", e);

			try {
				/// we try to clean up by stopping the recorder.
				stopRecorder();
			} catch (Exception e2) {
			}
			throw new SoundsException(ErrorCodes.errnoGeneral,  "Error starting recorder" +  e.getMessage());
		}
	}

	public void stopRecorder() throws SoundsException {
		// This removes all pending runnables
		stopProgressTimer();

		if (this.model.getMediaRecorder() == null) {
			Log.d(TAG, "mediaRecorder is null");
			throw new SoundsException(ErrorCodes.errnoNotRecording, "The MediaRecorder was null");
		}
		try {
			if (Build.VERSION.SDK_INT >= 24) {

				try {
					this.model.getMediaRecorder().resume(); // This is required as we cannot stop if we are paused.
				} catch (Exception e) {
				}
			}
			this.model.getMediaRecorder().stop();
			this.model.getMediaRecorder().reset();
			this.model.getMediaRecorder().release();
			this.model.setMediaRecorder(null);
		} catch (Exception e) {
			Log.d(TAG, "Error Stop Recorder");
			throw new SoundsException(ErrorCodes.errnoGeneral, "An error occured trying to stop the recorder " + e.getCause().getClass().getSimpleName()
			 + " "  + e.getMessage());
		}
	}

	public void pauseRecorder() throws SoundsException {
		if (this.model.getMediaRecorder() == null) {
			Log.d(TAG, "mediaRecorder is null");
			throw new SoundsException(ErrorCodes.errnoNotRecording, "The MediaRecorder was null");
		}
		if (Build.VERSION.SDK_INT < 24) {
			throw new SoundsException(ErrorCodes.errnoNotSupported, "Pause/Resume needs at least Android API 24");
		} else {
			stopProgressTimer();
			this.model.getMediaRecorder().pause();
		}
	}

	public void resumeRecorder() throws SoundsException {
		if (this.model.getMediaRecorder() == null) {
			Log.d(TAG, "mediaRecorder is null");
			throw new SoundsException(ErrorCodes.errnoNotRecording, "The MediaRecorder was null");
		}
		if (Build.VERSION.SDK_INT < 24) {
			throw new SoundsException(ErrorCodes.errnoNotSupported, "Pause/Resume needs at least Android API 24");
		} else {
			// restart tickers.
			startProgressTimer();
			this.model.getMediaRecorder().resume();
		}
	}

	/*********************************************
	 * 
	 * Progress and DbPeak level updates
	 *
	 *********************************************/

	// Starts the progress ticker if required.
	private void startProgressTimer() {
		// make certain no tickers are currently running.
		stopProgressTimer();
		progressTickHandler.post(() -> sendRecordingUpdate());
	}

	// stops the progress and Db level tickers.
	private void stopProgressTimer() {
		progressTickHandler.removeCallbacksAndMessages(null);
	}

	// Gets the current Db peak level.
	private double getDbLevel() {
		double db = 0;

		MediaRecorder recorder = model.getMediaRecorder();
		if (recorder != null) {
			double maxAmplitude = recorder.getMaxAmplitude();
			if (maxAmplitude != 0.0) {
				// Calculate db based on the following article.
				// https://stackoverflow.com/questions/10655703/what-does-androids-getmaxamplitude-function-for-the-mediarecorder-actually-gi
				//
				double ref_pressure = 51805.5336;
				double p = maxAmplitude / ref_pressure;
				double p0 = 0.0002;

				db = 20.0 * Math.log10(p / p0);
			}
		}
		return db;
	}

	// Sends a progress update to the dart code containing the current_position and
	// the Db Level
	// This method then re-queues itself.
	@UiThread
	private void sendRecordingUpdate() {
		try {

			SoundsPlatformApi.OnRecordingProgress args = new SoundsPlatformApi.OnRecordingProgress();
			args.setRecorder(recorderProxy);
			args.setTrack(trackProxy);
			long elapsed = SystemClock.elapsedRealtime() - model.startTime;
			args.setDuration(elapsed);
			args.setDecibels(getDbLevel());

			new SoundsPlatformApi.SoundsFromPlatformApi(SoundsPlugin.getBinaryMessenger()).onRecordingProgress(args, null);
			// reschedule ourselves.
			progressTickHandler.postDelayed(() -> sendRecordingUpdate(), this.model.progressInterval.toMillis());
		} catch (Exception e) {
			Log.d(TAG, "Exception: " + e.toString());
		}
	}

	public void setProgressInterval(Duration interval) {
		this.model.progressInterval = interval;
	}


}
