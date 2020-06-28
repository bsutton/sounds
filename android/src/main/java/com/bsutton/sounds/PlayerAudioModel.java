package com.bsutton.sounds;

import android.media.MediaPlayer;

class PlayerAudioModel
{
	public              int    subsDurationMillis    = 10;

	private MediaPlayer mediaPlayer;
	private long        playTime = 0;


	public MediaPlayer getMediaPlayer ()
	{
		return mediaPlayer;
	}

	public void setMediaPlayer ( MediaPlayer mediaPlayer )
	{
		this.mediaPlayer = mediaPlayer;
	}

	public long getPlayTime ()
	{
		return playTime;
	}

	public void setPlayTime ( long playTime )
	{
		this.playTime = playTime;
	}
}
