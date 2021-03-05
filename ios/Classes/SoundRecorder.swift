//  Converted to Swift 5.2 by Swiftify v5.2.19227 - https://swiftify.com/
//
//  SoundRecorder.swift
//  Pods
//
//  Created by larpoux on 24/03/2020.
//
//
//  SoundRecorder.swift
//  flauto
//
//  Created by larpoux on 24/03/2020.
//
import AVFoundation
import Flutter

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

private var _channel: FlutterMethodChannel?
var _soundRecorderChannel: FlutterMethodChannel?

func SoundRecorderReg(_ registrar: (NSObjectProtocol & FlutterPluginRegistrar)?) {
    SoundRecorderManager.register(with: registrar!)
}

var soundRecorderManager: SoundRecorderManager? // Singleton

class SoundRecorderManager: NSObject, FlutterPlugin {
    private var soundRecorderSlots: [AnyHashable]?

    class func register(with registrar: (NSObjectProtocol & FlutterPluginRegistrar)) {
        _channel = FlutterMethodChannel(
            name: "com.bsutton.sounds.sound_recorder",
            binaryMessenger: registrar.messenger())
        assert(soundRecorderManager == nil)
        soundRecorderManager = SoundRecorderManager()
        registrar.addMethodCallDelegate(soundRecorderManager!, channel: _channel ?? <#default value#>)
    }

    func handle(_ call: FlutterMethodCall, result: FlutterResult) {
        let args = call.arguments as! Dictionary<String, Any>
        let slotNo = args["slotNo"] as! NSNumber


        // The dart code supports lazy initialization of recorders.
        // This means that recorders can be registered (and slots allocated)
        // on the client side in a different order to which the recorders
        // are initialised.
        // As such we need to grow the slot array upto the 
        // requested slot no. even if we haven't seen initialisation
        // for the lower numbered slots.
        while slotNo >= (soundRecorderSlots?.count ?? 0) {
            soundRecorderSlots?.append(NSNull())
        }

        var aSoundRecorder = soundRecorderSlots?[slotNo] as? SoundRecorder

        if "initializeSoundRecorder" == call.method {
            assert(soundRecorderSlots?[slotNo] == NSNull())
            aSoundRecorder = SoundRecorder(slotNo)
            soundRecorderSlots?[slotNo] = aSoundRecorder
            aSoundRecorder?.initializeSoundRecorder(call, result: result)
        } else if "releaseSoundRecorder" == call.method {
            aSoundRecorder?.release(call, result: result)
        } else if "startRecorder" == call.method {
            aSoundRecorder?.start(call, result: result)
        } else if "stopRecorder" == call.method {
            aSoundRecorder?.stop(result)
        } else if "setProgressInterval" == call.method {
            let args = call.arguments as! Dictionary<String, Any>
            let interval = args["milli"] as? NSNumber
            aSoundRecorder?.setProgressInterval(interval?.intValue ?? 0, result: result)
        } else if "pauseRecorder" == call.method {
            aSoundRecorder?.pause(call, result: result)
        } else if "resumeRecorder" == call.method {
            aSoundRecorder?.resumeRecorder(call, result: result)
        } else {
            result(FlutterMethodNotImplemented)
        }
    }

    func invokeCallback(_ methodName: String?, arguments call: [AnyHashable : Any]?) {
        _channel?.invokeMethod(methodName ?? <#default value#>, arguments: call)
    }

    func freeSlot(_ slotNo: Int) {
        soundRecorderSlots?[slotNo] = NSNull()
    }

    override init() {
        super.init()
        soundRecorderSlots = []
    }
}

class SoundRecorder: NSObject, AVAudioRecorderDelegate {
    private var audioFileURL: URL?
    private var audioRecorder: AVAudioRecorder?
    private var progressIntervalSeconds = 0.0
    private var progressTimer: Timer?
    private var setCategoryDone: t_SET_CATEGORY_DONE!
    private var setActiveDone: t_SET_CATEGORY_DONE!
    private var slotNo = 0

    func getPlugin() -> SoundRecorderManager? {
        return soundRecorderManager
    }

    convenience init?(_ aSlotNo: Int) {
        slotNo = aSlotNo
    }

    func start(_ call: FlutterMethodCall?, result: FlutterResult) {
        //let args = call.arguments as! Dictionary<String, Any>
        let args = call?.arguments as? Dictionary<String, Any>
        let path = args?["path"] as? String
        let sampleRateArgs = args?["sampleRate"] as? NSNumber
        let numChannelsArgs = args?["numChannels"] as? NSNumber
        let iosQuality = args?["iosQuality"] as? NSNumber
        let bitRate = args?["bitRate"] as? NSNumber
        let formatArg = args?["format"] as? NSNumber

        var sampleRate: Float = 44100

        var numChannels = 2

        let format = formatArg?.intValue ?? 0




        audioFileURL = URL(fileURLWithPath: path ?? "")

        var audioSettings = [
            AVSampleRateKey : NSNumber(value: sampleRate),
            AVFormatIDKey : NSNumber(value: Int32(format)),
            AVNumberOfChannelsKey : NSNumber(value: Int32(numChannels)),
            AVEncoderAudioQualityKey : NSNumber(value: Int32(iosQuality?.intValue ?? 0))
        ]

        // If bitrate is defined, the use it, otherwise use the OS default
        if !(bitRate == NSNull()) {
            audioSettings[AVEncoderBitRateKey] = NSNumber(value: Int32(bitRate?.intValue ?? 0))
        }



        // Setup audio session the first time the user starts recording with this SoundRecorder instance.
        if (setCategoryDone == .not_SET) || (setCategoryDone == .for_PLAYING) {
            let audioSession = AVAudioSession.sharedInstance()
            do {
                try audioSession.setCategory(
                    .playAndRecord,
                    options: .allowBluetooth)
            } catch {
            }
            setCategoryDone = .for_RECORDING
            var error: Error

            // set volume default to speaker
            var success = false
            do {
                try audioSession.overrideOutputAudioPort(AVAudioSessionPortOverrideSpeaker)
                success = true
            } catch {
                print("error doing outputaudioportoverride - \(error.localizedDescription)")
            }
        }


        do {
            if let audioFileURL = audioFileURL, let audioSettings = audioSettings as? [String : Any] {
                audioRecorder = try AVAudioRecorder(
                    url: audioFileURL,
                    settings: audioSettings)
            }
        } catch {
        }

        audioRecorder?.delegate = self
        audioRecorder?.record()

        audioRecorder?.isMeteringEnabled = true
        startProgressTimer()

        let filePath = audioFileURL?.path
        result(filePath)
    }

    func stop(_ result: FlutterResult) {
        audioRecorder?.stop()

        stopProgressTimer()

        let filePath = audioFileURL?.absoluteString
        result(filePath)
    }

    func initializeSoundRecorder(_ call: FlutterMethodCall?, result: FlutterResult) {
        progressIntervalSeconds = 0.8
        result(NSNumber(value: true))
    }

    func release(_ call: FlutterMethodCall?, result: FlutterResult) {
        getPlugin()?.freeSlot(slotNo)
        slotNo = -1
        result(NSNumber(value: true))
    }

    func pause(_ call: FlutterMethodCall?, result: FlutterResult) {
        audioRecorder?.pause()

        stopProgressTimer()
        result("Recorder is Paused")
    }

    func resumeRecorder(_ call: FlutterMethodCall?, result: FlutterResult) {
        let b = audioRecorder?.record() ?? false
        startProgressTimer()
        result(NSNumber(value: b))
    }

    func startProgressTimer() {
        stopProgressTimer()
        print(String(format: "starting ProgressTimer interval:%lf", progressIntervalSeconds))
        progressTimer = Timer.scheduledTimer(
            timeInterval: TimeInterval(progressIntervalSeconds),
            target: self,
            selector: #selector(SoundPlayer.updateProgress),
            userInfo: nil,
            repeats: true)
    }

    func stopProgressTimer() {
        if progressTimer != nil {
            progressTimer?.invalidate()
            progressTimer = nil
        }
    }

    func setProgressInterval(_ intervalInMilli: Int, result: FlutterResult) {
        /// convert milliseconds to seconds required by a Timer.
        progressIntervalSeconds = Double(intervalInMilli) / 1000.0
        result("setProgressInterval")
    }

    @objc func updateProgress() {
        let decibels = getDbLevel()
        let currentTime = NSNumber(value: Double?(audioRecorder?.currentTime ?? <#default value#> * 1000) ?? <#default value#>)
        audioRecorder?.updateMeters()

        let status = String(
            format: "{\"current_position\": \"%@\", \"decibels\":\"%lf\"}", currentTime.stringValue, decibels)
        print("updateProgress: \(status)")
        invokeCallback("updateProgress", stringArg: status)
    }

    func getDbLevel() -> Double {
        // NSNumber *normalizedPeakLevel = [NSNumber numberWithDouble:MIN(pow(10.0, [audioRecorder peakPowerForChannel:0] / 20.0) * 160.0, 160.0)];
        audioRecorder?.updateMeters()
        // silence is -160 max volume is 0 hence +160 as below calc only worksfor +ve no.s
        let maxAmplitude = Double((audioRecorder?.peakPower(forChannel: 0) ?? 0.0) + 160)

        var db: Double = 0

        if maxAmplitude != 0 {
            // Calculate db based on the following article.
            // https://stackoverflow.com/questions/10655703/what-does-androids-getmaxamplitude-function-for-the-mediarecorder-actually-gi
            //
            let ref_pressure = 51805.5336
            let p = maxAmplitude / ref_pressure
            let p0 = 0.0002

            db = 20.0 * log10(p / p0)
        }

        return db
    }

    func invokeCallback(_ methodName: String?, stringArg: String?) {
        let dic = [
            "slotNo": NSNumber(value: Int32(slotNo)),
            "arg": stringArg ?? ""
            ] as [String : Any]
        getPlugin()?.invokeCallback(methodName, arguments: dic)
    }

    func invokeCallback(_ methodName: String?, numberArg arg: NSNumber?) {
        var dic: [ExpressibleByStringLiteral : NSNumber]? = nil
        if let arg = arg {
            dic = [
                "slotNo": NSNumber(value: Int32(slotNo)),
                "arg": arg
            ]
        }
        getPlugin()?.invokeCallback(methodName, arguments: dic)
    }

    func getChannel() -> FlutterMethodChannel? {
        return _channel
    }
}

//---------------------------------------------------------------------------------------------


