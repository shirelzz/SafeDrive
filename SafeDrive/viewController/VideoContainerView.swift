////
////  VideoContainerView.swift
////  SafeDrive
////
////  Created by שיראל זכריה on 13/03/2024.
////
//
//import Foundation
//import UIKit
//import AVKit
//import AVFoundation
//
//class VideoContainerView: UIView {
//
//    override class var layerClass: AnyClass {
//        get {
//            return AVPlayerLayer.self
//        }
//    }
//
//    override func layoutSublayers(of layer: CALayer) {
//        super.layoutSublayers(of: layer)
//        guard layer == self.layer else {
//            return
//        }
//        layer.frame = self.bounds
//    }
//
//}
