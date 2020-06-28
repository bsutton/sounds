
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