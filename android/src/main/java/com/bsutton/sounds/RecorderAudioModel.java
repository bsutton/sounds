package com.bsutton.sounds;

import android.media.MediaRecorder;



class RecorderAudioModel
{
	public              int     subsDurationMillis    = 10;
	public              long    peakLevelUpdateMillis = 800;
	public              boolean shouldProcessDbLevel  = true;

	private      MediaRecorder mediaRecorder;

	// The time at which  the current recording was started.
	public       long          startTime;
	private      long          recordTime   = 0;
	public final double        micLevelBase = 2700;


	public MediaRecorder getMediaRecorder ()
	{
		return mediaRecorder;
	}

	public void setMediaRecorder ( MediaRecorder mediaRecorder )
	{
		this.mediaRecorder = mediaRecorder;
	}

	public long getRecordTime ()
	{
		return recordTime;
	}

	public void setRecordTime ( long recordTime )
	{
		this.recordTime = recordTime;
	}

}