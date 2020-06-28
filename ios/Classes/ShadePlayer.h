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
 
#ifndef ShadePlayer_h
#define ShadePlayer_h


#import <Flutter/Flutter.h>
#import "SoundPlayer.h"

extern void ShadePlayerReg(NSObject<FlutterPluginRegistrar>* registrar);



@interface ShadePlayerManager : SoundPlayerManager
{
}

+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar;
- (void)freeSlot: (int)slotNo;
@end


@interface ShadePlayer : SoundPlayer
{

}
- (ShadePlayer*)init: (int)aSlotNo;
- (void)startShadePlayer:(FlutterMethodCall*)call result: (FlutterResult)result;
- (void)initializeShadePlayer: (FlutterMethodCall*)call result: (FlutterResult)result;
- (void)releaseShadePlayer:(FlutterMethodCall *)call result:(FlutterResult)result;
@end

#endif // ShadePlayer_h
