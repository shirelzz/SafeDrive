//
//  ContentView.swift
//  SafeDrive
//
//  Created by שיראל זכריה on 05/03/2024.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        
        HostedViewController()
                    .ignoresSafeArea()

    }
}

#Preview {
    ContentView()
}

//<key>NSCameraUsageDescription</key>
//<string>We need access to your camera to detect objects for safety purposes.</string>
//
