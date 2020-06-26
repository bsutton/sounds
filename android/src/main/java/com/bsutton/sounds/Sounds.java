package com.bsutton.sounds;
import java.util.concurrent.CountDownLatch;


/*
 * This file is part of Sounds (Sounds).
 *
 *   Sounds (Sounds) is free software: you can redistribute it and/or modify
 *   it under the terms of the Lesser GNU General Public License
 *   version 3 (LGPL3) as published by the Free Software Foundation.
 *
 *   Sounds (Sounds) is distributed in the hope that it will be useful,
 *   but WITHOUT ANY WARRANTY; without even the implied warranty of
 *   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *   GNU General Public License for more details.
 *
 *   You should have received a copy of the Lesser GNU General Public License
 *   along with Sounds (Sounds).  If not, see <https://www.gnu.org/licenses/>.
 */

import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.embedding.engine.plugins.activity.ActivityAware;

import android.app.Activity;
import android.content.Context;

import androidx.annotation.NonNull;


import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding;
import io.flutter.plugin.common.PluginRegistry.Registrar;


// this enum MUST be synchronized with lib/sounds.dart and ios/Classes/SoundsPlugin.h
enum t_CODEC
{
  	  DEFAULT
  	, AAC
  	, OPUS
  	, CODEC_CAF_OPUS // Apple encapsulates its bits in its own special envelope : .caf instead of a regular ogg/opus (.opus). This is completely stupid, this is Apple.
  	, MP3
  	, VORBIS
  	, PCM
}

public class Sounds
	implements FlutterPlugin,
	           ActivityAware
{
    public static final boolean FULL_FLAVOR = true;
	static Context ctx;
	static Registrar reg;
	static Activity androidActivity;

	/// latch to control access until we have been full initialised.
	/// This class supports v1 and v2 of the flutter embedding so there
	/// are two ways we can be initialised. 
	/// Both paths drop the latch.
	static CountDownLatch initialised = new CountDownLatch(1);
	

	/**
	 * v2 Plugin Sounds.
	 * 
	 * Only called on new systems
	 * 
	 * see:
	 * https://flutter.dev/docs/development/packages-and-plugins/plugin-api-migration
	 */
	@Override
	public void onAttachedToEngine ( FlutterPlugin.FlutterPluginBinding binding )
	{
		ctx = binding.getApplicationContext ();

		SoundPlayerPlugin.attachSoundPlayer ( ctx, binding.getBinaryMessenger () );
		SoundRecorderPlugin.attachSoundRecorder ( ctx, binding.getBinaryMessenger () );
		ShadePlayerPlugin.attachShadePlayer ( ctx, binding.getBinaryMessenger () );
	}


	/**
	 *  v1 Plugin Sounds.
	 * 
	 *  Only called on older systems.
	 */
	public static void registerWith ( Registrar registrar )
	{
		reg = registrar;
		ctx = registrar.context ();
		androidActivity = registrar.activity ();

		SoundPlayerPlugin.attachSoundPlayer ( ctx, registrar.messenger () );
		SoundRecorderPlugin.attachSoundRecorder ( ctx, registrar.messenger ()  );
		ShadePlayerPlugin.attachShadePlayer ( ctx, registrar.messenger ()  );
		
		/// We are fully initialised for v1 embedding
		initialised.countDown();

	}


	@Override
	public void onDetachedFromEngine ( FlutterPlugin.FlutterPluginBinding binding )
	{
	}

	@Override
	public void onDetachedFromActivity ()
	{
	}

	@Override
	public void onReattachedToActivityForConfigChanges (
		@NonNull
			ActivityPluginBinding binding
	                                                   )
	{

	}

	@Override
	public void onDetachedFromActivityForConfigChanges ()
	{

	}

	@Override
	public void onAttachedToActivity (
		@NonNull
			ActivityPluginBinding binding
	                                 )
	{
		androidActivity = binding.getActivity ();

		/// We are fully initialised for v2 embedding
		initialised.countDown();
	}
}
