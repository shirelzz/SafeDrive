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

class DepthEstimationVC: UIViewController, UNUserNotificationCenterDelegate {
    
    var player: AVPlayer!
    var playerLayer: AVPlayerLayer!
    var videoOutput: AVPlayerItemVideoOutput!
    
    var depthEstimationHandler: DepthEstimationHandler!
    var depthLayer: CALayer!
    var screenRect: CGRect! = UIScreen.main.bounds
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupVideoPlayer()
        
        depthEstimationHandler = DepthEstimationHandler(modelName: "FCRNFP16")
        
        setupLayers()
        
        processVideoFrames()
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
    
    func displayDepthEstimation(depthMap: CVPixelBuffer) {
        // Convert the depth map to a grayscale image
        let grayscaleImage = depthMap.toGrayscaleImage()
        
        // Update the depth layer with the grayscale image
        depthLayer.contents = grayscaleImage?.cgImage
    }
    
    func retrievePixelBufferAtCurrentTime() -> CVPixelBuffer? {
        let itemTime = player.currentTime()
        guard let outputItem = player.currentItem,
              let track = outputItem.asset.tracks(withMediaType: AVMediaType.video).first
//                let track = try await outputItem.asset.loadTracks(withMediaType: AVMediaType.video).first

        else {
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



