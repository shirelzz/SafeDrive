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
                    Label("Object Detection", systemImage: "rectangle.stack.fill")
                        .padding(10)
                }
            DepthEstimationView()
                .tabItem {
                    Label("Depth Estimation", systemImage: "square.stack.fill")
                        .padding(10)
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
