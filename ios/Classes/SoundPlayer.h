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


extern void SoundPlayerReg( NSObject<FlutterPluginRegistrar>* _Nonnull   registrar);


// Slots to track method calls from the dart into ios code.
// These slots are shared by the SoundPlayer and the ShadePlayer.
extern NSMutableArray* _Nullable playerSlots;


@interface SoundPlayerManager : NSObject<FlutterPlugin>
{
}

+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*_Nonnull)registrar;
- (void)handleMethodCall:(FlutterMethodCall*_Nonnull)call result:(FlutterResult _Nonnull )result;
- (void)invokeCallback: (NSString*_Nonnull)methodName arguments: (NSDictionary *_Nullable)call;
- (void)freeSlot: (int)slotNo;
- (void)getDuration: (NSString*_Nonnull)path callbackUuid:(NSString*_Nonnull)callbackUuid  result:(FlutterResult _Nonnull )result;
@end

@interface SoundPlayer : NSObject <AVAudioPlayerDelegate>
{
        AVAudioPlayer *audioPlayer;
        bool isPaused ;
        t_SET_CATEGORY_DONE setCategoryDone;
        t_SET_CATEGORY_DONE setActiveDone;
}

- (SoundPlayerManager*_Nonnull) getPlugin;
- (SoundPlayer*_Nonnull)init: (int)aSlotNo;

- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *_Nonnull)player successfully:(BOOL)flag;
- (void)updateProgress:(NSTimer *_Nullable)timer;
- (void)startTimer;
- (void)stopPlayer;
- (void)pausePlayer:(FlutterResult _Nonnull )result;
- (void)resumePlayer:(FlutterResult _Nonnull )result;
- (void)stopTimer;
- (void)pause;
- (bool)resume;
- (void)startPlayer:(NSString*_Nonnull)path result: (FlutterResult _Nonnull )result;
- (void)startPlayerFromBuffer:(FlutterStandardTypedData*_Nonnull)dataBuffer result: (FlutterResult _Nonnull )result;
- (void)seekToPlayer:(long) positionInMilli result: (FlutterResult _Nonnull )result;
- (void)setSubscriptionInterval:(long)intervalInMilli result: (FlutterResult _Nonnull )result;
- (void)setVolume:(double) volume result: (FlutterResult _Nonnull )result;
- (void)setCategory: (NSString*_Nonnull)categ mode:(NSString* _Nullable)mode options:(int)options result:(FlutterResult _Nonnull )result;
- (void)setActive:(BOOL)enabled result:(FlutterResult _Nonnull )result;
- (void)initializeSoundPlayer: (FlutterMethodCall*_Nonnull)call result: (FlutterResult _Nonnull )result;
- (void)releaseSoundPlayer: (FlutterMethodCall*_Nonnull)call result: (FlutterResult _Nonnull )result;

@end


