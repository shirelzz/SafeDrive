//
//  Alerts.swift
//  SafeDrive
//
//  Created by שיראל זכריה on 07/03/2024.
//

import SwiftUI
import UIKit
import AVFoundation

extension ObjectDetectionVC {

    // make sure to not send the same alert within the time the alert is already playing

    // Function to send banner alerts
    func sendBannerAlert(hazardType: String) {
        print("sending banner alert")
        
        // Check if the last sent time for this hazard type is within the cooldown period
        if let lastSent = lastSentTime[hazardType], Date().timeIntervalSince(lastSent) < 10 {
            print("Alert already sent for \(hazardType) within cooldown period.")
            return
        }
        
        let content = UNMutableNotificationContent()
        content.title = "Warning"
        content.body = "Potential \(hazardType) detected!"
        content.sound = .default
        
        let request = UNNotificationRequest(identifier: hazardType, content: content, trigger: nil)
        UNUserNotificationCenter.current().add(request) { (error) in
            if let error = error {
                print("Error sending notification: \(error.localizedDescription)")
            } else {
                print("Notification sent successfully for \(hazardType)")
                self.lastSentTime[hazardType] = Date()
            }
        }
    }
    
    // Function to play sound alerts
    func playSoundAlert() {
        print("playing sound alert")
        guard let url = Bundle.main.url(forResource: "softAlert", withExtension: "mp3") else { return }
        
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: url)
            audioPlayer?.play()
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
                self.audioPlayer?.stop()
            }
            
        } catch {
            print("Error playing sound: \(error.localizedDescription)")
        }
    }
    
    func triggerHapticFeedback() {
        print("haptic alert")
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.warning)
    }
}
