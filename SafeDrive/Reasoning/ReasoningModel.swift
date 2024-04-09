//
//  ReasoningModel.swift
//  SafeDrive
//
//  Created by שיראל זכריה on 12/03/2024.
//

import Foundation

struct DetectedObject {
    var type: String
    var position: CGRect // Using CGRect to represent the object's position; in a real application, this might need to be more complex
    var confidence: CGFloat
}


func isHazard(detectedObjects: [DetectedObject], safeDistance: CGFloat) -> Bool {
    for object in detectedObjects {
        switch object.type {
        case "pedestrian":
            if object.position.origin.y < safeDistance {
                print("Pedestrian too close! Hazard detected.")
                return true
            }
        case "stop sign":
            // Assuming we have logic to determine the relevance of the sign
            print("Stop sign detected ahead! Hazard.")
            return true
        default:
            continue
        }
    }
    return false
}
