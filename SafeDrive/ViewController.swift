//
//  ViewController.swift
//  SafeDrive
//
//  Created by שיראל זכריה on 05/03/2024.
//

//import Foundation

import UIKit
import AVFoundation
import Vision
import CoreML
import SwiftUI

class ViewController: UIViewController {
    private var player: AVPlayer!
    private var playerLayer: AVPlayerLayer!
    private var videoOutput: AVPlayerItemVideoOutput!
    var requests = [VNRequest]()
    var detectionLayer: CALayer!
    var screenRect: CGRect! = UIScreen.main.bounds

    override func viewDidLoad() {
        super.viewDidLoad()
        setupVideoPlayer()
        setupDetector()
        setupLayers()
    }
    
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
        player.rate = 0.5
        
        // Process frames
        processVideoFrames()
        
        // Set the video gravity to "resizeAspectFill"
//        playerLayer.videoGravity = .resizeAspectFill

        // Add observer for device orientation changes
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self, selector: #selector(handleOrientationChange), name: UIDevice.orientationDidChangeNotification, object: nil)

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
    
    func processVideoFrames() {
        // Adjust this interval to control the frequency of frame processing
        let interval = CMTime(value: 1, timescale: 1) // Example: 1 frame per second
        player.addPeriodicTimeObserver(forInterval: interval, queue: DispatchQueue.main) { [weak self] _ in
            guard let self = self, let pixelBuffer = self.retrievePixelBufferAtCurrentTime() else { return }
            self.detectObjects(in: pixelBuffer)
        }
    }
    
    func retrievePixelBufferAtCurrentTime() -> CVPixelBuffer? {
        let currentTime = player.currentTime()
        return videoOutput.copyPixelBuffer(forItemTime: currentTime, itemTimeForDisplay: nil)
    }
    
    func setupDetector() {
        guard let modelURL = Bundle.main.url(forResource: "yolov5s", withExtension: "mlmodelc") else {
            print("ML model not found")
            return
        }
        
        do {
            let visionModel = try VNCoreMLModel(for: MLModel(contentsOf: modelURL))
            let objectRecognition = VNCoreMLRequest(model: visionModel, completionHandler: { [weak self] (request, error) in
                self?.processDetections(for: request, error: error)
            })
            requests = [objectRecognition]
        } catch {
            print("Failed to load Vision ML model: \(error)")
        }
    }
    
    func detectObjects(in pixelBuffer: CVPixelBuffer) {

        let handler = VNImageRequestHandler(cvPixelBuffer: pixelBuffer, orientation: .up , options: [:])
        
        do {
            try handler.perform(requests)
        } catch {
            print("Failed to perform detection.\n\(error.localizedDescription)")
        }
    }
    
    func processDetections(for request: VNRequest, error: Error?) {
        DispatchQueue.main.async {
            guard let results = request.results else {
                print("Unable to detect anything.\n\(String(describing: error))")
                return
            }
            
            self.detectionLayer.sublayers?.removeAll()
            
            for observation in results where observation is VNRecognizedObjectObservation {
                guard let objectObservation = observation as? VNRecognizedObjectObservation else { continue }
                
                // Transformations
                let objectBounds = VNImageRectForNormalizedRect(objectObservation.boundingBox, Int(self.screenRect.size.width), Int(self.screenRect.size.height))
                let transformedBounds = CGRect(x: objectBounds.minX,
                                               y: self.screenRect.size.height - objectBounds.maxY,
                                               width: objectBounds.maxX - objectBounds.minX,
                                               height: objectBounds.maxY - objectBounds.minY)
            
                self.highlightObject(objectObservation: objectObservation, bounds: transformedBounds)
            }
        }
    }
    
    func highlightObject(objectObservation: VNRecognizedObjectObservation, bounds: CGRect) {
        print("Highlighting object...")
        
        // Create and configure the shape layer for the bounding box
        let boxLayer = CALayer()
        boxLayer.frame = bounds
        boxLayer.borderWidth = 2.0
        boxLayer.borderColor = UIColor.white.cgColor
        boxLayer.cornerRadius = 2
        detectionLayer.addSublayer(boxLayer)
        print("Box layer added")

        // Create and configure the label layer for the detected object
        if let topLabelObservation = objectObservation.labels.first {
            let labelString = "\(topLabelObservation.identifier) \(String(format: "%.2f", topLabelObservation.confidence))"
            let labelLayer = CATextLayer()
            labelLayer.string = labelString
            labelLayer.fontSize = 14
            labelLayer.foregroundColor = UIColor.white.cgColor
            labelLayer.backgroundColor = UIColor.black.withAlphaComponent(0.8).cgColor
            labelLayer.alignmentMode = .right // Align to the right for landscape orientation
            labelLayer.cornerRadius = 2
            
            // Position the label at the top right corner of the bounding box
            labelLayer.frame = CGRect(x: bounds.maxX - CGFloat(labelString.count * 0), // Adjust the multiplier as needed
                                      y: bounds.minY - 20, // Adjust this value as needed
                                      width: CGFloat(labelString.count * 7), // Adjust the multiplier as needed
                                      height: 20)
            detectionLayer.addSublayer(labelLayer)
            print("Label layer added")
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


