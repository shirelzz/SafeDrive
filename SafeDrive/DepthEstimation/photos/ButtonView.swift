//
//  ButtonView.swift
//  SafeDrive
//
//  Created by שיראל זכריה on 10/04/2024.
//

import SwiftUI

struct ButtonView: View {
    @Binding var showPicker: Bool
    @ObservedObject var presenter: MainPresenter
    var body: some View {
        VStack {
            HStack {
                Spacer()
                Button(action: {
                    self.showPicker = true
                }) {
                    Text("Change Photo")
                        .foregroundStyle(.primary)
                        //.padding()
                }
                .buttonStyle(.borderedProminent)
                .padding()
                .disabled(self.$presenter.loading.wrappedValue)
            }
            Spacer()
        }
    }
}

struct ButtonView_Previews: PreviewProvider {
    @State static var showPicker = false
    static var previews: some View {
        ButtonView(showPicker: $showPicker, presenter: MainPresenter())
    }
}
