//
//  DepthEstimationHandler.swift
//  SafeDrive
//
//  Created by שיראל זכריה on 19/03/2024.
//

import Foundation
import Vision
import CoreML

protocol DepthEstimationDelegate: AnyObject {
    func didEstimateDepth(depthMap: DepthMap?)
}

class DepthEstimationHandler {
    
    private var depthEstimationRequest: VNCoreMLRequest!
    weak var delegate: DepthEstimationDelegate?
    
    init(modelName: String) {
        setupEstimator(modelName: modelName)
    }
    
    private func setupEstimator(modelName: String) {
        guard let modelURL = Bundle.main.url(forResource: modelName, withExtension: "mlmodelc") else {
            print("\(modelName) model not found")
            return
        }
        
        do {
            let visionModel = try VNCoreMLModel(for: MLModel(contentsOf: modelURL))
            depthEstimationRequest = VNCoreMLRequest(model: visionModel) { [weak self] (request, error) in
                self?.processEstimation(for: request, error: error)
            }
            depthEstimationRequest.imageCropAndScaleOption = .scaleFill
        } catch {
            print("Failed to load Vision ML model: \(error)")
        }
    }
    
    func estimateDepth(from pixelBuffer: CVPixelBuffer) {
        let handler = VNImageRequestHandler(cvPixelBuffer: pixelBuffer, orientation: .up, options: [:])
        do {
            try handler.perform([depthEstimationRequest])
        } catch {
            print("Failed to perform depth estimation.\n\(error.localizedDescription)")
        }
    }
    
    private func processEstimation(for request: VNRequest, error: Error?) {
        guard let results = request.results as? [VNPixelBufferObservation],
              let depthMapPixelBuffer = results.first?.pixelBuffer else {
            print("Unable to estimate depth.\n\(String(describing: error))")
            delegate?.didEstimateDepth(depthMap: nil)
            return
        }
        
        let depthMap = DepthMap(pixelBuffer: depthMapPixelBuffer)
        delegate?.didEstimateDepth(depthMap: depthMap)
    }
}
