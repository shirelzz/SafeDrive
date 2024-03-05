//
//  ViewController.swift
//  SafeDrive
//
//  Created by שיראל זכריה on 05/03/2024.
//

import Foundation
import UIKit
import Vision

class ViewController: UIViewController {

    var model: YOLOModel?

    override func viewDidLoad() {
        super.viewDidLoad()

        // Load the pre-trained YOLO model
        // This could involve loading the Core ML model file (yolo.mlmodel)
        guard let model = try? YOLOModel(configuration: MLModelConfiguration()) else {
            fatalError("Failed to load YOLO model")
        }
        self.model = model

        // Start object detection on input images or video frames
        performObjectDetection()
    }

    func performObjectDetection() {
        // Perform object detection on input images or video frames
        // This could involve capturing video frames from the camera or loading images from the photo library
        // For each frame/image, use the YOLO model to perform object detection

        // Example: Get bounding boxes and class labels from the YOLO model
        let boundingBoxes = detectObjects(in: frame)

        // Filter detected objects based on target class labels
        let targetClassLabels = ["red light", "pedestrian", "car"]
        let filteredBoxes = boundingBoxes.filter { targetClassLabels.contains($0.label) }

        // Display filtered objects on the screen
        displayFilteredObjects(filteredBoxes)
    }

    func detectObjects(in frame: UIImage) -> [BoundingBox] {
        // Use the YOLO model to perform object detection on the input frame
        // This involves passing the frame as input to the YOLO model and processing the output to extract bounding boxes and class labels
    }

    func displayFilteredObjects(_ boxes: [BoundingBox]) {
        // Draw bounding boxes and labels for the filtered objects on the screen
        // Use Core Graphics or other drawing libraries to draw the bounding boxes and labels on the input frame
    }
}
