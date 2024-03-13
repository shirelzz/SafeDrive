//
//  ObjectTrackingModel.swift
//  SafeDrive
//
//  Created by שיראל זכריה on 12/03/2024.
//

import Foundation
import UIKit
import Vision


protocol TrackingDelegate: AnyObject {
    func trackingHandler(_ handler: TrackingHandler, didUpdate trackingResults: [VNDetectedObjectObservation], for uuid: UUID, label: String)

//    func didUpdateTracking(for objects: [VNDetectedObjectObservation], uuid: UUID)
}


class TrackingHandler {
    
    var delegate: TrackingDelegate?
    private var sequenceHandler = VNSequenceRequestHandler()
//    private var trackedRequests = [UUID: VNTrackObjectRequest]()
    private var activeTrackings = [UUID: VNTrackObjectRequest]()

//    private var trackingRequests: [VNTrackObjectRequest] = []
    
    
    func startTracking(object: VNRecognizedObjectObservation, label: String, uuid: UUID, in pixelBuffer: CVPixelBuffer) {
        let trackingRequest = VNTrackObjectRequest(detectedObjectObservation: object) { [weak self] request, error in
            guard let self = self else { return }
            if let error = error {
                print("Tracking error: \(error.localizedDescription)")
                return
            }
            if let trackingResults = request.results as? [VNDetectedObjectObservation] {
                self.delegate?.trackingHandler(self, didUpdate: trackingResults, for: uuid, label: label)
            }
        }
        trackingRequest.trackingLevel = .accurate
        self.activeTrackings[uuid] = trackingRequest
        
        do {
            try sequenceHandler.perform([trackingRequest], on: pixelBuffer, orientation: .up)
        } catch {
            print("Failed to start tracking: \(error)")
        }
    }

    
//    func startTracking(objectsToTrack: [VNRecognizedObjectObservation], type: TrackingType, in pixelBuffer: CVPixelBuffer) {
//        var inputObservations = [UUID: VNDetectedObjectObservation]()
//        var trackedObjects = [UUID: TrackedPolyRect]()
//        
//        switch type {
//        case .object:
//            for observation in objectsToTrack {
//                let inputObservation = VNDetectedObjectObservation(boundingBox: observation.boundingBox)
//                inputObservations[inputObservation.uuid] = inputObservation
//                trackedObjects[inputObservation.uuid] = observation // Assuming TrackedPolyRect is your custom tracking object
//            }
//        case .rectangle:
//            // Handle rectangle tracking if needed
//            break
//        }
//        
//        // Create tracking requests for each object
//        var trackingRequests = [VNTrackObjectRequest]()
//        for (uuid, inputObservation) in inputObservations {
//            let request = VNTrackObjectRequest(detectedObjectObservation: inputObservation)
//            request.trackingLevel = .accurate // Set tracking level as needed
//            trackingRequests.append(request)
//            trackedRequests[uuid] = request
//        }
//        
//        // Perform tracking using sequence handler
//        do {
//            try sequenceHandler.perform(trackingRequests, on: pixelBuffer, orientation: .up)
//        } catch {
//            print("Failed to start tracking: \(error)")
//        }
//    }

//    func startTracking(object: VNRecognizedObjectObservation, uuid: UUID, in pixelBuffer: CVPixelBuffer) {
//        print("startTracking")
//
//        let trackingRequest = VNTrackObjectRequest(detectedObjectObservation: object) { [weak self] request, error in
//            // Call the delegate method with the UUID
//            guard let trackingResults = request.results as? [VNDetectedObjectObservation] else {
//                print("Tracking failed: \(error?.localizedDescription ?? "Unknown error")")
//                return
//            }
////            self?.delegate?.didUpdateTracking(for: trackingResults, uuid: uuid)
//        }
//        trackingRequest.trackingLevel = .accurate
//        trackedRequests[uuid] = trackingRequest
//
//        do {
//            try sequenceHandler.perform([trackingRequest], on: pixelBuffer, orientation: .up)
//        } catch {
//            print("Failed to start tracking: \(error)")
//        }
//    }
    
    func stopTracking(uuid: UUID) {
      print("stopTracking for \(uuid)")
//
//      // Remove the associated tracking request if it exists
//      if let request = trackedRequests[uuid] {
//        trackedRequests.removeValue(forKey: uuid)
////          sequenceHandler. .removeRequest(request) // Use the correct method for cancellation
//      } else {
//        print("WARNING: Stop tracking requested for non-existent UUID: \(uuid)")
//      }
        
        activeTrackings.removeValue(forKey: uuid)

    }
    

//    func addTrackingRequest(_ request: VNTrackObjectRequest) {
//      trackingRequests.append(request)
//    }
//
//    func removeTrackingRequest(uuid: UUID) {
//      trackingRequests.removeAll { $0.uuid == uuid }
//    }

}
