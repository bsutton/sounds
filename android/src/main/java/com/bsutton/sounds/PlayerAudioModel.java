package com.bsutton.sounds;

import android.media.MediaPlayer;

import java.time.Duration;

class PlayerAudioModel {

	/**
	 * The interval between each progress event being sent.
	 */
	public Duration progressInterval = Duration.ofMillis(100);

	private MediaPlayer mediaPlayer;
	private long playTime = 0;

	public MediaPlayer getMediaPlayer() {
		return mediaPlayer;
	}

	public void setMediaPlayer(MediaPlayer mediaPlayer) {
		this.mediaPlayer = mediaPlayer;
	}

	public long getPlayTime() {
		return playTime;
	}

	public void setPlayTime(long playTime) {
		this.playTime = playTime;
	}
}
