////
////  ObjectTracker.swift
////  SafeDrive
////
////  Created by שיראל זכריה on 12/03/2024.
////
//
//import Foundation
//import Vision
//import UIKit
//
//class ObjectTracker {
//    private var trackingRequests: [VNRequest] = []
//    private var sequenceHandler = VNSequenceRequestHandler()
//    
//    // Function to start tracking a detected object
//    func startTracking(object: VNRecognizedObjectObservation, in pixelBuffer: CVPixelBuffer) {
//        let trackingRequest = VNTrackObjectRequest(detectedObjectObservation: object) { [weak self] request, error in
//            guard let strongSelf = self else { return }
//            if let trackingError = error {
//                print("Tracking failed: \(trackingError.localizedDescription)")
//                return
//            }
//            
//            // Update the UI or take actions based on tracking result
//            strongSelf.updateTrackingResults(for: request)
//        }
//        
//        // Use the detected object's bounding box as the input for tracking
//        trackingRequest.inputObservation = object
//        trackingRequests.append(trackingRequest)
//        
//        // Perform the tracking request
//        performTrackingRequest(pixelBuffer: pixelBuffer)
//    }
//    
//    // Function to update the tracking with new video frames
//    func performTrackingRequest(pixelBuffer: CVPixelBuffer) {
//        guard !trackingRequests.isEmpty else { return }
//        do {
//            try sequenceHandler.perform(trackingRequests, on: pixelBuffer)
//        } catch {
//            print("Failed to perform sequence request: \(error.localizedDescription)")
//        }
//    }
//    
//    // Handling tracking results to update the UI or logic based on new positions
//    private func updateTrackingResults(for request: VNRequest) {
//        DispatchQueue.main.async {
//            guard let trackingResults = request.results else {
//                print("No tracking results")
//                return
//            }
//            
//            for result in trackingResults {
//                if let observation = result as? VNDetectedObjectObservation {
//                    // Handle the updated tracking result, e.g., update a UI element or trigger an action
//                    // The `observation.boundingBox` gives you the new position of the tracked object
//                    print("Updated object position: \(observation.boundingBox)")
//                }
//            }
//        }
//    }
//}
//
//
