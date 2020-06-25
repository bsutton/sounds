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

#import <Flutter/Flutter.h>
#import <AVFoundation/AVFoundation.h>
#import "Sounds.h"


/*

typedef enum
{
        IS_STOPPED,
        IS_PLAYING,
        IS_PAUSED,
        IS_RECORDING,
} t_AUDIO_STATE;
*/

extern void SoundPlayerReg(_Nullable NSObject<FlutterPluginRegistrar>* registrar);
extern NSMutableArray* flautoPlayerSlots;


@interface SoundPlayerManager : NSObject<FlutterPlugin>
{
}

+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar;
- (void)handleMethodCall:(FlutterMethodCall*)call result:(FlutterResult)result;
- (void)invokeMethod: (NSString*)methodName arguments: (NSDictionary*)call;
- (void)freeSlot: (int)slotNo;
@end

@interface SoundPlayer : NSObject <AVAudioPlayerDelegate>
{
        AVAudioPlayer *audioPlayer;
        bool isPaused ;
        t_SET_CATEGORY_DONE setCategoryDone;
        t_SET_CATEGORY_DONE setActiveDone;
}

- (SoundPlayerManager*) getPlugin;
- (SoundPlayer*)init: (int)aSlotNo;

- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag;
- (void)updateProgress:(NSTimer *)timer;
- (void)startTimer;
- (void)stopPlayer;
- (void)pausePlayer:(FlutterResult)result;
- (void)resumePlayer:(FlutterResult)result;
- (void)stopTimer;
- (void)pause;
- (bool)resume;
- (void)startPlayer:(NSString*)path result: (FlutterResult)result;
- (void)startPlayerFromBuffer:(FlutterStandardTypedData*)dataBuffer result: (FlutterResult)result;
- (void)seekToPlayer:(long) positionInMilli result: (FlutterResult)result;
- (void)setSubscriptionInterval:(long)intervalInMilli result: (FlutterResult)result;
- (void)setVolume:(double) volume result: (FlutterResult)result;
- (void)setCategory: (NSString*)categ mode:(NSString*)mode options:(int)options result:(FlutterResult)result;
- (void)setActive:(BOOL)enabled result:(FlutterResult)result;
- (void)initializeSoundPlayer: (FlutterMethodCall*)call result: (FlutterResult)result;
- (void)releaseSoundPlayer: (FlutterMethodCall*)call result: (FlutterResult)result;
@end


