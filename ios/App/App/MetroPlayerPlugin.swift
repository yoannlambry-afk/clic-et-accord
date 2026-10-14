import Foundation
import Capacitor
import AVFoundation
import os.log

/// Joue en boucle, sans coupure, une mesure de métronome rendue par la page web (WAV en base64).
/// AVAudioPlayer + session « playback » + mode d'arrière-plan « audio » : le clic continue écran verrouillé.
@objc(MetroPlayerPlugin)
public class MetroPlayerPlugin: CAPPlugin, CAPBridgedPlugin {
    public let identifier = "MetroPlayerPlugin"
    public let jsName = "MetroPlayer"
    public let pluginMethods: [CAPPluginMethod] = [
        CAPPluginMethod(name: "play", returnType: CAPPluginReturnPromise),
        CAPPluginMethod(name: "stop", returnType: CAPPluginReturnPromise),
        CAPPluginMethod(name: "setVolume", returnType: CAPPluginReturnPromise),
        CAPPluginMethod(name: "status", returnType: CAPPluginReturnPromise)
    ]

    private let log = OSLog(subsystem: "fr.bibeo.clicetaccord", category: "metro")
    private var player: AVAudioPlayer?
    private var volume: Float = 0.8
    private var observing = false
    private var heartbeat: Timer?

    private func activateSession() throws {
        let session = AVAudioSession.sharedInstance()
        try session.setCategory(.playback, mode: .default, options: [.mixWithOthers])
        try session.setActive(true)
        if !observing {
            observing = true
            NotificationCenter.default.addObserver(self, selector: #selector(handleInterruption(_:)),
                                                   name: AVAudioSession.interruptionNotification, object: session)
        }
    }

    @objc private func handleInterruption(_ note: Notification) {
        guard let info = note.userInfo,
              let typeValue = info[AVAudioSessionInterruptionTypeKey] as? UInt,
              let type = AVAudioSession.InterruptionType(rawValue: typeValue) else { return }
        if type == .ended {
            let optionsValue = info[AVAudioSessionInterruptionOptionKey] as? UInt ?? 0
            let options = AVAudioSession.InterruptionOptions(rawValue: optionsValue)
            if options.contains(.shouldResume), let p = player {
                try? AVAudioSession.sharedInstance().setActive(true)
                p.play()
                os_log("reprise après interruption", log: log, type: .default)
            }
        }
    }

    @objc func play(_ call: CAPPluginCall) {
        guard let b64 = call.getString("wav"), let data = Data(base64Encoded: b64) else {
            call.reject("Données audio manquantes"); return
        }
        if let v = call.getDouble("volume") { volume = Float(max(0, min(1, v))) }
        do {
            try activateSession()
            let p = try AVAudioPlayer(data: data, fileTypeHint: AVFileType.wav.rawValue)
            p.numberOfLoops = -1
            p.volume = volume
            p.prepareToPlay()
            let old = player
            player = p
            p.play()
            old?.stop()
            os_log("lecture : %.3f s par mesure", log: log, type: .default, p.duration)
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                self.heartbeat?.invalidate()
                self.heartbeat = Timer.scheduledTimer(withTimeInterval: 2, repeats: true) { [weak self] _ in
                    guard let self = self else { return }
                    os_log("battement : lecture=%{public}@ position=%.2f", log: self.log, type: .default,
                           (self.player?.isPlaying ?? false) ? "oui" : "non", self.player?.currentTime ?? 0)
                }
            }
            call.resolve(["playing": true, "duration": p.duration])
        } catch {
            os_log("échec lecture : %{public}@", log: log, type: .error, error.localizedDescription)
            call.reject("Lecture impossible : \(error.localizedDescription)")
        }
    }

    @objc func stop(_ call: CAPPluginCall) {
        DispatchQueue.main.async { [weak self] in self?.heartbeat?.invalidate(); self?.heartbeat = nil }
        player?.stop()
        player = nil
        try? AVAudioSession.sharedInstance().setActive(false, options: [.notifyOthersOnDeactivation])
        os_log("arrêt", log: log, type: .default)
        call.resolve()
    }

    @objc func setVolume(_ call: CAPPluginCall) {
        volume = Float(max(0, min(1, call.getDouble("volume") ?? Double(volume))))
        player?.volume = volume
        call.resolve()
    }

    @objc func status(_ call: CAPPluginCall) {
        call.resolve(["playing": player?.isPlaying ?? false, "currentTime": player?.currentTime ?? 0])
    }
}
