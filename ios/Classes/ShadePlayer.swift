//  Converted to Swift 5.2 by Swiftify v5.2.19227 - https://swiftify.com/
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

import AVFoundation
import Flutter
import MediaPlayer



/*
 * flauto is a sounds module.
 * Its purpose is to offer higher level functionnalities, using MediaService/MediaBrowser.
 * This module may use sounds module, but sounds module may not depends on this module.
 */



/// Plays an audio track using the OSs on UI (sometimes referred to as a Shade) media
/// player.
/// Allows playback control even when the phone is locked.
private var _channel: FlutterMethodChannel?

func ShadePlayerReg(_ registrar: (NSObjectProtocol & FlutterPluginRegistrar)?) {
    ShadePlayerManager.register(withRegistrar: registrar)
}

var shadePlayerManager: ShadePlayerManager? // Singleton

class ShadePlayerManager: SoundPlayerManager {
    //NSMutableArray* ShadePlayerSlots;
    override class func register(withRegistrar registrar: (NSObjectProtocol & FlutterPluginRegistrar)?) {
        _channel = FlutterMethodChannel(
            name: "com.bsutton.sounds.sounds_shade_player",
            binaryMessenger: registrar?.messenger())
        shadePlayerManager = ShadePlayerManager() // In super class
        registrar?.addMethodCallDelegate(shadePlayerManager, channel: _channel)
    }

    override func freeSlot(_ slotNo: Int) {
        playerSlots?[slotNo] = NSNull()
    }

    override init() {
        super.init()
        playerSlots = []
    }

    override func invokeCallback(_ methodName: String?, arguments call: [AnyHashable : Any]?) {
        _channel?.invokeMethod(methodName, arguments: call)
    }

    override func getManager() -> SoundPlayerManager? {
        return shadePlayerManager
    }

    override func handle(_ call: FlutterMethodCall?, result: FlutterResult) {
        var slotNo = (call?.arguments["slotNo"] as? NSNumber)?.intValue ?? 0

        // The dart code supports lazy initialization of players.
        // This means that players can be registered (and slots allocated)
        // on the client side in a different order to which the players
        // are initialised.
        // As such we need to grow the slot array upto the 
        // requested slot no. even if we haven't seen initialisation
        // for the lower numbered slots.
        while slotNo >= (playerSlots?.count ?? 0) {
            playerSlots?.append(NSNull())
        }


        var aShadePlayer = playerSlots?[slotNo] as? ShadePlayer

        if "initializeMediaPlayer" == call?.method {
            assert(playerSlots?[slotNo] == NSNull())
            aShadePlayer = ShadePlayer(slotNo) as? ShadePlayer
            playerSlots?[slotNo] = aShadePlayer

            aShadePlayer?.initializeShadePlayer(call, result: result)
        } else if "releaseMediaPlayer" == call?.method {
            aShadePlayer?.release(call, result: result)
            playerSlots?[slotNo] = NSNull()
            slotNo = -1
        } else if "startShadePlayer" == call?.method {
            aShadePlayer?.start(call, result: result)
        } else {
            super.handle(call, result: result)
        }
    }
}

// post fix with _Sound to avoid conflicts with common libs including path_provider
private func GetDirectoryOfType_Sounds(_ dir: FileManager.SearchPathDirectory) -> String? {
    let paths = FileManager.default.urls(for: dir, in: .userDomainMask).map(\.path)
    return (paths.first ?? "") + "/"
}

class ShadePlayer: SoundPlayer {
    private var audioFileURL: URL?
    private var track: Track?
    private var forwardTarget: Any?
    private var backwardTarget: Any?
    private var pauseTarget: Any?
    private var setCategoryDone: t_SET_CATEGORY_DONE!
    private var setActiveDone: t_SET_CATEGORY_DONE!
    private var slotNo = 0

    convenience init?(_ aSlotNo: Int) {
        slotNo = aSlotNo
    }

    func start(_ call: FlutterMethodCall?, result: FlutterResult) {
        let trackDict = call?.arguments["track"] as? [AnyHashable : Any]
        track = Track(fromDictionary: trackDict)
        let canPause = (call?.arguments["canPause"] as? NSNumber)?.boolValue ?? false
        let canSkipForward = (call?.arguments["canSkipForward"] as? NSNumber)?.boolValue ?? false
        let canSkipBackward = (call?.arguments["canSkipBackward"] as? NSNumber)?.boolValue ?? false


        if track == nil {
            result(
                FlutterError(
                                code: "UNAVAILABLE",
                                message: "The track passed to startPlayer is not valid.",
                                details: nil))
        }


        // Check whether the audio file is stored as a path to a file or a buffer
        if track?.isUsingPath() ?? false {
            // The audio file is stored as a path to a file

            let path = track?.path

            var isRemote = false
            // Check whether a path was given
            if NSString.self == NSNull.self {
                // No path was given, get the path to a default sound
                audioFileURL = URL(fileURLWithPath: (GetDirectoryOfType_Sounds(.cachesDirectory) ?? "") + "sound.aac")
                // This file name is not good. Perhaps the MediaFormat is not AAC. !
            } else {
                // A path was given, then create a NSURL with it
                let remoteUrl = URL(string: path ?? "")

                // Check whether the URL points to a local or remote file
                if remoteUrl != nil && remoteUrl?.scheme != nil && remoteUrl?.host != nil {
                    audioFileURL = remoteUrl
                    isRemote = true
                } else {
                    audioFileURL = URL(string: path ?? "")
                }
            }

            // Able to play in silent mode
            if setCategoryDone == .not_SET {
                do {
                    try AVAudioSession.sharedInstance().setCategory(
                        .playback)
                } catch {
                }
                setCategoryDone = .for_PLAYING
            }

            // Able to play in background
            if setActiveDone == .not_SET {
                do {
                    try AVAudioSession.sharedInstance().setActive(true)
                } catch {
                }
                setActiveDone = .for_PLAYING
            }

            isPaused = false

            // Check whether the file path points to a remote or local file
            if isRemote {
                var downloadTask: URLSessionDataTask? = nil
                if let audioFileURL = audioFileURL {
                    downloadTask = URLSession.shared.dataTask(
                        with: audioFileURL,
                        completionHandler: { data, response, error in
                            // The file to play has been downloaded, then initialize the audio player
                            // and start playing.

                            // We must create a new Audio Player instance to be able to play a different Url
                            do {
                                if let data = data {
                                    self.audioPlayer = try AVAudioPlayer(data: data)
                                }
                            } catch {
                            }
                            self.audioPlayer.delegate = self

                            DispatchQueue.main.async(execute: {
                                UIApplication.shared.beginReceivingRemoteControlEvents()
                            })

                            self.audioPlayer.play()
                        })
                }

                downloadTask?.resume()
                startProgressTimer()
                let filePath = audioFileURL?.absoluteString
                result(filePath)
            } else {
                // Initialize the audio player with the file that the given path points to,
                // and start playing.

                // if (!audioPlayer) { // Fix sound distoring when playing recorded audio again.
                do {
                    if let audioFileURL = audioFileURL {
                        audioPlayer = try AVAudioPlayer(contentsOf: audioFileURL)
                    }
                } catch {
                }
                audioPlayer?.delegate = self
                // }

                // Able to play in silent mode
                DispatchQueue.main.async(
                    execute: {
                        UIApplication.shared.beginReceivingRemoteControlEvents()
                    })

                audioPlayer?.play()
                startProgressTimer()
                let filePath = audioFileURL?.absoluteString
                result(filePath)
            }
        } else {
            // The audio file is stored as a buffer
            let dataBuffer = track?.dataBuffer
            let bufferData = dataBuffer?.init()
            do {
                if let bufferData = bufferData {
                    audioPlayer = try AVAudioPlayer(data: bufferData)
                }
            } catch {
            }
            audioPlayer?.delegate = self
            DispatchQueue.main.async(
                execute: {
                    UIApplication.shared.beginReceivingRemoteControlEvents()
                })
            audioPlayer?.play()
            startProgressTimer()
            result("Playing from buffer")
        }
        //[ self invokeCallback:@"updatePlaybackState" arguments:playingState];

        // Display the notification with the media controls
        setupRemoteCommandCenter(canPause, canSkipForward: canSkipForward, canSkipBackward: canSkipBackward, result: result)
        setupNowPlaying()

    }

    func initializeShadePlayer(_ call: FlutterMethodCall?, result: FlutterResult) {
        setCategoryDone = .not_SET
        setActiveDone = .not_SET
        result(NSNumber(value: true))
    }

    func release(_ call: FlutterMethodCall?, result: FlutterResult) {
        // The code used to release all the media player resources is the same of the one needed
        // to stop the media playback. Then, use that one.
        // [self stopRecorder:result];
        stop()
        let commandCenter = MPRemoteCommandCenter.shared()
        if pauseTarget != nil {
            if let pauseTarget = pauseTarget {
                commandCenter.togglePlayPauseCommand.removeTarget(pauseTarget, action: nil)
            }
            pauseTarget = nil
        }
        if forwardTarget != nil {
            if let forwardTarget = forwardTarget {
                commandCenter.nextTrackCommand.removeTarget(forwardTarget, action: nil)
            }
            forwardTarget = nil
        }

        if backwardTarget != nil {
            if let backwardTarget = backwardTarget {
                commandCenter.previousTrackCommand.removeTarget(backwardTarget, action: nil)
            }
            backwardTarget = nil
        }

        getPlugin()?.freeSlot(slotNo)
        result("The player has been successfully released")

    }

    override func getPlugin() -> SoundPlayerManager? {
        return shadePlayerManager
    }

    override func invokeCallback(_ methodName: String?, stringArg: String?) {
        let dic = [
            "slotNo": NSNumber(value: Int32(slotNo)),
            "arg": stringArg ?? ""
        ]
        getPlugin()?.invokeCallback(methodName, arguments: dic)
    }

    func invokeCallback(_ methodName: String?, boolArg: Bool) {
        let dic = [
            "slotNo": NSNumber(value: Int32(slotNo)),
            "arg": NSNumber(value: boolArg)
        ]
        getPlugin()?.invokeCallback(methodName, arguments: dic)
    }

    // Give the system information about what the audio player
    // is currently playing. Takes in the image to display in the
    // notification to control the media playback.
    func setupNowPlaying() {
        // Initialize the MPNowPlayingInfoCenter

        let playingInfoCenter = MPNowPlayingInfoCenter.default()
        var songInfo: [AnyHashable : Any] = [:]
        // The caller specify an asset to be used.
        // Probably good in the future to allow the caller to specify the image itself, and not a resource.
        if (track?.albumArtUrl != nil) && (NSString.self != NSNull.self) {
            // Retrieve the album art for the
            // current track .
            let url = URL(string: track?.albumArtUrl ?? "")
            var artworkImage: UIImage? = nil
            if let url = url, let data = Data(contentsOf: url) {
                artworkImage = UIImage(data: data)
            }
            if artworkImage != nil {
                let albumArt = MPMediaItemArtwork(
                    boundsSize: artworkImage?.size ?? CGSize.zero,
                    requestHandler: { size in
                        return artworkImage!
                    })

                songInfo[MPMediaItemPropertyArtwork] = albumArt
            }
        } else if (track?.albumArtAsset) != nil && (NSString.self != NSNull.self) {
            let artworkImage = UIImage(named: track?.albumArtAsset ?? "")
            if artworkImage != nil {
                let albumArt = MPMediaItemArtwork(
                    boundsSize: artworkImage?.size ?? CGSize.zero,
                    requestHandler: { size in
                        return artworkImage!
                    })

                songInfo[MPMediaItemPropertyArtwork] = albumArt
            }
        } else if (track?.albumArtFile) != nil && (NSString.self != NSNull.self) {
            let artworkImage = UIImage(contentsOfFile: track?.albumArtFile ?? "")
            if artworkImage != nil {
                let albumArt = MPMediaItemArtwork(
                    boundsSize: artworkImage?.size ?? CGSize.zero,
                    requestHandler: { size in
                        return artworkImage!
                    })
                songInfo[MPMediaItemPropertyArtwork] = albumArt
            }
        } else {
            let artworkImage = UIImage(named: "AppIcon")
            if artworkImage != nil {
                let albumArt = MPMediaItemArtwork(
                    boundsSize: artworkImage?.size ?? CGSize.zero,
                    requestHandler: { size in
                        return artworkImage!
                    })
                songInfo[MPMediaItemPropertyArtwork] = albumArt
            }
        }

        let progress = NSNumber(value: audioPlayer?.currentTime ?? 0.0)
        let duration = NSNumber(value: audioPlayer?.duration ?? 0.0)

        songInfo[MPMediaItemPropertyTitle] = track?.title
        songInfo[MPMediaItemPropertyArtist] = track?.artist
        songInfo[MPNowPlayingInfoPropertyElapsedPlaybackTime] = progress
        songInfo[MPMediaItemPropertyPlaybackDuration] = duration
        let b = audioPlayer?.isPlaying ?? false
        songInfo[MPNowPlayingInfoPropertyPlaybackRate] = NSNumber(value: b ? 1.0 : 0.0)

        playingInfoCenter.nowPlayingInfo = songInfo as? [String : Any]
    }

    func cleanTarget(_ canPause: Bool, canSkipForward: Bool, canSkipBackward: Bool) {
        // [commandCenter.playCommand setEnabled:YES];
        // [commandCenter.pauseCommand setEnabled:YES];
        //   [commandCenter.playCommand addTargetWithHandler: ^MPRemoteCommandHandlerStatus(MPRemoteCommandEvent * _Nonnull event) {
        //       // [[MediaController sharedInstance] playOrPauseMusic];    // Begin playing the current track.
        //       [self resumePlayer:result];
        //       return MPRemoteCommandHandlerStatusSuccess;
        //   }];
        //
        //   [commandCenter.pauseCommand addTargetWithHandler: ^MPRemoteCommandHandlerStatus(MPRemoteCommandEvent * _Nonnull event) {
        //       // [[MediaController sharedInstance] playOrPauseMusic];    // Begin playing the current track.
        //       [self pausePlayer:result];
        //       return MPRemoteCommandHandlerStatusSuccess;
        //   }];
        let commandCenter = MPRemoteCommandCenter.shared()

        if pauseTarget != nil {
            if let pauseTarget = pauseTarget {
                commandCenter.togglePlayPauseCommand.removeTarget(pauseTarget, action: nil)
            }
            pauseTarget = nil
        }
        if forwardTarget != nil {
            if let forwardTarget = forwardTarget {
                commandCenter.nextTrackCommand.removeTarget(forwardTarget, action: nil)
            }
            forwardTarget = nil
        }

        if backwardTarget != nil {
            if let backwardTarget = backwardTarget {
                commandCenter.previousTrackCommand.removeTarget(backwardTarget, action: nil)
            }
            backwardTarget = nil
        }
        commandCenter.togglePlayPauseCommand.isEnabled = true // If the caller does not want to control pause button, we will use our default action
        commandCenter.nextTrackCommand.isEnabled = canSkipForward
        commandCenter.previousTrackCommand.isEnabled = canSkipBackward

        do {
            pauseTarget = commandCenter.togglePlayPauseCommand.addTarget(handler: { event in

                let b = self.audioPlayer.isPlaying
                // If the caller wants to control the pause button, just call him
                if b {
                    if canPause {
                        self.invokeCallback("pause", boolArg: true)
                    } else {
                        self.pause()
                    }
                } else {
                    if canPause {
                        self.invokeCallback("resume", boolArg: true)
                    } else {
                        self.resume()
                    }
                }
                return .success
            })
        }

        if canSkipForward {
            forwardTarget = commandCenter.nextTrackCommand.addTarget(handler: { event in
                self.invokeCallback("skipForward", stringArg: "")
                // [[MediaController sharedInstance] fastForward];    // forward to next track.
                return .success
            })
        }

        if canSkipBackward {
            backwardTarget = commandCenter.previousTrackCommand.addTarget(handler: { event in
                self.invokeCallback("skipBackward", stringArg: "")
                // [[MediaController sharedInstance] rewind];    // back to previous track.
                return .success
            })
        }
    }

    override func stop() {
        stopProgressTimer()
        isPaused = false
        if audioPlayer != nil {
            audioPlayer?.stop()
            //audioPlayer = nil;
        }
        // ????  [self cleanTarget:false canSkipForward:false canSkipBackward:false];
        if (setActiveDone != .by_USER /* The caller did it himself : Sounds must not change that) */) && (setActiveDone != .not_SET) {
            cleanTarget(false, canSkipForward: false, canSkipBackward: false) // ???
            do {
                try AVAudioSession.sharedInstance().setActive(false)
            } catch {
            }
            setActiveDone = .not_SET
        }
    }

    // Give the system information about what to do when the notification
    // control buttons are pressed.
    func setupRemoteCommandCenter(_ canPause: Bool, canSkipForward: Bool, canSkipBackward: Bool, result: FlutterResult) {
        cleanTarget(canPause, canSkipForward: canSkipForward, canSkipBackward: canSkipBackward)
    }
}

//---------------------------------------------------------------------------------------------

//---------------------------------------------------------------------------------------------