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

// Slots to track method calls from the dart into ios code.
// These slots are shared by the SoundPlayer and the ShadePlayer.private var _channel: FlutterMethodChannel?
var playerSlots: [AnyHashable]?

var soundPlayerManager: SoundPlayerManager? // Singleton

func SoundPlayerReg(_ registrar: FlutterPluginRegistrar) {
    SoundPlayerManager.register(with: registrar)
}


class SoundPlayerManager: NSObject, FlutterPlugin {
    public var _channel = FlutterMethodChannel()
    
    func setChannel(channel: FlutterMethodChannel){
        _channel = channel
    }
    class func register(with registrar: FlutterPluginRegistrar) {
       let channel = FlutterMethodChannel(
         name: "com.bsutton.sounds.sound_player",
         binaryMessenger: registrar.messenger())
        assert(soundPlayerManager == nil)
        soundPlayerManager = SoundPlayerManager()
        soundPlayerManager!.setChannel(channel: channel)
        registrar.addMethodCallDelegate(soundPlayerManager!, channel: channel)

    }

    func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        let args = call.arguments as! Dictionary<String, Any>
        let slotNo = (args["slotNo"] as? NSNumber)?.intValue ?? 0
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

        var aSoundPlayer = playerSlots?[slotNo] as? SoundPlayer
        if "initializeMediaPlayer" == call.method {
            assert(playerSlots?[slotNo] == nil)
            aSoundPlayer = SoundPlayer(aSlotNo: slotNo)
            playerSlots?[slotNo] = aSoundPlayer
            aSoundPlayer?.initializeSoundPlayer(call, result: result)
        } else if "releaseMediaPlayer" == call.method {
            aSoundPlayer?.release(call, result: result)
            playerSlots?[slotNo] = NSNull()
            playerSlots?[slotNo] = NSNull()
        } else if "getDuration" == call.method {
            //assert(args != nil)
            let path = args["path"] as! String
            let callbackUuid = args["callbackUuid"] as? String
            soundPlayerManager?.getDuration(path, callbackUuid: callbackUuid, slotNo: slotNo, result: result)
        } else if "startPlayer" == call.method {
            let path = args["path"] as? String
            aSoundPlayer?.start(path, result: result)
        } else if "startPlayerFromBuffer" == call.method {
            let dataBuffer = args["dataBuffer"] as? FlutterStandardTypedData
            aSoundPlayer?.start(fromBuffer: dataBuffer, result: result)
        } else if "stopPlayer" == call.method {
            aSoundPlayer?.stop()
            result("stop play")
        } else if "pausePlayer" == call.method {
            aSoundPlayer?.pause(result)
        } else if "resumePlayer" == call.method {
            aSoundPlayer?.resumePlayer(result)
        } else if "seekToPlayer" == call.method {
            let positionInMilli = args["milli"] as? NSNumber
            aSoundPlayer?.seek(toPlayer: positionInMilli?.intValue ?? 0, result: result)
        } else if "setProgressInterval" == call.method {
            let intervalInMilli = args["milli"] as? NSNumber
            aSoundPlayer?.setProgressInterval(intervalInMilli?.intValue ?? 0, result: result)
        } else if "setVolume" == call.method {
            let volume = args["volume"] as? NSNumber
            aSoundPlayer?.setVolume(volume?.doubleValue ?? 0.0, result: result)
        } else if "iosSetCategory" == call.method {
            //assert(args != nil)
            let categ = args["category"] as? String
            let mode = args["mode"] as? String
            let options = args["options"] as? NSNumber
            aSoundPlayer?.setCategory(categ, mode: mode, options: options?.intValue ?? 0, result: result)
        } else if "setActive" == call.method {
            let enabled = (args["enabled"] as? NSNumber)?.boolValue ?? false
            aSoundPlayer?.setActive(enabled, result: result)
        } else if "getResourcePath" == call.method {
            result(Bundle.main.resourcePath)
        } else {
            result(FlutterMethodNotImplemented)
        }
    }
    
    func invokeCallback(_ methodName: String?, arguments call: [AnyHashable : Any]?) {
        _channel.invokeMethod(methodName! , arguments: call)
    }
    func freeSlot(slotNo: Int) {
        playerSlots?[slotNo] = NSNull()
    }

    func getDuration(_ path: String?, callbackUuid: String?, slotNo: Int, result: FlutterResult) {
        /// let the dart code resume whilst we calculate the duratin.
        result("queued")

        let afUrl = URL(fileURLWithPath: path ?? "")
        var fileID: AudioFileID?
        var status = AudioFileOpenURL(afUrl as CFURL, .readPermission, AudioFileTypeID(0), &fileID)
        var outDataSize = Float64(0)
        var thePropSize = UInt32(MemoryLayout<Float64>.size)
        if let wfileID = fileID {
        status = AudioFileGetProperty(wfileID, kAudioFilePropertyEstimatedDuration, UnsafeMutablePointer<UInt32>(mutating: &thePropSize), UnsafeMutableRawPointer(mutating: &outDataSize))
            AudioFileClose(wfileID)
        }
        print("\("getDuration status\(Int(status))")")

        if status == kAudioServicesNoError {
            let milliseconds = Int(outDataSize * 1000)

            let args = String(
                format: "{\"callbackUuid\": \"%@\", \"milliseconds\": %d}", callbackUuid!, milliseconds)

            let dic = [
                "slotNo": NSNumber(value: Int32(slotNo)),
                "arg": args
                ] as [String : Any]
            invokeCallback("durationResults", arguments: dic)
        } else {
            /// danger will robison, danger
            let args = String(
                format: "{\"callbackUuid\": \"%@\", \"description\": \"%d\"}", callbackUuid!, Int(status))
            let dic = [
                "slotNo": NSNumber(value: Int32(slotNo)),
                "arg": args
                ] as [String : Any]
            invokeCallback("onError", arguments: dic)
        }

    }

    override init() {
        super.init()
        playerSlots = []
    }

    func getManager() -> SoundPlayerManager? {
        return soundPlayerManager
    }
}
class SoundPlayer: NSObject, AVAudioPlayerDelegate {
    var audioPlayer: AVAudioPlayer?
    var isPaused = false
    var setCategoryDone: t_SET_CATEGORY_DONE!
    var setActiveDone: t_SET_CATEGORY_DONE!

    private var audioFileURL: URL?
    private var progressTimer: Timer?
    private var progressIntervalSeconds = 0.0
    private var slotNo = 0

    func getPlugin() -> SoundPlayerManager? {
        return soundPlayerManager
    }

    init(aSlotNo: Int) {
        slotNo = aSlotNo
    }

    func stop() {
        stopProgressTimer()
        isPaused = false
        if audioPlayer != nil {
            audioPlayer?.stop()
            audioPlayer = nil
        }
        if (setActiveDone != .by_USER /* The caller did it himself : Sounds must not change that) */) && (setActiveDone != .not_SET) {
            do {
                try AVAudioSession.sharedInstance().setActive(false)
            } catch {
            }
            setActiveDone = .not_SET
        }
    }

    func pause(_ result: FlutterResult) {
        if audioPlayer != nil {
            if !(audioPlayer?.isPlaying ?? false) {
                isPaused = false

                print("audioPlayer is not playing!\n")
                result(
                    FlutterError(
                                        code: "Audio Player",
                                        message: "audioPlayer is not playing",
                                        details: nil))
            } else {
                pause()
                result("pause play")
            }
        } else {
            print("resumePlayer : player is not set\n")
            result(
                FlutterError(
                                code: "Audio Player",
                                message: "player is not set",
                                details: nil))
        }
    }

    func resumePlayer(_ result: FlutterResult) {

        isPaused = false

        if audioPlayer == nil {
            print("resumePlayer : player is not set\n")
            result(
                FlutterError(
                                code: "Audio Player",
                                message: "player is not set",
                                details: nil))
            return
        }
        if audioPlayer?.isPlaying ?? false {
            print("audioPlayer is already playing!\n")
            result(
                FlutterError(
                                code: "Audio Player",
                                message: "audioPlayer is already playing",
                                details: nil))
        } else {
            do {
                try AVAudioSession.sharedInstance().setActive(true)
            } catch {
            }
            let b = resume()
            if b {
                let filePath = audioFileURL?.absoluteString
                result(filePath)
            } else {
                result(
                    FlutterError(
                                        code: "Audio Player",
                                        message: "resume failed",
                                        details: nil))
            }
        }
    }

    func startProgressTimer() {
        stopProgressTimer()
        print(String(format: "starting ProgressTimer interval:%lf", progressIntervalSeconds))
        progressTimer = Timer.scheduledTimer(
            timeInterval: TimeInterval(progressIntervalSeconds),
            target: self,
            selector: #selector(updateProgress),
            userInfo: nil,
            repeats: true)
        print("started ProgressTimer")
    }

    func stopProgressTimer() {
        if progressTimer != nil {
            print("stopping ProgressTimer")
            progressTimer?.invalidate()
            progressTimer = nil
        }
    }

    @objc func updateProgress() {
        print("entered updateProgress")
        let duration = NSNumber(value: Double(audioPlayer!.duration * 1000))
        let currentTime = NSNumber(value: Double((audioPlayer?.currentTime)! * 1000))

        let status = String(
            format: "{\"duration\": \"%@\", \"current_position\": \"%@\"}", duration.stringValue, currentTime.stringValue)
        print("sending updateProgress: \(status)")
        invokeCallback("updateProgress", stringArg: status)
    }

    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        print("audioPlayerDidFinishPlaying")
        if (setActiveDone != .by_USER /* The caller did it himself : Sounds must not change that) */) && (setActiveDone != .not_SET) {
            do {
                try AVAudioSession.sharedInstance().setActive(false)
            } catch {
            }
            setActiveDone = .not_SET
        }
        if let uaudioPlayer = audioPlayer {
        let duration = NSNumber(value: Double(uaudioPlayer.duration * 1000))
        let currentTime = NSNumber(value: Double(uaudioPlayer.currentTime * 1000))
        
        let status = String(format: "{\"duration\": \"%@\", \"current_position\": \"%@\"}", duration.stringValue, currentTime.stringValue)

        invokeCallback("audioPlayerFinishedPlaying", stringArg: status)
        isPaused = false
        }
        stopProgressTimer()
    }

    func pause() {
        audioPlayer?.pause()
        isPaused = true
        stopProgressTimer()
        if (setActiveDone != .by_USER /* The caller did it himself : Sounds must not change that) */) && (setActiveDone != .not_SET) {
            do {
                try AVAudioSession.sharedInstance().setActive(false)
            } catch {
            }
            setActiveDone = .not_SET
        }
    }

    @discardableResult
    func resume() -> Bool {
        isPaused = true

        var b = false
        if audioPlayer?.isPlaying ?? false {
            print("audioPlayer is already playing!\n")
        } else {
            b = audioPlayer?.play() ?? false
            if b {
                startProgressTimer()
                if setActiveDone == .not_SET {
                    do {
                        try AVAudioSession.sharedInstance().setActive(true)
                    } catch {
                    }
                    setActiveDone = .for_PLAYING
                }
            } else {
                print("resume : resume failed!\n")
            }
        }
        return b
    }

    func start(_ path: String?, result: @escaping FlutterResult) {
        var isRemote = false
        if NSString.self == NSNull.self {
            audioFileURL = URL(fileURLWithPath: (getDirectoryOfType_Sounds(.cachesDirectory) ?? "") + "sound.aac")
        } else {
            let remoteUrl = URL(string: path ?? "")
            if remoteUrl != nil && remoteUrl?.scheme != nil && remoteUrl?.host != nil {
                audioFileURL = remoteUrl
                isRemote = true
            } else {
                audioFileURL = remoteUrl ?? URL(fileURLWithPath: path ?? "", isDirectory: false)
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

        if isRemote {
            var downloadTask: URLSessionDataTask? = nil
            if let audioFileURL = audioFileURL {
                downloadTask = URLSession.shared.dataTask(
                    with: audioFileURL,
                    completionHandler: { data, response, error in

                        // We must create a new Audio Player instance to be able to play a different Url
                        do {
                            if let data = data {
                                self.audioPlayer = try AVAudioPlayer(data: data)
                            }
                        } catch {
                        }
                        self.audioPlayer?.delegate = self

                        UIApplication.shared.beginReceivingRemoteControlEvents()

                        let b = self.audioPlayer?.play() ?? false
                        if !b {
                            self.stop()
                            result(FlutterError(
                                code: "Audio Player",
                                message: "Play failure",
                                details: nil))
                        }
                    })
            }

            startProgressTimer()
            let filePath = audioFileURL?.absoluteString
            result(filePath)
            downloadTask?.resume()
        } else {
            // if (!audioPlayer) { // Fix sound distoring when playing recorded audio again.
            do {
                if let audioFileURL = audioFileURL {
                    audioPlayer = try AVAudioPlayer(contentsOf: audioFileURL)
                }
            } catch {
            }
            audioPlayer?.delegate = self
            // }
            let b = audioPlayer?.play() ?? false
            if !b {
                stop()
                result(FlutterError(
                    code: "Audio Player",
                    message: "Play failure",
                    details: nil))
            } else {
                startProgressTimer()
                let filePath = audioFileURL?.absoluteString
                result(filePath)
            }
        }
    }

    func start(fromBuffer dataBuffer: FlutterStandardTypedData?, result: FlutterResult) {
        do {
            if let data = dataBuffer?.data{
                audioPlayer = try AVAudioPlayer(data: data)
            }
        } catch {
        }
        audioPlayer?.delegate = self
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
        let b = audioPlayer?.play() ?? false
        if !b {
            stop()
            result(FlutterError(
                code: "Audio Player",
                message: "Play failure",
                details: nil))
        } else {
            startProgressTimer()
            result("Playing from buffer")
        }
    }

    func seek(toPlayer positionInMilli: Int, result: FlutterResult) {
        if audioPlayer != nil {
            audioPlayer?.currentTime = TimeInterval(positionInMilli / 1000)
            updateProgress()
            result(NSNumber(value: positionInMilli).stringValue)
        } else {
            result(
                FlutterError(
                                code: "Audio Player",
                                message: "player is not set",
                                details: nil))
        }
    }

    func setProgressInterval(_ intervalInMillis: Int, result: FlutterResult) {
        progressIntervalSeconds = Double(intervalInMillis) / 1000.0
        print(String(format: "setProgressInterval called  interval:%lf", progressIntervalSeconds))
        result("setProgressInterval")
    }

    func setVolume(_ volume: Double, result: FlutterResult) {
        if audioPlayer != nil {
            audioPlayer?.volume = Float(volume)
            result("volume set")
        } else {
            result(
                FlutterError(
                                code: "Audio Player",
                                message: "player is not set",
                                details: nil))
        }
    }

    func setCategory(_ categ: String?, mode: String?, options: Int, result: FlutterResult) {
        // Able to play in silent mode
        var b = false
        do {
            try AVAudioSession.sharedInstance().setCategory(
                AVAudioSession.Category(rawValue: categ!/* AVAudioSessionCategoryPlayback */),
                        mode: AVAudioSession.Mode(rawValue: mode!),
                        options: AVAudioSession.CategoryOptions(rawValue: UInt(options)))
            b = true
        } catch {
        }
        setCategoryDone = .by_USER // The caller did it himself : Sounds must not change that)
        setActiveDone = .not_SET
        let r = NSNumber(value: b)
        result(r)
    }

    func setActive(_ enabled: Bool, result: FlutterResult) {
        if enabled {
            if setActiveDone != .not_SET {
                // Already activated. Nothing todo;
                setActiveDone = .by_USER // The caller did it himself : Sounds must not change that)
                result(0)
                return
            }
            setActiveDone = .by_USER // The caller did it himself : Sounds must not change that)
        } else {
            if setActiveDone == .not_SET {
                // Already desactivated
                result(0)
                return
            }
            setActiveDone = .not_SET
        }
        var b = false
        do {
            try AVAudioSession.sharedInstance().setActive(enabled)
            b = true
        } catch {
        }
        let r = NSNumber(value: b)
        result(r)
    }

    func initializeSoundPlayer(_ call: FlutterMethodCall?, result: FlutterResult) {
        isPaused = false
        progressIntervalSeconds = 0.8
        result(NSNumber(value: true))
    }

    func release(_ call: FlutterMethodCall?, result: FlutterResult) {
        getPlugin()?.freeSlot(slotNo: slotNo)
        result("The player has been successfully released")

    }

    func invokeCallback(_ methodName: String?, stringArg: String?) {
        let dic = [
            "slotNo": NSNumber(value: Int32(slotNo)),
            "arg": stringArg ?? ""
            ] as [String : Any]
        getPlugin()?.invokeCallback(methodName, arguments: dic)
    }

    // post fix with _Sounds to avoid conflicts with common libs including path_provider
    func getDirectoryOfType_Sounds(_ dir: FileManager.SearchPathDirectory) -> String? {
        let paths = FileManager.default.urls(for: dir, in: .userDomainMask).map(\.path)
        return (paths.first ?? "") + "/"
    }
}

//--------------------------------------------------------------------------------------------

