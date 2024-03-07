//
//  Detector.swift
//  SafeDrive
//
//  Created by שיראל זכריה on 05/03/2024.
//

import Vision
import CoreML
import UIKit

extension ViewController {
    
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
        
        let isHazardNearby = self.isHazardNearby(pixelBuffer)
        if isHazardNearby {
            // Hazard detected and is nearby, trigger alert
            Alerts.voiceAlert(soundName: "softAlert")
        } else {
            print("Detected hazard is not nearby, no alert triggered")
        }
    }
    
    func processDetections(for request: VNRequest, error: Error?) {
        DispatchQueue.main.async {
            guard let results = request.results else {
                print("Unable to detect anything.\n\(String(describing: error))")
                return
            }
            
            self.detectionLayer.sublayers?.removeAll()
            
            var personDetected = false
            
            for observation in results where observation is VNRecognizedObjectObservation {
                guard let objectObservation = observation as? VNRecognizedObjectObservation else { continue }
                
                // If a person is detected, send alerts
                if objectObservation.labels.contains(where: { $0.identifier.lowercased().contains("cat") }) {
                    personDetected = true
                }
                
                // Transformations
                let objectBounds = VNImageRectForNormalizedRect(objectObservation.boundingBox, Int(self.screenRect.size.width), Int(self.screenRect.size.height))
                let transformedBounds = CGRect(x: objectBounds.minX,
                                               y: self.screenRect.size.height - objectBounds.maxY,
                                               width: objectBounds.maxX - objectBounds.minX,
                                               height: objectBounds.maxY - objectBounds.minY)
            
                self.highlightObject(objectObservation: objectObservation, bounds: transformedBounds)
            }
            
            // Send alerts if person is detected
            if personDetected {
                print("person detected")
                self.sendBannerAlert()
                self.playSoundAlert()
                personDetected = false
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
            labelLayer.frame = CGRect(x: bounds.maxX - CGFloat(labelString.count * 0),
                                      y: bounds.minY - 20,
                                      width: CGFloat(labelString.count * 7),
                                      height: 20)
            detectionLayer.addSublayer(labelLayer)
            print("Label layer added")
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
    
    private func isHazardNearby(_ pixelBuffer: CVPixelBuffer) -> Bool {
        // Simulate proximity assessment by estimating depth from the image
        
        let depthEstimationModel = DepthEstimationModel()
        
        guard let depthMap = depthEstimationModel.estimateDepth(from: pixelBuffer) else {
            fatalError("Failed to estimate depth from image")
        }
        
        let hazardsNearby = depthMap.containsNearbyHazards()
        
        return hazardsNearby
    }
}
