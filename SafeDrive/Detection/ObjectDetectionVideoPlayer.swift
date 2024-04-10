//
//  ObjectDetectionVideoPlayer.swift
//  SafeDrive
//
//  Created by שיראל זכריה on 07/03/2024.
//

import SwiftUI
import AVFoundation
import UIKit

extension ObjectDetectionVC {
    
    func setupVideoPlayer() {
        
        let videos = ["cityDrive", "roadPortrait", "cityPort", "trafficLightPort", "crossStreetPort", "standRoad"]
        guard let filePath = Bundle.main.path(forResource: videos[1], ofType: "mp4") else {
            print("Video file not found")
            return
        }
        let fileURL = URL(fileURLWithPath: filePath)
        let asset = AVAsset(url: fileURL)
        let playerItem = AVPlayerItem(asset: asset)
                
        videoOutput = AVPlayerItemVideoOutput(pixelBufferAttributes: [String(kCVPixelBufferPixelFormatTypeKey): Int(kCVPixelFormatType_32BGRA)])
        playerItem.add(videoOutput)
        
        player = AVPlayer(playerItem: playerItem)
        playerLayer = AVPlayerLayer(player: player)
        player.isMuted = true
        
        playerLayer.frame = view.bounds
        playerLayer.videoGravity = .resizeAspect
        view.layer.addSublayer(playerLayer)
        
        player.play()
        player.rate = 0.4
        
        // Process frames
        processVideoFrames()

        // Add observer for device orientation changes
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self, selector: #selector(handleOrientationChange), name: UIDevice.orientationDidChangeNotification, object: nil)
        
        // Add observer for end of video playback
        notificationCenter.addObserver(self, selector: #selector(playerDidFinishPlaying(_:)), name: .AVPlayerItemDidPlayToEndTime, object: player.currentItem)


    }
    
    @objc func playerDidFinishPlaying(_ notification: Notification) {
        player.seek(to: CMTime.zero) // Move the playback to the beginning
        player.play() // Start playing again
    }
    
    func retrievePixelBufferAtCurrentTime() -> CVPixelBuffer? {
        let currentTime = player.currentTime()
        return videoOutput.copyPixelBuffer(forItemTime: currentTime, itemTimeForDisplay: nil)
    }
    
    // Handle orientation changes
    @objc func handleOrientationChange(_ notification: Notification) {
        guard let videoOutput = videoOutput else {
            return
        }
        
        let videoWidth = CGFloat(CVPixelBufferGetWidth(videoOutput.copyPixelBuffer(forItemTime: player.currentTime(), itemTimeForDisplay: nil)!))
        let videoHeight = CGFloat(CVPixelBufferGetHeight(videoOutput.copyPixelBuffer(forItemTime: player.currentTime(), itemTimeForDisplay: nil)!))
        let aspectRatio = videoWidth / videoHeight
        
        let deviceOrientation = UIDevice.current.orientation
        switch deviceOrientation {
        case .landscapeLeft, .landscapeRight:
            // Landscape orientation
            let videoWidth = UIScreen.main.bounds.height * aspectRatio
            let xOffset = (UIScreen.main.bounds.width - videoWidth) / 2.0
            let newFrame = CGRect(x: xOffset, y: 0, width: videoWidth, height: UIScreen.main.bounds.height)
            playerLayer.frame = newFrame
        case .portrait, .portraitUpsideDown, .faceUp, .faceDown, .unknown:
            // Portrait orientation
            let videoHeight = UIScreen.main.bounds.width / aspectRatio
            let yOffset = (UIScreen.main.bounds.height - videoHeight) / 2.0
            let newFrame = CGRect(x: 0, y: yOffset, width: UIScreen.main.bounds.width, height: videoHeight)
            playerLayer.frame = newFrame
        @unknown default:
            break
        }
    }
    
//    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
//       super.viewWillTransition(to: size, with: coordinator)
//        coordinator.animate(alongsideTransition: { (context) in
//        }) { (context) in
//            self.videoView.frame.size = size
//            self.playerLayer.frame.size = size
//        }
//    }
    
}
