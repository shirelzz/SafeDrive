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
import AVKit

class ObjectDetectionVC: UIViewController, DetectionDelegate, UNUserNotificationCenterDelegate {
    
    var detectionHandler: DetectionHandler!

    var player: AVPlayer!
    var playerLayer: AVPlayerLayer!
    var videoOutput: AVPlayerItemVideoOutput!
    
    var requests = [VNRequest]()
    var detectionLayer: CALayer!
    var screenRect: CGRect! = UIScreen.main.bounds
    var audioPlayer: AVAudioPlayer?
    
    // Dictionary to store the last sent time for each hazard type
    var lastSentTime: [String: Date] = [:]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        requestAuthorization()
        
        setupVideoPlayer()
        
        detectionHandler = DetectionHandler(modelName: "yolov5s")
        detectionHandler.delegate = self
        
        setupLayers()
       
    }
    
    func setupLayers() {
        detectionLayer = CALayer()
        detectionLayer.frame = view.bounds
        detectionLayer.masksToBounds = true
        playerLayer.addSublayer(detectionLayer)
    }
    
    func requestAuthorization(){
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .carPlay, .sound]) { (granted, error) in
            if granted {
                print("Notification authorization granted")
            } else {
                print("Notification authorization denied")
            }
        }
    }
    
    // Implement DetectionDelegate method
    func didDetect(objects: [VNRecognizedObjectObservation]) {
        print("didDetect view")

        self.detectionLayer.sublayers?.removeAll()
        
        for observation in objects {
                        
            var label = ""
            if let topLabelObservation = observation.labels.first {
                label = "\(topLabelObservation.identifier) \(String(format: "%.2f", topLabelObservation.confidence))"
            }
            
            if observation.labels.first?.identifier == "car" && observation.confidence > 0.8 {
//                self.playSoundAlert() // works
                self.sendBannerAlert(hazardType: "car")
//                self.triggerHapticFeedback() // works

            }
            
            // Transformations
            let objectBounds = getObjectBoundsNew(observation: observation)
            let transformedBounds = transformeObjectBounds(objectBounds: objectBounds)
            self.highlightObject(objectObservation: observation, label: label, bounds: transformedBounds, color: UIColor.red)
        }
        
        // Update detection layer with all object layers
        DispatchQueue.main.async {
          self.detectionLayer.sublayers?.removeAll()
        }
    }
    
    func getObjectBoundsNew(observation: VNDetectedObjectObservation) -> CGRect {
        print("getObjectBounds")

        return VNImageRectForNormalizedRect(observation.boundingBox,
                                            Int(self.screenRect.size.width),
                                            Int(self.screenRect.size.height))
    }

    func transformeObjectBoundsNew(objectBounds: CGRect) -> CGRect {
        print("transformeObjectBoundsNew")

        return CGRect(x: objectBounds.minX,
                      y: self.screenRect.size.height - objectBounds.maxY,
                      width: objectBounds.width,
                      height: objectBounds.height)
    }
    
    func transformeObjectBounds(objectBounds: CGRect) -> CGRect {
        print("transformeObjectBounds")

        return CGRect(x: objectBounds.minX,
                      y: self.screenRect.size.height - objectBounds.maxY,
                      width: objectBounds.maxX - objectBounds.minX,
                      height: objectBounds.maxY - objectBounds.minY)
    }
    
    func detected(_ objectName: String,_ observation: VNRecognizedObjectObservation) -> Bool {
        print("detected")

        return observation.labels.contains(where: { $0.identifier.lowercased().contains(objectName) })
    }
    
    func configureBoxLayer(bounds: CGRect, color: UIColor) -> CALayer {
        print("configureBoxLayer")

        let boxLayer = CALayer()
        boxLayer.frame = bounds
        boxLayer.borderWidth = 2.0
        boxLayer.borderColor = color.cgColor
        boxLayer.cornerRadius = 2
        
        return boxLayer
    }
    
    func configureLabelLayer(bounds: CGRect, label: String, confidence: Float? = nil) -> CATextLayer  {
        print("configureLabelLayer")

        let labelLayer = CATextLayer()
        labelLayer.string = label
        labelLayer.fontSize = 14
        labelLayer.foregroundColor = UIColor.white.cgColor
        labelLayer.backgroundColor = UIColor.black.withAlphaComponent(0.8).cgColor
        labelLayer.alignmentMode = .right // Align to the right for landscape orientation
        labelLayer.cornerRadius = 2
        
        // Position the label at the top right corner of the bounding box
        labelLayer.frame = CGRect(x: bounds.maxX - CGFloat(label.count * 0),
                                  y: bounds.minY - 20,
                                  width: CGFloat(label.count * 7),
                                  height: 20)
        
        return labelLayer
    }

    
    func highlightObject(objectObservation: VNDetectedObjectObservation, label: String, bounds: CGRect, color: UIColor) {
        print("Highlighting \(color.accessibilityName) object...")

        let boxLayer = configureBoxLayer(bounds: bounds, color: color)
        let labelLayer = configureLabelLayer(bounds: bounds, label: label)
        detectionLayer.addSublayer(boxLayer)
        detectionLayer.addSublayer(labelLayer)
    }
    
    func processVideoFrames() {
        print("processVideoFrames")
        let interval = CMTime(value: 1, timescale: 30) // frames per second
        player.addPeriodicTimeObserver(forInterval: interval, queue: DispatchQueue.main) { [weak self] _ in
            guard let self = self, let pixelBuffer = self.retrievePixelBufferAtCurrentTime() else { return }
            detectionHandler.detectObjects(in: pixelBuffer)
        }
    }
    
}

struct HostedViewController: UIViewControllerRepresentable {
    func makeUIViewController(context: Context) -> UIViewController {
        return ObjectDetectionVC()
        }

        func updateUIViewController(_ uiViewController: UIViewController, context: Context) {
        }
}
