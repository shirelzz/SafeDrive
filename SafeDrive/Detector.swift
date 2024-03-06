////
////  Detector.swift
////  SafeDrive
////
////  Created by שיראל זכריה on 05/03/2024.
////
//
//import Foundation
//import Vision
//import AVFoundation
//import UIKit
//
//extension ViewController {
//    
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
////            let recognitionRequest = VNCoreMLRequest(model: visionModel, completionHandler: { [weak self] request, error in
////                self?.detectionDidComplete(request: request, error: error)
////            })
//            let recognitionRequest = VNCoreMLRequest(model: visionModel, completionHandler: { (request, error) in
//
//                DispatchQueue.main.async(execute: {
//                    // perform all the UI updates on the main queue
//                    if let results = request.results {
//                        print("results 0: \(results)")
//                        self.extractDetections(results)
//                        
//                        if results.isEmpty {
//                            print("results is empty")
//                        }
//                    }
//                    print("no results")
//
//                })
//            })
//            
//            print("recognitionRequest model: \(recognitionRequest.model)")
//            print("recognitionRequest model: \(recognitionRequest.debugDescription)")
//            
//            requests = [recognitionRequest]
//            
//
//            
//        } catch {
//            print("Error loading Core ML model: \(error)")
//        }
//    }
//
//    func detectionDidComplete(request: VNRequest, error: Error?) {
//        guard let results = request.results else {
//            print("No results found")
//            return
//        }
//        print("Results received: \(results)")
//        
//        if results.isEmpty {
//            print("results is empty")
//        }
//
//
//        DispatchQueue.main.async {
//            self.extractDetections(results)
//            print("Object detection results: \(results)")
//        }
//    }
//
//    
//    func extractDetections(_ results: [Any]) {
//        print("results 3: \(results)")
//        detectionLayer.sublayers?.forEach { $0.removeFromSuperlayer() }
//        
//        for observation in results where observation is VNRecognizedObjectObservation {
//            guard let objectObservation = observation as? VNRecognizedObjectObservation else { continue }
//            
//            let objectBounds = VNImageRectForNormalizedRect(objectObservation.boundingBox,
//                                                            Int(screenRect.size.width),
//                                                            Int(screenRect.size.height))
//            print("Object Bounds: \(objectBounds)")
//
//            let transformedBounds = CGRect(
//                x: objectBounds.minX,
//                y: screenRect.size.height - objectBounds.maxY,
//                width: objectBounds.maxX - objectBounds.minX,
//                height: objectBounds.maxY - objectBounds.minY)
//            print("transformedBounds: \(transformedBounds)")
//            
//            let boxLayer = drawBoundingBox(transformedBounds)
//            detectionLayer.addSublayer(boxLayer)
//            
//            print("Drawing bounding box at: \(boxLayer.frame)")
//
//        }
//    }
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
//}
