//
//  AudioManager.swift
//  Hound
//
//  Created by Jonathan Xakellis on 5/14/21.
//  Copyright © 2023 Jonathan Xakellis. All rights reserved.
//

import AudioToolbox
import AVFoundation
import MediaPlayer
import UIKit

enum AudioManager {

    private static var sharedPlayer: AVAudioPlayer?

    static var isPlaying: Bool {
        // if the shared player is nil, then its impossible to be playing anything
        return sharedPlayer?.isPlaying ?? false
    }

    // MARK: - General Audio

    static func playAudio(audioPath: String) {
        DispatchQueue.global().async {
            guard let path = Bundle.main.path(forResource: audioPath, ofType: "mp3") else {
                return
            }

            let url = URL(fileURLWithPath: path)

            do {
                stopAudio()

                AudioManager.sharedPlayer = try AVAudioPlayer(contentsOf: url)
                AudioManager.sharedPlayer?.numberOfLoops = -1
                AudioManager.sharedPlayer?.volume = 1.0

                // generic .playback audio that mixes with others. most compatible and non intrustive
                try AVAudioSession.sharedInstance().setCategory(.playback, options: [.mixWithOthers])
                try AVAudioSession.sharedInstance().setActive(true)

                AudioManager.sharedPlayer?.play()
            }
            catch {
                HoundLogger.general.error("AudioManager.playAudio: Encountered an error: \(error.localizedDescription)")
            }
        }
    }

    static func stopAudio() {
        DispatchQueue.global().async {
            shouldVibrate = false
            AudioManager.sharedPlayer?.stop()
        }

    }

    // MARK: - Silent Audio

    static func playSilenceAudio() {
        DispatchQueue.global().async {
            guard let path = Bundle.main.path(forResource: "silence", ofType: "mp3") else {
                return
            }

            let url = URL(fileURLWithPath: path)

            do {
                stopAudio()

                AudioManager.sharedPlayer = try AVAudioPlayer(contentsOf: url)
                AudioManager.sharedPlayer?.numberOfLoops = -1
                AudioManager.sharedPlayer?.volume = 0

                // generic .playback audio that mixes with others. most compatible and non intrustive
                try AVAudioSession.sharedInstance().setCategory(.playback, options: [.mixWithOthers])
                try AVAudioSession.sharedInstance().setActive(true)

                AudioManager.sharedPlayer?.play()

            }
            catch {
                HoundLogger.general.error("AudioManager.playSilenceAudio: Encountered an error: \(error.localizedDescription)")
            }

        }
    }

    // MARK: - Loud Audio

    ///
    private static var shouldVibrate = false

    /// Checks to see if the user has notifications enabled, loud notifications enabled, and the app is in the background and, if all conditions are met, then begins loud notification and vibration.
    static func playLoudNotification() {
        // make sure the user wants loud notifications
        // don't check for if there are enabled reminders, as client could be out of sync with server which has a reminder
        guard UserConfiguration.isNotificationEnabled && UserConfiguration.isLoudNotificationEnabled && UIApplication.shared.applicationState == .background else { return }

        shouldVibrate = true
        loopVibrate()
        // make the device repeadedly vibrate
        func loopVibrate() {
            if shouldVibrate == true {
                AudioServicesPlayAlertSoundWithCompletion(SystemSoundID(kSystemSoundID_Vibrate)) {
                    DispatchQueue.global().asyncAfter(deadline: .now() + 1.0) {
                        loopVibrate()
                    }
                }
            }
        }

        // make the device play the loud notification sound
        DispatchQueue.global().async {
            guard let path = Bundle.main.path(forResource: "\(UserConfiguration.notificationSound.rawValue.lowercased())", ofType: "mp3") else {
                return
            }
            let url = URL(fileURLWithPath: path)

            do {
                stopAudio()

                AudioManager.sharedPlayer = try AVAudioPlayer(contentsOf: url)
                AudioManager.sharedPlayer?.numberOfLoops = -1
                AudioManager.sharedPlayer?.volume = 1.0

                MPVolumeView.setVolume(1.0)

                try AVAudioSession.sharedInstance().setCategory(.playback, options: [])
                try AVAudioSession.sharedInstance().setActive(true)

                AudioManager.sharedPlayer?.play()

            }
            catch {
                HoundLogger.general.error("AudioManager.playLoudNotification: Encountered an error: \(error.localizedDescription)")
            }
        }
    }

}

extension MPVolumeView {
    static func setVolume(_ volume: Float) {
        DispatchQueue.main.async {
            let volumeView = MPVolumeView()
            let slider = volumeView.subviews.first(where: { $0 is UISlider }) as? UISlider

            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.05) {
                slider?.value = volume
            }
        }
    }
}
