# iOSCategory

### TODO this section needs reviewing as I don't think it is correct it also breaks our stated purpose of being OS agnostic.

### The android documentation states that requestFocus should be called on the play\(\) callback which we do by default.

Before controlling the focus with `requestFocs()` you must call `iosSetCategory()` on iOS or `androidAudioFocusRequest()` on Android. `requesFocus()` and `androidAudioFocusRequest()` are useful if you want to `hush others` \(in android terminology duck others\). Those functions are probably called just once when the app starts. After calling this function, the caller is calling `requestFocus()/abandonFocus() as required`.

You can refer to [iOS documentation](https://developer.apple.com/documentation/avfoundation/avSoundPlayer/1771734-setcategory) to understand the parameters needed for `iosSetCategory()` and to the [Android documentation](https://developer.android.com/reference/android/media/AudioFocusRequest) to understand the parameter needed for `androidAudioFocusRequest()`.

Remark : those three functions do NOT work on Android before SDK 26.

Note: these platform specific methods are under review with the intent to remove any/all platform specific elements to the api.

```text
if (_hushOthers)
{
	if (Platform.isIOS)
		await player.iosSetCategory( t_IOS_SESSION_CATEGORY.PLAY_AND_RECORD, t_IOS_SESSION_MODE.DEFAULT, IOS_DUCK_OTHERS |  IOS_DEFAULT_TO_SPEAKER );
	else if (Platform.isAndroid)
		await player.androidAudioFocusRequest( ANDROID_AUDIOFOCUS_GAIN_TRANSIENT_MAY_DUCK );
} else
{
	if (Platform.isIOS)
		await player.iosSetCategory( t_IOS_SESSION_CATEGORY.PLAY_AND_RECORD, t_IOS_SESSION_MODE.DEFAULT, IOS_DEFAULT_TO_SPEAKER );
	else if (Platform.isAndroid)
		await player.androidAudioFocusRequest( ANDROID_AUDIOFOCUS_GAIN );
}
...
```

