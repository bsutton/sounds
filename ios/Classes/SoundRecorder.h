//
//  SoundRecorder.h
//  Pods
//
//  Created by larpoux on 24/03/2020.
//
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

#ifndef SoundRecorder_h
#define SoundRecorder_h


#import <Flutter/Flutter.h>
#import <AVFoundation/AVFoundation.h>
#import "Sounds.h"

extern void SoundRecorderReg(NSObject<FlutterPluginRegistrar>* registrar);


@interface SoundRecorderManager : NSObject<FlutterPlugin>
{
}

+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar;
- (void)handleMethodCall:(FlutterMethodCall*)call result:(FlutterResult)result;
- (void)invokeCallback: (NSString*)methodName arguments: (NSDictionary*)call;
- (void)freeSlot: (int)slotNo;
@end



@interface SoundRecorder : NSObject <AVAudioRecorderDelegate>
{
}

- (SoundRecorderManager*) getPlugin;
- (SoundRecorder*)init: (int)aSlotNo;
- (void)startRecorder :(FlutterMethodCall*)call result:(FlutterResult)result;
- (void)stopRecorder:(FlutterResult)result;
- (void)setDbPeakLevelUpdate:(long)intervalInMills result: (FlutterResult)result;
- (void)setDbLevelEnabled:(BOOL)enabled result: (FlutterResult)result;
- (void)initializeSoundRecorder : (FlutterMethodCall*)call result:(FlutterResult)result;
- (void)releaseSoundRecorder : (FlutterMethodCall*)call result:(FlutterResult)result;
- (void)setSubscriptionInterval:(long)intervalInMillis result: (FlutterResult)result;
- (void)pauseRecorder : (FlutterMethodCall*)call result:(FlutterResult)result;
- (void)resumeRecorder : (FlutterMethodCall*)call result:(FlutterResult)result;

@end

#endif /* SoundRecorder_h */
