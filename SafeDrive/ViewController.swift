//
//  ViewController.swift
//  SafeDrive
//
//  Created by שיראל זכריה on 05/03/2024.
//

import Foundation
import UIKit
import SwiftUI
import Vision
import CoreML
import AVFoundation

class ViewController: UIViewController, AVCaptureVideoDataOutputSampleBufferDelegate {
//    private var permissionGranted = false // Flag for permission
    private let captureSession = AVCaptureSession()
    private let sessionQueue = DispatchQueue(label: "sessionQueue")
    private var previewLayer = AVCaptureVideoPreviewLayer()
    var screenRect: CGRect! = nil // For view dimensions
    
    // Detector
    private var videoOutput = AVCaptureVideoDataOutput()
    var requests = [VNRequest]()
    var detectionLayer: CALayer! = nil
    
      
    override func viewDidLoad() {
//        checkPermission()
        
        sessionQueue.async { [unowned self] in
//            guard permissionGranted else { return }
            self.setupCaptureSession()
            
            self.setupLayers()
            self.setupDetector()
            
            self.captureSession.startRunning()
        }
    }
    
    override func willTransition(to newCollection: UITraitCollection, with coordinator: UIViewControllerTransitionCoordinator) {
        screenRect = UIScreen.main.bounds
        self.previewLayer.frame = CGRect(x: 0, y: 0, width: screenRect.size.width, height: screenRect.size.height)

        switch UIDevice.current.orientation {
            // Home button on top
            case UIDeviceOrientation.portraitUpsideDown:
                self.previewLayer.connection?.videoOrientation = .portraitUpsideDown
             
            // Home button on right
            case UIDeviceOrientation.landscapeLeft:
                self.previewLayer.connection?.videoOrientation = .landscapeRight
            
            // Home button on left
            case UIDeviceOrientation.landscapeRight:
                self.previewLayer.connection?.videoOrientation = .landscapeLeft
             
            // Home button at bottom
            case UIDeviceOrientation.portrait:
                self.previewLayer.connection?.videoOrientation = .portrait
                
            default:
                break
            }
        
        // Detector
        updateLayers()
    }
    
//    func checkPermission() {
//        switch AVCaptureDevice.authorizationStatus(for: .video) {
//            // Permission has been granted before
//            case .authorized:
//                permissionGranted = true
//                
//            // Permission has not been requested yet
//            case .notDetermined:
//                requestPermission()
//                    
//            default:
//                permissionGranted = false
//            }
//    }
    
//    func requestPermission() {
//        sessionQueue.suspend()
//        AVCaptureDevice.requestAccess(for: .video) { [unowned self] granted in
//            self.permissionGranted = granted
//            self.sessionQueue.resume()
//        }
//    }
    
    func setupCaptureSession() {
        // Define the URL of the sample video file
        guard let videoURL = Bundle.main.url(forResource: "cityDrive", withExtension: "mp4") else {
            fatalError("Sample video not found")
        }
        
        // Create an AVAsset from the video URL
        let videoAsset = AVAsset(url: videoURL)
        
        // Create an AVPlayerItem from the video asset
        let playerItem = AVPlayerItem(asset: videoAsset)
        
        // Create an AVPlayer with the player item
        let player = AVPlayer(playerItem: playerItem)
        
        // Create a player layer to display the video
        let playerLayer = AVPlayerLayer(player: player)
        playerLayer.videoGravity = .resizeAspectFill
        
        // Set the frame of the player layer to match the screen size
        playerLayer.frame = CGRect(x: 0, y: 0, width: screenRect.size.width, height: screenRect.size.height)
        
        // Add the player layer to the view's layer
        view.layer.addSublayer(playerLayer)
        
        // Start playing the video
        player.play()
    }

    
//    func setupCaptureSession() {
//        // Camera input
//        guard let videoDevice = AVCaptureDevice.default(.builtInDualWideCamera,for: .video, position: .back) else { return }
//        guard let videoDeviceInput = try? AVCaptureDeviceInput(device: videoDevice) else { return }
//           
//        guard captureSession.canAddInput(videoDeviceInput) else { return }
//        captureSession.addInput(videoDeviceInput)
//                         
//        // Preview layer
//        screenRect = UIScreen.main.bounds
//        
//        previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
//        previewLayer.frame = CGRect(x: 0, y: 0, width: screenRect.size.width, height: screenRect.size.height)
//        previewLayer.videoGravity = AVLayerVideoGravity.resizeAspectFill // Fill screen
//        previewLayer.connection?.videoOrientation = .portrait
//        
//        // Detector
//        videoOutput.setSampleBufferDelegate(self, queue: DispatchQueue(label: "sampleBufferQueue"))
//        captureSession.addOutput(videoOutput)
//        
//        videoOutput.connection(with: .video)?.videoOrientation = .portrait
//        
//        // Updates to UI must be on main queue
//        DispatchQueue.main.async { [weak self] in
//            self!.view.layer.addSublayer(self!.previewLayer)
//        }
//    }
}

struct HostedViewController: UIViewControllerRepresentable {
    func makeUIViewController(context: Context) -> UIViewController {
        return ViewController()
        }

        func updateUIViewController(_ uiViewController: UIViewController, context: Context) {
        }
}

//class ViewController: UIViewController {
//    
//    var yolov5Model: YOLOv5?
//    var videoURL: URL?
//    
//    override func viewDidLoad() {
//        super.viewDidLoad()
//
//        yolov5Model = YOLOv5()
//
//        // Set the URL of the sample video
//        videoURL = Bundle.main.url(forResource: "cityDrive", withExtension: "mp4")
//
//        // Start object detection on the sample video
//        performObjectDetection()
//    }
//    
//    func performObjectDetection() {
//        guard let videoURL = videoURL, let yolov5Model = yolov5Model else { return }
//
//        do {
//            // Create AVAsset from the video URL
//            let videoAsset = AVAsset(url: videoURL)
//            let videoReader = try AVAssetReader(asset: videoAsset)
//            
//            // Select video track
//            guard let videoTrack = videoAsset.tracks(withMediaType: .video).first else { return }
//            
//            // Create AVAssetReaderTrackOutput
//            let videoOutput = AVAssetReaderTrackOutput(track: videoTrack, outputSettings: nil)
//            
//            // Add output to reader
//            videoReader.add(videoOutput)
//            
//            // Start reading
//            videoReader.startReading()
//            
//            // Read each frame
//            while let sampleBuffer = videoOutput.copyNextSampleBuffer() {
//                guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { continue }
//                
//                // Convert pixelBuffer to UIImage
//                let image = UIImage(pixelBuffer: pixelBuffer)
//                
//                // Perform object detection using YOLOv5 model
//                let predictions = try yolov5Model.prediction(image: pixelBuffer)
//                
//                // Process predictions
//                processPredictions(predictions)
//            }
//        } catch {
//            print("Error reading video: \(error)")
//        }
//    }
//    
//    func processPredictions(_ predictions: YOLOv5Output) {
//        // Iterate through predictions
//        for prediction in predictions.predictions {
//            // Check for hazardous objects (e.g., pedestrians, cars)
//            if prediction.label == "person" || prediction.label == "car" {
//                // Trigger alert
//                triggerAlert()
//            }
//
//            // Draw bounding box around detected object (optional)
//            let boundingBox = prediction.rect
//            // Draw bounding box on image (e.g., using Core Graphics)
//            // ...
//        }
//    }
//    
//    func triggerAlert() {
//        // Voice alert
//        let utterance = AVSpeechUtterance(string: "Attention: Hazardous object detected!")
//        let synthesizer = AVSpeechSynthesizer()
//        synthesizer.speak(utterance)
//        
//        // Haptic feedback
//        let feedbackGenerator = UINotificationFeedbackGenerator()
//        feedbackGenerator.notificationOccurred(.warning)
//        
//        // Banner notification
//        let content = UNMutableNotificationContent()
//        content.title = "Alert"
//        content.body = "Hazardous object detected!"
//        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: nil)
//        UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)
//    }
//
////    // Call performObjectDetection function when capturing a camera frame
////    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
////        guard let image = sampleBuffer.image else { return }
////        performObjectDetection(on: image)
////    }
//    
//    //    func performObjectDetection() {
//    //        // Perform object detection on input images or video frames
//    //        // This could involve capturing video frames from the camera or loading images from the photo library
//    //        // For each frame/image, use the YOLO model to perform object detection
//    //
//    //        // Example: Get bounding boxes and class labels from the YOLO model
//    //        let boundingBoxes = detectObjects(in: frame)
//    //
//    //        // Filter detected objects based on target class labels
//    //        let targetClassLabels = ["red light", "pedestrian", "car"]
//    //        let filteredBoxes = boundingBoxes.filter { targetClassLabels.contains($0.label) }
//    //
//    //        // Display filtered objects on the screen
//    //        displayFilteredObjects(filteredBoxes)
//    //    }
//
//
//
////    func detectObjects(in frame: UIImage) -> [BoundingBox] {
////        // Use the YOLO model to perform object detection on the input frame
////        // This involves passing the frame as input to the YOLO model and processing the output to extract bounding boxes and class labels
////    }
////
////    func displayFilteredObjects(_ boxes: [BoundingBox]) {
////        // Draw bounding boxes and labels for the filtered objects on the screen
////        // Use Core Graphics or other drawing libraries to draw the bounding boxes and labels on the input frame
////    }
//}
//
//
//extension UIImage {
//    convenience init?(pixelBuffer: CVPixelBuffer) {
//        let ciImage = CIImage(cvPixelBuffer: pixelBuffer)
//        let context = CIContext()
//        guard let cgImage = context.createCGImage(ciImage, from: ciImage.extent) else { return nil }
//        self.init(cgImage: cgImage)
//    }
//}

//struct HostedViewController: UIViewControllerRepresentable {
//    func makeUIViewController(context: Context) -> UIViewController {
//        return ViewController()
//        }
//
//        func updateUIViewController(_ uiViewController: UIViewController, context: Context) {
//        }
//}

