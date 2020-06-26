//
//  Sounds.m
//  flauto
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



#import "Sounds.h"
#import "SoundPlayer.h"
#import "SoundRecorder.h"
#import "ShadePlayer.h"
#import <AVFoundation/AVFoundation.h>
#import <Foundation/Foundation.h>


@implementation Sounds
{
}


+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar
{
        SoundPlayerReg(registrar);
        SoundRecorderReg(registrar);
        ShadePlayerReg(registrar);
}

@end
