//
//  DetectionHandler.swift
//  SafeDrive
//
//  Created by שיראל זכריה on 12/03/2024.
//

import Foundation
import Vision
import CoreML
import UIKit

protocol DetectionDelegate: AnyObject {
    func didDetect(objects: [VNRecognizedObjectObservation])
}

class DetectionHandler {
    
    private var detectionRequests: [VNRequest] = []
    weak var delegate: DetectionDelegate?

    init(modelName: String) {
        setupDetector(modelName: modelName)
    }
    
    private func setupDetector(modelName: String) {
        print("setupDetector")
        guard let modelURL = Bundle.main.url(forResource: modelName, withExtension: "mlmodelc") else {
            print("\(modelName) model not found")
            return
        }
        
        do {
            let visionModel = try VNCoreMLModel(for: MLModel(contentsOf: modelURL))
            print("visionModel: \(visionModel.description)")

            let objectRecognition = VNCoreMLRequest(model: visionModel) { [weak self] (request, error) in
                print("objectRecognition")
                self?.processDetections(for: request, error: error)
                print("processed Detections")

            }
            print("objectRecognition: \(objectRecognition.description)")

            detectionRequests = [objectRecognition]
        } catch {
            print("Failed to load Vision ML model: \(error)")
        }
        print("end setupDetector")

    }
    
    func detectObjects(in pixelBuffer: CVPixelBuffer) {
        print("detectObjects")

        let handler = VNImageRequestHandler(cvPixelBuffer: pixelBuffer, orientation: .up, options: [:])
        do {
            try handler.perform(detectionRequests)
        } catch {
            print("Failed to perform detection.\n\(error.localizedDescription)")
        }
        
        if isHazardNearby(pixelBuffer) {
            // Hazard detected and is nearby, trigger alert
            Alerts.voiceAlert(soundName: "softAlert")
        } else {
            print("Detected hazard is not nearby, no alert triggered")
        }
    }
    
    private func processDetections(for request: VNRequest, error: Error?) {
        print("processDetections")

        DispatchQueue.main.async { [weak self] in
            guard let results = request.results as? [VNRecognizedObjectObservation] else {
                print("Unable to detect anything.\n\(String(describing: error))")
                return
            }
          
            self?.delegate?.didDetect(objects: results)
        }
    }
    
    private func isHazardNearby(_ pixelBuffer: CVPixelBuffer) -> Bool {
        print("isHazardNearby")

//        // Simulate proximity assessment by estimating depth from the image
//        
//        let depthEstimationModel = DepthEstimationModel()
//        
//        guard let depthMap = depthEstimationModel.estimateDepth(from: pixelBuffer) else {
//            fatalError("Failed to estimate depth from image")
//        }
//        
//        let hazardsNearby = depthMap.containsNearbyHazards()
        
        return false // hazardsNearby
    }
    
}
