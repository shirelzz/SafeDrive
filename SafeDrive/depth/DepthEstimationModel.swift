//
//  DepthEstimationModel.swift
//  SafeDrive
//
//  Created by שיראל זכריה on 07/03/2024.
//

import Foundation
import CoreImage

class DepthEstimationModel {
    
    func estimateDepth(from pixelBuffer: CVPixelBuffer) -> DepthMap? {
        
        // For demonstration purposes, we'll create a mock depth map with random values
        let width = CVPixelBufferGetWidth(pixelBuffer)
        let height = CVPixelBufferGetHeight(pixelBuffer)
        let depthValues = (0..<(width * height)).map { _ in Float.random(in: 0.0...10.0) } // Random depth values between 0 and 10 meters
        return DepthMap(width: width, height: height, values: depthValues)
    }
}

struct DepthMap {
    let width: Int
    let height: Int
    let values: [Float]
    
    func containsNearbyHazards() -> Bool {
        
        let hazardThreshold: Float = 2.0 // Threshold for hazard proximity in meters
        for depthValue in values {
            if depthValue < hazardThreshold {
                return true // Hazard detected nearby
            }
        }
        return false
    }
}

