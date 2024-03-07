//
//  ViewController.swift
//  SafeDrive
//
//  Created by שיראל זכריה on 05/03/2024.
//

import SwiftUI
import UIKit
import AVFoundation
import Vision
import CoreML

class ViewController: UIViewController {
    var player: AVPlayer!
    var playerLayer: AVPlayerLayer!
    var videoOutput: AVPlayerItemVideoOutput!
    var requests = [VNRequest]()
    var detectionLayer: CALayer!
    var screenRect: CGRect! = UIScreen.main.bounds
    var audioPlayer: AVAudioPlayer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupVideoPlayer()
        setupDetector()
        setupLayers()
        
        // Request authorization
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound]) { (granted, error) in
            if granted {
                print("Notification authorization granted")
            } else {
                print("Notification authorization denied")
            }
        }
    }
    
    func setupLayers() {
        detectionLayer = CALayer()
        detectionLayer.frame = view.bounds
        detectionLayer.masksToBounds = true
        playerLayer.addSublayer(detectionLayer)
    }
    
}

struct HostedViewController: UIViewControllerRepresentable {
    func makeUIViewController(context: Context) -> UIViewController {
        return ViewController()
        }

        func updateUIViewController(_ uiViewController: UIViewController, context: Context) {
        }
}
