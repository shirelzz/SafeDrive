//
//  IntelligentConsoleView.swift
//  SafeDrive
//
//  Created by שיראל זכריה on 10/04/2024.
//

import SwiftUI

struct IntelligentConsoleView: View {
    @Binding var output: IntelligenceOutput
    var body: some View {
        VStack {
            Spacer()
            
            HStack {
                Text("\(Int(output.executionTime))ms ,")
                Text("\(Int(output.modelSize))MB ,")
                Text("\(Int(output.imageSize.width)) : \(Int(output.imageSize.height))res")
                Spacer()
            }
            .padding()
            
            HStack {
                Text("Confidence: \(output.confidence)")
                Text("Title: \(output.title)")
                Spacer()
            }
            .padding()
        }
    }
}

struct IntelligentConsoleView_Previews: PreviewProvider {
    @State private static var output =
        IntelligenceOutput(
            image: nil,
            confidence: 0,
            executionTime: 0,
            title: "",
            modelSize: 0,
            imageSize: CGSize(width: 0, height: 0)
        )
    static var previews: some View {
        IntelligentConsoleView(output: $output)
    }
}
