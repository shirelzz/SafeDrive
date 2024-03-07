//
//  Alerts.swift
//  SafeDrive
//
//  Created by שיראל זכריה on 05/03/2024.
//

import Foundation
import UIKit
import AVFoundation

class Alerts {
    // Function to trigger haptic feedback
    static func haptics() {
        let generator = UINotificationFeedbackGenerator()
        generator.prepare()
        generator.notificationOccurred(.success) // You can replace .success with .warning or .error based on the feedback you want
    }
    
    // Function to show banner alert
    static func banner(title: String, message: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okayAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alertController.addAction(okayAction)
        
        if let topViewController = UIApplication.shared.windows.first?.rootViewController {
            topViewController.present(alertController, animated: true, completion: nil)
        }
    }
    
    // Function to trigger voice or sound alert
    static func voiceAlert(soundName: String) {
        guard let soundURL = Bundle.main.url(forResource: soundName, withExtension: "mp3") else {
            print("Sound file not found")
            return
        }
        
        var audioPlayer: AVAudioPlayer?
        
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: soundURL)
            audioPlayer?.play()
        } catch {
            print("Failed to play sound: \(error)")
        }
    }
}


//func triggerAlert() {
//    // Voice alert
//    let utterance = AVSpeechUtterance(string: "Attention: Hazardous object detected!")
//    let synthesizer = AVSpeechSynthesizer()
//    synthesizer.speak(utterance)
//    
//    // Haptic feedback
//    let feedbackGenerator = UINotificationFeedbackGenerator()
//    feedbackGenerator.notificationOccurred(.warning)
//    
//    // Banner notification
//    let content = UNMutableNotificationContent()
//    content.title = "Alert"
//    content.body = "Hazardous object detected!"
//    let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: nil)
//    UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)
//}
