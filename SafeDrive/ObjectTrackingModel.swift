////
////  ObjectTrackingModel.swift
////  SafeDrive
////
////  Created by שיראל זכריה on 12/03/2024.
////
//
//import Foundation
//import UIKit
//import Vision
//
//
//protocol TrackingDelegate: AnyObject {
//    func trackingHandler(_ handler: TrackingHandler, didUpdate trackingResults: [VNDetectedObjectObservation], for uuid: UUID, label: String)
//
////    func didUpdateTracking(for objects: [VNDetectedObjectObservation], uuid: UUID)
//}
//
//
//class TrackingHandler {
//    
//    var delegate: TrackingDelegate?
//    private var sequenceHandler = VNSequenceRequestHandler()
////    private var trackedRequests = [UUID: VNTrackObjectRequest]()
//    private var activeTrackings = [UUID: VNTrackObjectRequest]()
//
////    private var trackingRequests: [VNTrackObjectRequest] = []
//    
//    
//    func startTracking(object: VNRecognizedObjectObservation, label: String, uuid: UUID, in pixelBuffer: CVPixelBuffer) {
//        let trackingRequest = VNTrackObjectRequest(detectedObjectObservation: object) { [weak self] request, error in
//            guard let self = self else { return }
//            if let error = error {
//                print("Tracking error: \(error.localizedDescription)")
//                return
//            }
//            if let trackingResults = request.results as? [VNDetectedObjectObservation] {
//                self.delegate?.trackingHandler(self, didUpdate: trackingResults, for: uuid, label: label)
//            }
//        }
//        trackingRequest.trackingLevel = .accurate
//        self.activeTrackings[uuid] = trackingRequest
//        
//        do {
//            try sequenceHandler.perform([trackingRequest], on: pixelBuffer, orientation: .up)
//        } catch {
//            print("Failed to start tracking: \(error)")
//        }
//    }
//    
//    func stopTracking(uuid: UUID) {
//      print("stopTracking for \(uuid)")
//        
//      // Remove the associated tracking request if it exists
//      if let request = activeTrackings[uuid] {
//          activeTrackings.removeValue(forKey: uuid)
//      } else {
//        print("WARNING: Stop tracking requested for non-existent UUID: \(uuid)")
//      }
//        
//    }
//
//}
