//
//  VideoPlayerService.swift
//  SafeDrive
//
//  Created by שיראל זכריה on 09/04/2024.
//

import Foundation
import AVFoundation
import UIKit

class VideoPlayerService: NSObject {
    
    var player: AVPlayer?
    
//    var playerLayer: AVPlayerLayer?
    private var _playerLayer: AVPlayerLayer?
    var playerLayer: AVPlayerLayer? { 
        return _playerLayer
    }
    
    var videoOutput: AVPlayerItemVideoOutput?

    // This function sets up the video player with a video from the app's bundle.
    func setupVideoPlayer(view: UIView) {
        
        let viewLayer = view.layer
        
        let videos = ["cityDrive", "roadPortrait", "cityPort", "trafficLightPort", "crossStreetPort", "standRoad"]
        guard let filePath = Bundle.main.path(forResource: videos[1], ofType: "mp4") else {
            print("Video file not found")
            return
        }

        let fileURL = URL(fileURLWithPath: filePath)
        let asset = AVAsset(url: fileURL)
        let playerItem = AVPlayerItem(asset: asset)

        videoOutput = AVPlayerItemVideoOutput(pixelBufferAttributes: [String(kCVPixelBufferPixelFormatTypeKey): Int(kCVPixelFormatType_32BGRA)])
        playerItem.add(videoOutput!)

        player = AVPlayer(playerItem: playerItem)
//        playerLayer = AVPlayerLayer(player: player)
        _playerLayer = AVPlayerLayer(player: player)
        
        player?.isMuted = true

        playerLayer?.frame = view.bounds
        playerLayer?.videoGravity = .resizeAspect
        viewLayer.addSublayer(playerLayer!)

        player?.play()
        player?.rate = 0.4

        // Add observer for device orientation changes
        NotificationCenter.default.addObserver(self, selector: #selector(handleOrientationChange), name: UIDevice.orientationDidChangeNotification, object: nil)

        // Add observer for end of video playback
        NotificationCenter.default.addObserver(self, selector: #selector(playerDidFinishPlaying(_:)), name: .AVPlayerItemDidPlayToEndTime, object: player?.currentItem)
    }

    @objc func playerDidFinishPlaying(_ notification: Notification) {
        player?.seek(to: CMTime.zero) // Move the playback to the beginning
        player?.play() // Start playing again
    }

    func retrievePixelBufferAtCurrentTime() -> CVPixelBuffer? {
        guard let currentTime = player?.currentTime(), let videoOutput = videoOutput else { return nil }
        return videoOutput.copyPixelBuffer(forItemTime: currentTime, itemTimeForDisplay: nil)
    }

    // Handle orientation changes
    @objc func handleOrientationChange(_ notification: Notification) {
        guard let playerLayer = playerLayer, let videoOutput = videoOutput, let player = player else {
            return
        }
        
        guard let pixelBuffer = videoOutput.copyPixelBuffer(forItemTime: player.currentTime(), itemTimeForDisplay: nil) else {
            return
        }
        let videoWidth = CGFloat(CVPixelBufferGetWidth(pixelBuffer))
        let videoHeight = CGFloat(CVPixelBufferGetHeight(pixelBuffer))
        let aspectRatio = videoWidth / videoHeight

        let deviceOrientation = UIDevice.current.orientation
        adjustPlayerLayerFrame(for: deviceOrientation, with: aspectRatio)
    }
    
    private func adjustPlayerLayerFrame(for orientation: UIDeviceOrientation, with aspectRatio: CGFloat) {
        guard let playerLayer = self.playerLayer else { return }
        
        var frame = CGRect.zero
        switch orientation {
        case .landscapeLeft, .landscapeRight:
            let videoWidth = UIScreen.main.bounds.height * aspectRatio
            let xOffset = (UIScreen.main.bounds.width - videoWidth) / 2.0
            frame = CGRect(x: xOffset, y: 0, width: videoWidth, height: UIScreen.main.bounds.height)
        default:
            let videoHeight = UIScreen.main.bounds.width / aspectRatio
            let yOffset = (UIScreen.main.bounds.height - videoHeight) / 2.0
            frame = CGRect(x: 0, y: yOffset, width: UIScreen.main.bounds.width, height: videoHeight)
        }
        
        UIView.animate(withDuration: 0.25) {
            playerLayer.frame = frame
        }
    }
}
