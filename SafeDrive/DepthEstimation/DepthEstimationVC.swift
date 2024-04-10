//
//  DepthEstimationVC.swift
//  SafeDrive
//
//  Created by שיראל זכריה on 09/04/2024.
//

import SwiftUI
import UIKit
import AVFoundation
import Vision
import CoreML
import AVKit
import CoreVideo
import Accelerate

class DepthEstimationVC: UIViewController, UNUserNotificationCenterDelegate, DepthEstimationDelegate {
    
    var player: AVPlayer!
    var playerLayer: AVPlayerLayer!
    var videoOutput: AVPlayerItemVideoOutput!
    
    var depthEstimationHandler: DepthEstimationHandler!
    var depthLayer: CALayer!
    var screenRect: CGRect! = UIScreen.main.bounds
    
    let thresholdDistance: Double = 1.0 // Threshold distance in meters
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupVideoPlayer()
        
        depthEstimationHandler = DepthEstimationHandler(modelName: "FCRNFP16")
        depthEstimationHandler.delegate = self

        setupLayers()
        
        processVideoFrames()
    }
    
    func didEstimateDepth(depthMapPixelBuffer: CVPixelBuffer?) {
        guard let depthMapPixelBuffer = depthMapPixelBuffer else { return }
        displayDepthEstimation(depthMapPixelBuffer: depthMapPixelBuffer)
        
        // Convert depth values to meters
        let depthValue = convertDepthValueToMeters(depthMapPixelBuffer)
        // Check if object is too close
        if depthValue < thresholdDistance {
            raiseAlert()
        }
    }

    func displayDepthEstimation(depthMapPixelBuffer: CVPixelBuffer) {
        let grayscaleImage = createGrayscaleImage(from: depthMapPixelBuffer)
        depthLayer.contents = grayscaleImage?.cgImage
    }

    func raiseAlert() {
        let alertController = UIAlertController(title: "Object Too Close", message: "An object is too close!", preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alertController, animated: true, completion: nil)
    }

    func setupLayers() {
        depthLayer = CALayer()
        depthLayer.frame = view.bounds
        depthLayer.masksToBounds = true
        playerLayer.addSublayer(depthLayer)
    }
    
    func processVideoFrames() {
        let interval = CMTime(value: 1, timescale: 30) // frame per second
        player.addPeriodicTimeObserver(forInterval: interval, queue: DispatchQueue.main) { [weak self] _ in
            guard let self = self, let pixelBuffer = self.retrievePixelBufferAtCurrentTime() else { return }
            self.depthEstimationHandler.estimateDepth(from: pixelBuffer)
        }
    }
    
    func createGrayscaleImage(from depthMapPixelBuffer: CVPixelBuffer) -> UIImage? {
        // Lock the pixel buffer to access its data
        CVPixelBufferLockBaseAddress(depthMapPixelBuffer, .readOnly)
        defer { CVPixelBufferUnlockBaseAddress(depthMapPixelBuffer, .readOnly) }
        
        // Get the width and height of the pixel buffer
        let width = CVPixelBufferGetWidth(depthMapPixelBuffer)
        let height = CVPixelBufferGetHeight(depthMapPixelBuffer)
        
        // Create a grayscale context
        let colorSpace = CGColorSpaceCreateDeviceGray()
        let bitmapInfo = CGBitmapInfo(rawValue: CGImageAlphaInfo.none.rawValue)
        guard let context = CGContext(data: nil,
                                      width: width,
                                      height: height,
                                      bitsPerComponent: 8,
                                      bytesPerRow: width,
                                      space: colorSpace,
                                      bitmapInfo: bitmapInfo.rawValue) else {
            return nil
        }
        
        // Draw the pixel buffer into the context
        context.draw(depthMapPixelBuffer as! CGLayer, in: CGRect(x: 0, y: 0, width: width, height: height))
        
        // Create a CGImage from the context
        guard let cgImage = context.makeImage() else {
            return nil
        }
        
        // Create a UIImage from the CGImage
        let grayscaleImage = UIImage(cgImage: cgImage)
        
        return grayscaleImage
    }

    func convertDepthValueToMeters(_ depthMapPixelBuffer: CVPixelBuffer) -> Double {
        // Implementation of depth value to meters conversion
        // Assuming depth values are stored as normalized values (0.0 to 1.0)
        // You may need to adjust this conversion based on your depth estimation model output
        let normalizedDepthValue: Double = 0.5 // Example normalized depth value
        let maxDepthRange: Double = 10.0 // Maximum depth range in meters
        return normalizedDepthValue * maxDepthRange
    }

    func retrievePixelBufferAtCurrentTime() -> CVPixelBuffer? {
        let itemTime = player.currentTime()
        guard let outputItem = player.currentItem,
              let track = outputItem.asset.tracks(withMediaType: AVMediaType.video).first else {
            return nil
        }
        
        let imageGenerator = AVAssetImageGenerator(asset: outputItem.asset)
        imageGenerator.appliesPreferredTrackTransform = true
        
        do {
            let time = CMTimeMake(value: itemTime.value, timescale: itemTime.timescale)
            let imageRef = try imageGenerator.copyCGImage(at: time, actualTime: nil)
            return imageRef.toPixelBuffer()
        } catch {
            print("Error retrieving pixel buffer: \(error)")
            return nil
        }
    }


}

// Implement DepthEstimationHandler, CVPixelBuffer extensions, and DepthEstimationDelegate as before


extension CVPixelBuffer {
    
    func toGrayscaleImage() -> UIImage? {
        // Lock the pixel buffer
        CVPixelBufferLockBaseAddress(self, .readOnly)
//        defer { CVPixelBufferUnlockBaseAddress(self, .readOnly) }

        // Get the number of bytes per row for the pixel buffer
        let baseAddress = CVPixelBufferGetBaseAddress(self)
        let bytesPerRow = CVPixelBufferGetBytesPerRow(self)
        let width = CVPixelBufferGetWidth(self)
        let height = CVPixelBufferGetHeight(self)

        // Create a grayscale context
        let colorSpace = CGColorSpaceCreateDeviceGray()
        let bitmapInfo = CGBitmapInfo(rawValue: CGImageAlphaInfo.none.rawValue)
        
        // Create a bitmap graphics context with the sample buffer data
        guard let context = CGContext(data: baseAddress,
                                      width: width,
                                      height: height,
                                      bitsPerComponent: 8,
                                      bytesPerRow: bytesPerRow,
                                      space: colorSpace,
                                      bitmapInfo: CGImageAlphaInfo.none.rawValue)
        else { return nil }

//        // Draw the image into the context
//        context?.draw(self, in: CGRect(x: 0, y: 0, width: width, height: height))

        // Unlock the pixel buffer
        CVPixelBufferUnlockBaseAddress(self, .readOnly)

        // Create a grayscale image from the context
        guard let grayscaleImage = context.makeImage() else { return nil }

        return UIImage(cgImage: grayscaleImage)
    }
}

extension CGImage {
    func toPixelBuffer() -> CVPixelBuffer? {
        let width = self.width
        let height = self.height
        
        // Define pixel buffer attributes
        let pixelBufferAttributes: [String: Any] = [
            kCVPixelBufferCGImageCompatibilityKey as String: NSNumber(value: true),
            kCVPixelBufferCGBitmapContextCompatibilityKey as String: NSNumber(value: true),
            kCVPixelBufferWidthKey as String: NSNumber(value: width),
            kCVPixelBufferHeightKey as String: NSNumber(value: height),
            kCVPixelBufferPixelFormatTypeKey as String: NSNumber(value: kCVPixelFormatType_32ARGB)
        ]
        
        var pixelBuffer: CVPixelBuffer?
        let status = CVPixelBufferCreate(kCFAllocatorDefault, width, height, kCVPixelFormatType_32ARGB, pixelBufferAttributes as CFDictionary?, &pixelBuffer)
        
        guard status == kCVReturnSuccess, let unwrappedPixelBuffer = pixelBuffer else {
            return nil
        }
        
        CVPixelBufferLockBaseAddress(unwrappedPixelBuffer, [])
        defer { CVPixelBufferUnlockBaseAddress(unwrappedPixelBuffer, []) }
        
        let pixelData = CVPixelBufferGetBaseAddress(unwrappedPixelBuffer)
        
        let rgbColorSpace = CGColorSpaceCreateDeviceRGB()
        guard let context = CGContext(data: pixelData, width: width, height: height, bitsPerComponent: 8, bytesPerRow: CVPixelBufferGetBytesPerRow(unwrappedPixelBuffer), space: rgbColorSpace, bitmapInfo: CGImageAlphaInfo.noneSkipFirst.rawValue) else { return nil }
        
        context.draw(self, in: CGRect(x: 0, y: 0, width: width, height: height))
        
        return unwrappedPixelBuffer
    }
}

struct HostedDepthEstimationViewController: UIViewControllerRepresentable {
    func makeUIViewController(context: Context) -> UIViewController {
        return DepthEstimationVC()
    }
    
    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {
    }
}
