////
////  ViewController.swift
////  SafeDrive
////
////  Created by שיראל זכריה on 05/03/2024.
////
//
//import Foundation
//import UIKit
//import SwiftUI
//import Vision
//import CoreML
//import AVFoundation
//
//class ViewController: UIViewController {

//    var videoProcessingController: VideoProcessingController!
//
//    var videoPlayer: AVPlayer?
//    var videoOutput: AVPlayerItemVideoOutput?
//    var displayLink: CADisplayLink?
//    var requests = [VNRequest]()
//    var detectionLayer: CALayer!
//    var screenRect: CGRect! // For view dimensions
//    
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        // Initialize screenRect with the bounds of the main screen
//        screenRect = UIScreen.main.bounds
//        setupVideoPlayer()
//        setupLayers()
//        setupDetector()
//        
//    }
//    
//    func setupVideoPlayer() {
//        
//        
//        guard let videoURL = Bundle.main.url(forResource: "cityDrive", withExtension: "mp4") else {
//            fatalError("Sample video not found")
//        }
//        
//        let playerItem = AVPlayerItem(url: videoURL)
//        videoOutput = AVPlayerItemVideoOutput(pixelBufferAttributes: nil)
//        playerItem.add(videoOutput!)
//        videoPlayer = AVPlayer(playerItem: playerItem)
//        print("finished setting playerItem")
//
//        videoPlayer?.isMuted = true
//        videoPlayer?.rate = 0.5
//
//        let playerLayer = AVPlayerLayer(player: videoPlayer)
//        playerLayer.frame = CGRect(x: 0, y: 0, width: screenRect.size.width, height: screenRect.size.height)
//        view.layer.addSublayer(playerLayer)
//        
//        videoPlayer?.play()
//        videoPlayer?.rate = 0.25
//        
//        print("finished setting video")
//    }
//    
//    
//    
//    // detector
//    
//    func setupDetector() {
//        guard let modelURL = Bundle.main.url(forResource: "yolov5s", withExtension: "mlmodelc", subdirectory: nil) else {
//            fatalError("Model not found")
//        }
//
//        do {
//            let visionModel = try VNCoreMLModel(for: MLModel(contentsOf: modelURL))
//            print("Model: \(visionModel.description)")
//            
//            let recognitions = VNCoreMLRequest(model: visionModel, completionHandler: detectionDidComplete)
//            self.requests = [recognitions]
//
//
////            let recognitionRequest = VNCoreMLRequest(model: visionModel, completionHandler: { [weak self] request, error in
////                self?.detectionDidComplete(request: request, error: error)
////            })
////            let recognitionRequest = VNCoreMLRequest(model: visionModel, completionHandler: { (request, error) in
////
////                DispatchQueue.main.async(execute: {
////                    // perform all the UI updates on the main queue
////                    if let results = request.results {
////                        print("results 0: \(results)")
////                        self.extractDetections(results)
////                        
////                        if results.isEmpty {
////                            print("results is empty")
////                        }
////                    }
////                    print("no results")
////
////                })
////            })
//            
//            print("recognitionRequest model: \(recognitions.model)")
//            print("recognitionRequest model: \(recognitions.debugDescription)")
//                        
//
//            
//        } catch {
//            print("Error loading Core ML model: \(error)")
//        }
//    }
//    
//    func detectionDidComplete(request: VNRequest, error: Error?) {
//        DispatchQueue.main.async(execute: {
//            if let results = request.results {
//                self.extractDetections(results)
//            }
//        })
//    }
//    
//    func extractDetections(_ results: [VNObservation]) {
//        detectionLayer.sublayers = nil
//        
//        for observation in results where observation is VNRecognizedObjectObservation {
//            guard let objectObservation = observation as? VNRecognizedObjectObservation else { continue }
//            
//            // Transformations
//            let objectBounds = VNImageRectForNormalizedRect(objectObservation.boundingBox, Int(screenRect.size.width), Int(screenRect.size.height))
//            let transformedBounds = CGRect(x: objectBounds.minX, y: screenRect.size.height - objectBounds.maxY, width: objectBounds.maxX - objectBounds.minX, height: objectBounds.maxY - objectBounds.minY)
//            
//            let boxLayer = self.drawBoundingBox(transformedBounds)
//
//            detectionLayer.addSublayer(boxLayer)
//        }
//    }
//
////    func detectionDidComplete(request: VNRequest, error: Error?) {
////        guard let results = request.results else {
////            print("No results found")
////            return
////        }
////        print("Results received: \(results)")
////        
////        if results.isEmpty {
////            print("results is empty")
////        }
////
////
////        DispatchQueue.main.async {
////            self.extractDetections(results)
////            print("Object detection results: \(results)")
////        }
////    }
//
//    
////    func extractDetections(_ results: [Any]) {
////        print("results 3: \(results)")
////        detectionLayer.sublayers?.forEach { $0.removeFromSuperlayer() }
////        
////        for observation in results where observation is VNRecognizedObjectObservation {
////            guard let objectObservation = observation as? VNRecognizedObjectObservation else { continue }
////            
////            let objectBounds = VNImageRectForNormalizedRect(objectObservation.boundingBox,
////                                                            Int(screenRect.size.width),
////                                                            Int(screenRect.size.height))
////            print("Object Bounds: \(objectBounds)")
////
////            let transformedBounds = CGRect(
////                x: objectBounds.minX,
////                y: screenRect.size.height - objectBounds.maxY,
////                width: objectBounds.maxX - objectBounds.minX,
////                height: objectBounds.maxY - objectBounds.minY)
////            print("transformedBounds: \(transformedBounds)")
////            
////            let boxLayer = drawBoundingBox(transformedBounds)
////            detectionLayer.addSublayer(boxLayer)
////            
////            print("Drawing bounding box at: \(boxLayer.frame)")
////
////        }
////    }
//    
//    func setupLayers() {
//        detectionLayer = CALayer()
//        detectionLayer.frame = CGRect(x: 0, y: 0, width: screenRect.size.width, height: screenRect.size.height)
////        detectionLayer.zPosition = 1
////        detectionLayer.backgroundColor = UIColor.blue.withAlphaComponent(1).cgColor
//
//        self.view.layer.addSublayer(detectionLayer)
//        print("Detection layer frame: \(detectionLayer.frame)")
//        print("finished setting layers")
//    }
//
//    func updateLayers() {
//        detectionLayer?.frame = CGRect(x: 0, y: 0, width: screenRect.size.width, height: screenRect.size.height)
//    }
//    
//    func drawBoundingBox(_ bounds: CGRect) -> CALayer {
//        let boxLayer = CALayer()
//        boxLayer.frame = bounds
//        boxLayer.borderWidth = 3.0
//        boxLayer.borderColor = UIColor.red.cgColor
//        boxLayer.cornerRadius = 4
//        print("Drawing bounding box at: \(bounds)")
//
//        return boxLayer
//    }
//    
//    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
//        guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return }
//        let imageRequestHandler = VNImageRequestHandler(cvPixelBuffer: pixelBuffer, orientation: .up, options: [:]) // Create handler to perform request on the buffer
//
//        do {
//            try imageRequestHandler.perform(self.requests) // Schedules vision requests to be performed
//        } catch {
//            print(error)
//        }
//    }
//
//}
//
//
//struct HostedViewController: UIViewControllerRepresentable {
//    func makeUIViewController(context: Context) -> UIViewController {
//        return ViewController()
//        }
//
//        func updateUIViewController(_ uiViewController: UIViewController, context: Context) {
//        }
//}
//


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
        guard let filePath = Bundle.main.path(forResource: "cityDrive", ofType: "mp4") else {
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
//        let handler = VNImageRequestHandler(cvPixelBuffer: pixelBuffer, orientation: .right, options: [:])
        let handler = VNImageRequestHandler(cvPixelBuffer: pixelBuffer, orientation: .up, options: [:])
        
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
                let transformedBounds = CGRect(x: objectBounds.minX, y: self.screenRect.size.height - objectBounds.maxY, width: objectBounds.maxX - objectBounds.minX, height: objectBounds.maxY - objectBounds.minY)
                
//                let boxLayer = self.drawBoundingBox(transformedBounds)

                self.highlightObject(objectObservation: objectObservation, bounds: transformedBounds)
            }
        }
    }
    
    func drawBoundingBox(_ bounds: CGRect) -> CALayer {
        let boxLayer = CALayer()
        boxLayer.frame = bounds
        boxLayer.borderWidth = 3.0
        boxLayer.borderColor = CGColor.init(red: 0.0, green: 0.0, blue: 0.0, alpha: 1.0)
        boxLayer.cornerRadius = 4
        return boxLayer
    }
    
    func highlightObject(objectObservation: VNRecognizedObjectObservation, bounds: CGRect) {
        // Calculate the scale and offset based on the video's natural size and the player layer's frame
        let scaleX = playerLayer.bounds.width / CGFloat(CVPixelBufferGetWidth(videoOutput.copyPixelBuffer(forItemTime: player.currentTime(), itemTimeForDisplay: nil)!))
        let scaleY = playerLayer.bounds.height / CGFloat(CVPixelBufferGetHeight(videoOutput.copyPixelBuffer(forItemTime: player.currentTime(), itemTimeForDisplay: nil)!))
        let offsetX = playerLayer.bounds.minX
        let offsetY = playerLayer.bounds.minY

        // Calculate adjusted bounding box coordinates
        let objectBounds = VNImageRectForNormalizedRect(objectObservation.boundingBox, Int(scaleX), Int(scaleY))
        let adjustedBounds = CGRect(x: objectBounds.minX + offsetX,
                                    y: objectBounds.minY + offsetY,
                                    width: objectBounds.width,
                                    height: objectBounds.height)

        // Create and configure the shape layer for the bounding box
        let boxLayer = CALayer()
        boxLayer.frame = bounds
        boxLayer.borderWidth = 2.0
        boxLayer.borderColor = CGColor.init(red: 0.0, green: 0.0, blue: 0.0, alpha: 1.0)
        boxLayer.cornerRadius = 2
        
//        let boxLayer = CAShapeLayer()
//        boxLayer.frame = adjustedBounds
//        boxLayer.cornerRadius = 2
//        boxLayer.borderWidth = 2
//        boxLayer.borderColor = UIColor.red.cgColor
//        boxLayer.backgroundColor = UIColor.clear.cgColor
        detectionLayer.addSublayer(boxLayer)

        // If you want to display the top label for the detected object
        if let topLabelObservation = objectObservation.labels.first {
            let labelString = "\(topLabelObservation.identifier) \(String(format: "%.2f", topLabelObservation.confidence))"
            let labelLayer = CATextLayer()
            labelLayer.string = labelString
            labelLayer.fontSize = 14
            labelLayer.foregroundColor = UIColor.white.cgColor
            labelLayer.backgroundColor = UIColor.black.withAlphaComponent(0.5).cgColor
            labelLayer.alignmentMode = .natural
            labelLayer.cornerRadius = 2
            labelLayer.frame = CGRect(x: bounds.maxX, y: bounds.maxY + 10, width: CGFloat(labelString.count * 2), height: 20)
//            labelLayer.frame = CGRect(x: adjustedBounds.minX,
//                                      y: adjustedBounds.minY - 20,
//                                      width: 100,
//                                      height: 20)
            detectionLayer.addSublayer(labelLayer)
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


