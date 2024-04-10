//
//  DepthMap.swift
//  SafeDrive
//
//  Created by שיראל זכריה on 07/03/2024.
//

import Foundation
import CoreImage

struct DepthMap {
    let width: Int
    let height: Int
    let values: [Float]
    
    init(pixelBuffer: CVPixelBuffer) {
        self.width = CVPixelBufferGetWidth(pixelBuffer)
        self.height = CVPixelBufferGetHeight(pixelBuffer)
        self.values = [Float](repeating: 0.0, count: width * height)
    }
    
    func containsNearbyHazards(hazardThreshold: Float) -> Bool {
        for depthValue in values {
            if depthValue < hazardThreshold {
                return true // Hazard detected nearby
            }
        }
        return false
    }
}

