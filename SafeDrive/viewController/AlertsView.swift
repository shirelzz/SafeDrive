//
//  Alerts.swift
//  SafeDrive
//
//  Created by שיראל זכריה on 07/03/2024.
//

import SwiftUI
import UIKit
import AVFoundation

extension ViewController {

    // Function to send banner alerts
    func sendBannerAlert() {
        let content = UNMutableNotificationContent()
        content.title = "Warning"
         content.body = "Potential hazard detected!"
        content.sound = .default
        
        let request = UNNotificationRequest(identifier: "PersonDetected", content: content, trigger: nil)
        UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)
    }
    
    // Function to play sound alerts
    func playSoundAlert() {
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
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.warning)
    }
}
