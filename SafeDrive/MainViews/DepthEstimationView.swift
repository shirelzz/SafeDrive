//
//  DepthEstimationView.swift
//  SafeDrive
//
//  Created by שיראל זכריה on 09/04/2024.
//

import SwiftUI

struct DepthEstimationView: View {
    var body: some View {
        
        HostedDepthEstimationViewController()
            .ignoresSafeArea()
    }
}

#Preview {
    DepthEstimationView()
}
