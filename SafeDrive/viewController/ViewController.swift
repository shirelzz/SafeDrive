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

class ViewController: UIViewController, DetectionDelegate, TrackingDelegate  {
    
    func trackingHandler(_ handler: TrackingHandler, didUpdate trackingResults: [VNDetectedObjectObservation], for uuid: UUID, label: String) {
        print("trackingHandler: label: \(label)")
        DispatchQueue.main.async {
            // Update UI based on tracking results, e.g., draw bounding boxes
            for observation in trackingResults { // VNDetectedObjectObservation, VNRecognizedObjectObservation
                let bounds = self.getObjectBoundsNew(observation: observation)
                print("bounds: \(bounds)")

                let transformeBounds = self.transformeObjectBounds(objectBounds: bounds)
                print("transformeBounds: \(transformeBounds)")

                self.highlightObject(objectObservation: observation, label: label, bounds: transformeBounds, color: UIColor.blue) //.updateBoundingBox(observation, uuid: uuid)
            }
        }
    }
    
    
    var detectionHandler: DetectionHandler!
    var trackingHandler: TrackingHandler!
//    private var trackedObjects = [UUID: TrackedObject]()
    private var trackedObjects = [UUID: TrackedPolyRect]()

    var player: AVPlayer!
    var playerLayer: AVPlayerLayer!
    var videoOutput: AVPlayerItemVideoOutput!
//    var videoView: VideoContainerView!
    var requests = [VNRequest]()
    var detectionLayer: CALayer!
    var screenRect: CGRect! = UIScreen.main.bounds
    var audioPlayer: AVAudioPlayer?
    
    var objectLayers = [UUID: (boxLayer: CALayer, labelLayer: CATextLayer)]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupVideoPlayer()
        
        detectionHandler = DetectionHandler(modelName: "yolov5s")
        detectionHandler.delegate = self
        
        trackingHandler = TrackingHandler()
        trackingHandler.delegate = self
        
        setupLayers()
       
    }
    
    func setupLayers() {
        detectionLayer = CALayer()
        detectionLayer.frame = view.bounds
        detectionLayer.masksToBounds = true
        playerLayer.addSublayer(detectionLayer)
    }
    
    func RequestAuthorization(){
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound]) { (granted, error) in
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

//        self.detectionLayer.sublayers?.removeAll()
        var objectLayers = [UUID: (boxLayer: CALayer, labelLayer: CATextLayer)]()
        
        for observation in objects {
            
            var label = ""
            if let topLabelObservation = observation.labels.first {
                label = "\(topLabelObservation.identifier) \(String(format: "%.2f", topLabelObservation.confidence))"
            }
            
            if observation.labels.first?.identifier == "car" && observation.confidence > 0.8 {
                let uuid = UUID()
                let pixelBuffer = retrievePixelBufferAtCurrentTime() ?? nil
                if pixelBuffer != nil {
                    trackingHandler.startTracking(object: observation, label: label, uuid: uuid, in: pixelBuffer!)
//                    trackingHandler.startTracking(objectsToTrack: [observation], type: TrackingType.object, in: pixelBuffer!)
                } else {
                    print("--- pixelBuffer is nil")
                }
            }
            
            // Transformations
            let objectBounds = getObjectBoundsNew(observation: observation)
            let transformedBounds = transformeObjectBounds(objectBounds: objectBounds)
//            self.highlightObject(objectObservation: observation, label: label, bounds: transformedBounds, color: UIColor.red) // red for object detection
        }
        
        // Update detection layer with all object layers
        DispatchQueue.main.async {
          self.detectionLayer.sublayers?.removeAll()
          for (_, layers) in objectLayers {
            self.detectionLayer.addSublayer(layers.boxLayer)
            self.detectionLayer.addSublayer(layers.labelLayer)
          }
        }
        
//        if personDetected {
//            print("person detected")
//            self.sendBannerAlert()
//            self.playSoundAlert()
//            personDetected = false
//        }
    }
    
    func getObjectBoundsNew(observation: VNDetectedObjectObservation) -> CGRect {
        print("getObjectBounds")

        return VNImageRectForNormalizedRect(observation.boundingBox, Int(self.screenRect.size.width), Int(self.screenRect.size.height))
    }

    func transformeObjectBoundsNew(objectBounds: CGRect) -> CGRect {
        print("transformeObjectBoundsNew")

        return CGRect(x: objectBounds.minX,
                      y: self.screenRect.size.height - objectBounds.maxY,
                      width: objectBounds.width,
                      height: objectBounds.height)
    }
    
    func getObjectBounds(observation: VNRecognizedObjectObservation) -> CGRect {
        print("getObjectBoundsOld")

        return VNImageRectForNormalizedRect(observation.boundingBox,
                                            Int(self.screenRect.size.width),
                                            Int(self.screenRect.size.height))
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
    
    func configureLabelLayer(bounds: CGRect, label: String, confidence: Float? = nil) -> CALayer {
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

    
//    func configureLabelLayer(objectObservation: VNRecognizedObjectObservation, bounds: CGRect) -> CALayer {
//        print("configureLabelLayer")
//
//        if let topLabelObservation = objectObservation.labels.first {
//            let labelString = "\(topLabelObservation.identifier) \(String(format: "%.2f", topLabelObservation.confidence))"
//            let labelLayer = CATextLayer()
//            labelLayer.string = labelString
//            labelLayer.fontSize = 14
//            labelLayer.foregroundColor = UIColor.white.cgColor
//            labelLayer.backgroundColor = UIColor.black.withAlphaComponent(0.8).cgColor
//            labelLayer.alignmentMode = .right // Align to the right for landscape orientation
//            labelLayer.cornerRadius = 2
//            
//            // Position the label at the top right corner of the bounding box
//            labelLayer.frame = CGRect(x: bounds.maxX - CGFloat(labelString.count * 0),
//                                      y: bounds.minY - 20,
//                                      width: CGFloat(labelString.count * 7),
//                                      height: 20)
//            
//            return labelLayer
//        }
//        
//        return CALayer()
//    }
    
    func highlightObject(objectObservation: VNDetectedObjectObservation, label: String, bounds: CGRect, color: UIColor) {
        print("Highlighting \(color.accessibilityName) object...")

        let boxLayer = configureBoxLayer(bounds: bounds, color: color)
        let labelLayer = configureLabelLayer(bounds: bounds, label: label) //configureLabelLayer(objectObservation: objectObservation, bounds: bounds)
        detectionLayer.addSublayer(boxLayer)
        detectionLayer.addSublayer(labelLayer)
        
//        let uuid = UUID()
//        objectLayers[uuid] = (boxLayer: boxLayer, labelLayer: labelLayer)
    }
    
    
    func didUpdateTracking(for objects: [VNDetectedObjectObservation], uuid: UUID) {
        print("didUpdateTracking")

        // Assuming trackedObjects now maps UUIDs to VNDetectedObjectObservation for simplicity
        guard let trackedObject = trackedObjects[uuid] else { return }
        
        // Update the position of the object's boxLayer and labelLayer based on the tracking results
        if let newObservation = objects.first as? VNRecognizedObjectObservation {
            let newBounds = getObjectBoundsNew(observation: newObservation)
            let transformedBounds = transformeObjectBounds(objectBounds: newBounds)
            self.highlightObject(objectObservation: newObservation, label: "String", bounds: transformedBounds, color: UIColor.blue)

            // Update existing layers for this UUID
            if let layers = objectLayers[uuid] {
                layers.boxLayer.frame = transformedBounds
                layers.boxLayer.borderColor = UIColor.blue.cgColor // Change color to blue for tracking
                // Ensure to update the layer's position on the main thread
                DispatchQueue.main.async {
                    self.detectionLayer.addSublayer(layers.boxLayer)
                }
            }
            else {
                // Create new layers for this UUID and highlight the tracked object
                highlightTrackedObject(objectBounds: transformedBounds, color: UIColor.blue, uuid: uuid)
            }
        }
        
        if objects.isEmpty {
            // Object not detected in the current frame, stop tracking
            trackingHandler.stopTracking(uuid: uuid)
            // Also remove associated layers
            if let layers = objectLayers[uuid] {
                layers.boxLayer.removeFromSuperlayer()
                objectLayers.removeValue(forKey: uuid)
            }
        }
    }
    
    func highlightTrackedObject(objectBounds: CGRect, color: UIColor, uuid: UUID) {
         let boxLayer = configureBoxLayer(bounds: objectBounds, color: color)
         detectionLayer.addSublayer(boxLayer)
         objectLayers[uuid] = (boxLayer: boxLayer, labelLayer: CATextLayer()) // Store the box layer
     }

    
    // Method to process video frames and perform detection and tracking
    func processVideoFrames() {
        print("processVideoFrames")
        // Here you'd capture frames from your video source and call:
        // Adjust this interval to control the frequency of frame processing
        let interval = CMTime(value: 1, timescale: 1) // Example: 1 frame per second
        player.addPeriodicTimeObserver(forInterval: interval, queue: DispatchQueue.main) { [weak self] _ in
            guard let self = self, let pixelBuffer = self.retrievePixelBufferAtCurrentTime() else { return }
            detectionHandler.detectObjects(in: pixelBuffer)
        }
        // This method could be invoked repeatedly, such as from a timer or an AVFoundation capture session callback
    }
    
}

struct HostedViewController: UIViewControllerRepresentable {
    func makeUIViewController(context: Context) -> UIViewController {
        return ViewController()
        }

        func updateUIViewController(_ uiViewController: UIViewController, context: Context) {
        }
}
