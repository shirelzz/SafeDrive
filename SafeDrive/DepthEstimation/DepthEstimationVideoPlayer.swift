//
//  DepthEstimationVideoPlayer.swift
//  SafeDrive
//
//  Created by שיראל זכריה on 10/04/2024.
//

import SwiftUI
import AVFoundation
import UIKit

extension DepthEstimationVC {
    
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

//        // Add observer for device orientation changes
//        let notificationCenter = NotificationCenter.default
//        notificationCenter.addObserver(self, selector: #selector(handleOrientationChange), name: UIDevice.orientationDidChangeNotification, object: nil)
        
//        // Add observer for end of video playback
//        notificationCenter.addObserver(self, selector: #selector(playerDidFinishPlaying(_:)), name: .AVPlayerItemDidPlayToEndTime, object: player.currentItem)


    }
}
