//
//  ContentView.swift
//  SafeDrive
//
//  Created by שיראל זכריה on 05/03/2024.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        
        //        HostedViewController()
        //                    .ignoresSafeArea()
        
        TabView {
            
            ObjectDetectionView() // UIKitViewControllerRepresentable
                .tabItem {
                    Label("Object Detection", systemImage: "eyeglasses")
                        .padding()
                }
            
            DepthEstimationView()
                .tabItem {
                    Label("Depth Estimation", systemImage: "square.stack.3d.down.dottedline")
                        .padding()
                }
        }
        
    }
}

#Preview {
    ContentView()
}

//<key>NSCameraUsageDescription</key>
//<string>We need access to your camera to detect objects for safety purposes.</string>
//
