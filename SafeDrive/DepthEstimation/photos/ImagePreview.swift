//
//  ImagePreview.swift
//  SafeDrive
//
//  Created by שיראל זכריה on 10/04/2024.
//

import SwiftUI

struct ImagePreview: View {
    @Binding var image: Image?
    var body: some View {
        image?
            .resizable()
            .aspectRatio(contentMode: .fit)
    }
}

struct ImagePreview_Previews: PreviewProvider {
    @State static var image: Image?
    static var previews: some View {
        ImagePreview(image: $image)
    }
}
