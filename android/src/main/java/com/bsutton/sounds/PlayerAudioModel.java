
import android.Manifest;
import android.app.Activity;
import android.content.Context;
import android.content.pm.PackageManager;
import android.media.MediaPlayer;
import android.media.MediaRecorder;
import android.media.AudioManager;
import android.os.Build;
import android.os.Environment;
import android.os.Handler;
import android.os.SystemClock;
import android.support.v4.media.MediaMetadataCompat;
import android.support.v4.media.session.PlaybackStateCompat;
import android.util.Log;

import androidx.annotation.NonNull;
import androidx.annotation.UiThread;
import androidx.arch.core.util.Function;
import androidx.core.app.ActivityCompat;

import android.media.AudioFocusRequest;

import java.io.*;

import org.json.JSONException;
import org.json.JSONObject;

import java.io.File;
import java.io.FileOutputStream;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Timer;
import java.util.TimerTask;
import java.util.concurrent.Callable;
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

import java.util.concurrent.Callable;

import io.flutter.plugin.common.PluginRegistry;
import io.flutter.plugin.common.PluginRegistry.Registrar;

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
